import 'package:flutter/material.dart';
import 'package:tugas_akhir/components/custom_button.dart';
import 'package:tugas_akhir/components/custom_input_field.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/auth_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

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
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('change_password')),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor.withOpacity(0.7),
              accentColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              loc.translate('change_password'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              controller: _oldPasswordController,
              labelText: loc.translate('old_password'),
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomInputField(
              controller: _newPasswordController,
              labelText: loc.translate('new_password'),
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            CustomInputField(
              controller: _confirmPasswordController,
              labelText: loc.translate('confirm_new_password'),
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            CustomButton(
              text: loc.translate('confirm'),
              onPressed: () => _changePassword(loc),
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

  Future<void> _changePassword(loc) async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage = loc.translate('not_match');
      });
      return;
    }

    bool success = await _authService.changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('success'))),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = loc.translate('wrong_password');
      });
    }
  }
}
