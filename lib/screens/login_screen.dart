import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:healthsync/provider/auth_provider.dart';
import 'admin_signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;     // toggle password visibility

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider's loading state
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.isLoading;

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
                      absorbing: isLoading, // Use provider's isLoading
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/logo.png', // App Logo
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'HealthSync',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Admin Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 117, 117, 117),
                            ),
                          ),
                          const SizedBox(height: 30),
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
                              validator: (value) => value!.isEmpty
                                  ? 'Enter a valid email address'
                                  : null,
                              keyboardType: TextInputType.emailAddress,
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
                              validator: (value) => value!.isEmpty
                                  ? 'Enter your password'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 40),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: formWidth),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: isLoading ? null : _login, // Use provider's isLoading
                                child: const Text(
                                  'Login as Admin',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminSignUpScreen()),
                            ),
                            child: const Text(
                              'Don\'t have an account?',
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
            if (isLoading) // Use provider's isLoading
              _LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}