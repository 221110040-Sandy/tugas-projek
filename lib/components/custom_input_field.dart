import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false, // Default is false for non-password fields
  }) : super(key: key);

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText; // Use the passed obscureText value
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText
          ? _obscureText
          : false, // Only obscure text if it's a password field
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelBehavior:
            FloatingLabelBehavior.never, // Label disappears when typing
        prefixIcon: Icon(widget.icon, color: Colors.white),
        // Show "show/hide" button only for password fields
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
