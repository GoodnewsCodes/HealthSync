import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import '../models/admin.dart';
import 'screens/login_screen.dart';
import 'package:healthsync/screens/hospital/hospital_dashboard_screen.dart';
import 'package:healthsync/screens/pharmacy/pharmacy_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/database.dart';
import 'services/sms_service.dart';
import 'provider/auth_provider.dart' as custom;
import 'dart:async';
import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await _initializeFirebase();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<custom.AuthProvider>(create: (_) => custom.AuthProvider()),
          Provider<AuthService>(create: (_) => AuthService()),
          Provider<DatabaseService>(create: (_) => DatabaseService()),
          Provider<SmsService>(create: (_) => SmsService()),
          StreamProvider<Admin?>(
            create: (context) {
              final user = context.watch<User?>();
              if (user == null) return Stream.value(null);
              final db = FirebaseFirestore.instance;
              return db.collection('admins').doc(user.uid).snapshots().map((snap) {
                if (snap.exists) {
                  return Admin.fromMap(snap.data()!);
                }
                return null;
              });
            },
            initialData: null,
          ),
        ],
        child: const HealthSyncApp(),
      ),
    );
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization failed: ${error.toString()}'),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Basic connectivity check during startup
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Potentially show an initial message about no internet, but let the app load
      debugPrint('No internet connection at startup.');
    }
    
    // Attempt to warm up Firebase Auth to ensure it's ready
    await FirebaseAuth.instance.authStateChanges().first;

  } catch (e) {
    throw Exception('Failed to initialize Firebase: $e. Please check your internet connection and Firebase setup.');
  }
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom.AuthProvider>(context);

    if (authProvider.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: _AppLoadingOverlay(),
        ),
      );
    }

    if (authProvider.user == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      );
    } else {
      if (authProvider.facilityType == null) {
        return const _AppLoadingOverlay();
      } else {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: authProvider.facilityType == 'Pharmacy'
              ? const PharmacyDashboardScreen()
              : const HospitalDashboardScreen(),
        );
      }
    }
  }
}

class _AppLoadingOverlay extends StatelessWidget {
  const _AppLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}