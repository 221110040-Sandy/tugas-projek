import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FlutterLogo(size: 100),
      ),
    );
  }
}
