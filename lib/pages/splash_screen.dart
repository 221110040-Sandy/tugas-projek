import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 138, 30),
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpeg',
        ),
      ),
    );
  }
}
