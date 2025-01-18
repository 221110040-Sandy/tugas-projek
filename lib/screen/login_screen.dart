import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/components/custom_button.dart';
import 'package:tugas_akhir/components/custom_input_field.dart';
import 'package:tugas_akhir/services/auth_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';

  AuthService _authService = AuthService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              accentColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20.0),
                const SizedBox(height: 40.0),
                CustomInputField(
                  controller: _usernameController,
                  labelText: 'Email',
                  icon: Icons.person_outline,
                  isDarkBackground: true,
                ),
                const SizedBox(height: 20.0),
                CustomInputField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock_outline,
                  isDarkBackground: true,
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                CustomButton(
                  text: 'Login',
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    await _analytics.logEvent(
      name: 'login_attempt',
      parameters: {
        'email': _usernameController.text,
      },
    );
    bool success = await _authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      await _analytics.logEvent(
        name: 'login_success',
        parameters: {
          'email': _usernameController.text,
        },
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      await _analytics.logEvent(
        name: 'login_failure',
        parameters: {
          'email': _usernameController.text,
        },
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Gagal'),
            content: const Text('Email atau password salah.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
