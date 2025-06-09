import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import '../services/database.dart';
import '../models/admin.dart';
import 'login_screen.dart';
import 'package:healthsync/screens/hospital/hospital_dashboard_screen.dart';
import 'package:healthsync/screens/pharmacy/pharmacy_dashboard_screen.dart';
import 'package:uuid/uuid.dart';

class AdminSignUpScreen extends StatefulWidget {
  const AdminSignUpScreen({super.key});

  @override
  _AdminSignUpScreenState createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '###########',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _facilityNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final String _phonePrefix = '+234 ';
  String? _facilityType;

  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // If user entered 11 digits (typical Nigerian number starting with 0)
    if (digits.length == 11 && digits.startsWith('0')) {
      return '+234${digits.substring(1)}';
    }
    // If user entered 10 digits (without leading 0)
    else if (digits.length == 10) {
      return '+234$digits';
    }
    // If user entered full number with country code
    else if (digits.length == 13 && digits.startsWith('234')) {
      return '+$digits';
    }
    // Return as is (will be caught by validator)
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    const maxFormWidth = 400.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > maxFormWidth ? maxFormWidth : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 245, 242),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: formWidth,
                  child: Form(
                    key: _formKey,
                    child: AbsorbPointer(
                      absorbing: _isLoading,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.png', // Path to your image
                            width: 60,        // Adjust width as needed
                            height: 70,       // Adjust height as needed
                          ),
                          const Text(
                            'HealthSync',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Create Admin Account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 117, 117, 117),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return const TextStyle(color: Colors.blue);
                                  }
                                  return const TextStyle(color: Colors.blueGrey);
                                }),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              validator: (value) => value!.isEmpty || !_emailRegex.hasMatch(value)
                                  ? 'Enter a valid email address'
                                  : null,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 11.5, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    _phonePrefix,
                                    style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 11, 72, 122)),
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    inputFormatters: [_phoneFormatter],
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                      if (states.contains(WidgetState.focused)) {
                                        return const TextStyle(color: Colors.blue);
                                      }
                                      return const TextStyle(color: Colors.blueGrey);
                                      }),
                                      enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      ),
                                      hintText: '8012345678',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      
                                      String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                                      
                                      // Accept either 10 digits (without prefix) or 11 digits (with leading 0)
                                      if (digits.length == 10 || (digits.length == 11 && digits.startsWith('0'))) {
                                        return null;
                                      }
                                      
                                      return 'Enter 10 digits (8012345678) or 11 digits (08012345678)';
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return const TextStyle(color: Colors.blue);
                                  }
                                  return const TextStyle(color: Colors.blueGrey);
                                }),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value!.length < 6) {
                                  return 'Minimum 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: TextFormField(
                              controller: _facilityNameController,
                              decoration: InputDecoration(
                                labelText: 'Facility Name',
                                labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return const TextStyle(color: Colors.blue);
                                  }
                                  return const TextStyle(color: Colors.blueGrey);
                                }),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              validator: (value) => value!.isEmpty 
                                  ? 'Please enter your facility name'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                            ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: DropdownButtonFormField<String>(
                              value: _facilityType,
                              decoration: InputDecoration(
                              labelText: 'Facility Type',
                              labelStyle: WidgetStateTextStyle.resolveWith((states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return const TextStyle(color: Colors.blue);
                                  }
                                  return const TextStyle(color: Colors.blueGrey);
                              }),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 0, 23, 43)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              ),
                              items: const [
                              DropdownMenuItem(value: 'Hospital/Clinic', child: Text('Hospital/Clinic')),
                              DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy')),
                              ],
                              onChanged: (value) => setState(() => _facilityType = value),
                              validator: (value) => value == null ? 'Please select a facility type' : null,
                            ),
                            ),
                          
                          const SizedBox(height: 30),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: _isLoading ? null : _signUpAdmin,
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                            child: const Text(
                              'Already have an account? Login',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
  
  Future<void> _signUpAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_facilityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid facility type.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      String formattedPhone = _formatPhoneNumber(_phoneController.text);

      // 1. Create Firebase Auth account
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signUpAdmin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        throw Exception('User creation failed');
      }

      // 2. Create Admin object with all data
      final admin = Admin(
        uid: user.uid,
        email: _emailController.text.trim(),
        phone: formattedPhone,
        createdAt: DateTime.now(),
        facilityType: _facilityType!,
        facilityName: _facilityNameController.text.trim(),
        sessionId: const Uuid().v4(),
        lastActive: DateTime.now()
      );

      // 3. Save admin profile to Firestore using DatabaseService
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      bool isSaved = await databaseService.saveAdminProfile(admin);
      if (!isSaved) {
        // If saving fails, delete the Firebase Auth account
        await user.delete();
        throw Exception('Failed to save admin data to Firestore');
      }

      // Clear form fields
      if (mounted) {
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin account created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        // 4. Navigate to appropriate dashboard based on facility type
        _navigateToDashboard(_facilityType!);
      }

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please use a different email or login.';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters long.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid. Please enter a valid email.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled. Contact support.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection and try again.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;
        default:
          message = 'An unexpected error occurred: ${e.message}';
          debugPrint('FirebaseAuth Error: ${e.code} - ${e.message}');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('Unexpected Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard(String facilityType) {
    Widget destination;
    
    switch (facilityType) {
      case 'Hospital/Clinic':
        destination = const HospitalDashboardScreen();
        break;
      case 'Pharmacy':
        destination = const PharmacyDashboardScreen();
        break;
      default:
        destination = const HospitalDashboardScreen(); // Default fallback
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _facilityNameController.dispose();
    super.dispose();
  }
}

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      // Ensures it covers the whole screen
      child: Stack(
        children: [
          // Blurred, semi-transparent background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          // Centered small blue CircularProgressIndicator
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
    );
  }
}