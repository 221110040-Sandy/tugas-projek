import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/theme/colors.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpeg',
        ),
      ),
    );
  }
}
