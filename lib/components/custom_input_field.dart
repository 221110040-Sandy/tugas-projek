import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final bool
      isDarkBackground; // Add parameter to indicate background color type

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.isDarkBackground = true, // Default is true for dark backgrounds
  }) : super(key: key);

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText ? _obscureText : false,
      style: TextStyle(
        color: widget.isDarkBackground ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.isDarkBackground ? Colors.white70 : Colors.black54,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(
          widget.icon,
          color: widget.isDarkBackground ? Colors.white : Colors.black54,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color:
                      widget.isDarkBackground ? Colors.white : Colors.black54,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        filled: true,
        fillColor: widget.isDarkBackground ? Colors.white24 : Colors.grey[200],
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
