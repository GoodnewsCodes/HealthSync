import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  
  User? _user;
  bool _isLoading = false;
  String? _facilityType;
  String? _error;
  String? _sessionId;
  Timer? _sessionValidationTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get facilityType => _facilityType;
  String? get error => _error;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Set up connectivity listener
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          // When connection is restored, validate session
          _validateSession();
        }
      });

      // Set initial user from current auth state
      _user = _auth.currentUser;
      if (_user != null) {
        await _handleUserSignedIn(_user!);
      }

      // Set up auth state listener
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _handleUserSignedIn(user);
        } else {
          _handleUserSignedOut();
        }
      });
    } catch (e) {
      _error = 'Failed to initialize authentication service.';
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _handleUserSignedIn(User user) async {
    _user = user;
    _sessionId = const Uuid().v4();
    
    try {
      // First try to update just session fields
      await _db.collection('admins').doc(user.uid).update({
        'sessionId': _sessionId,
        'lastActive': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });
      
      await _loadFacilityType();
      _startSessionValidation();
    } catch (e) {
      debugPrint('Error handling user sign in: $e');
      // If update fails, check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // If offline, proceed without updating session (will sync when online)
        await _loadFacilityType();
      } else {
        // If online but still failing, set facilityType to null
        _facilityType = null;
        notifyListeners();
      }
    }
  }

  void _handleUserSignedOut() {
    _user = null;
    _facilityType = null;
    _sessionId = null;
    _sessionValidationTimer?.cancel();
    notifyListeners();
  }

  Future<void> _loadFacilityType() async {
    try {
      if (_user == null) return;
      
      final doc = await _db.collection('admins').doc(_user!.uid).get();
      if (doc.exists) {
        _facilityType = doc.data()?['facilityType'] as String?;
      }
    } catch (e) {
      debugPrint('Error loading facility type: $e');
      // Don't clear facilityType on error to maintain offline functionality
    }
    notifyListeners();
  }

  void _startSessionValidation() {
    _sessionValidationTimer?.cancel();
    // Validate session every 5 minutes
    _sessionValidationTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _validateSession();
    });
  }

  Future<void> _validateSession() async {
    if (_user == null || _sessionId == null) return;

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Don't validate session if offline - wait for next attempt
        return;
      }

      final doc = await _db.collection('admins').doc(_user!.uid).get();
      
      // If document doesn't exist, treat as valid (might be first login)
      if (!doc.exists) return;
      
      final serverSessionId = doc.data()?['sessionId'];
      
      if (serverSessionId != null && serverSessionId != _sessionId) {
        debugPrint('Session mismatch. User signed in on another device.');
        await signOut();
      }
    } catch (e) {
      debugPrint('Session validation error: $e');
      // Don't logout on network or permission errors to maintain offline functionality
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred during login.';
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      if (_user != null) {
        // Attempt to clear session ID from admins collection
        try {
          await _db.collection('admins').doc(_user!.uid).update({
            'sessionId': FieldValue.delete(),
          });
        } catch (e) {
          debugPrint('Error clearing session ID: $e');
          // If that fails, try setting to null
          try {
            await _db.collection('admins').doc(_user!.uid).update({
              'sessionId': null,
            });
          } catch (e) {
            debugPrint('Secondary error clearing session ID: $e');
          }
        }
      }
      await _auth.signOut();
    } catch (e) {
      _error = 'Failed to sign out.';
      debugPrint('Sign out error: $e');
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sessionValidationTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}