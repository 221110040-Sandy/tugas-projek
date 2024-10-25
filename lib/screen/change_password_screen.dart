import 'package:flutter/material.dart';
import 'package:tugas_akhir/components/custom_input_field.dart';
import 'package:tugas_akhir/services/auth_services.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String errorMessage = '';

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInputField(
              controller: _oldPasswordController,
              labelText: 'Old Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomInputField(
              controller: _newPasswordController,
              labelText: 'New Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomInputField(
              controller: _confirmPasswordController,
              labelText: 'Confirm New Password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Change Password'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    // Validate old password and new passwords
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = 'New password and confirm password do not match.';
      });
      return;
    }

    bool success = await _authService.changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (success) {
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage =
            'Failed to change password. Please check your old password.';
      });
    }
  }
}
