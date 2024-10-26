import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/firebase_options.dart';
import 'package:tugas_akhir/screen/home_screen.dart';
import 'package:tugas_akhir/screen/splash_screen.dart';
import 'package:tugas_akhir/screen/login_screen.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart'; // Import your DatabaseHelper

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    // Initialize the Firestore service
    FirestoreService firestoreService = FirestoreService();
    bool superAdminExists = await firestoreService.checkSuperAdminExists();
    if (!superAdminExists) {
      await firestoreService.addSuperAdmin('superadmin', 'superadminpassword');
      print("Superadmin berhasil ditambahkan");
    } else {
      print("Superadmin sudah ada");
    }
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  // Initialize SQLite database
  DatabaseHelper dbHelper = DatabaseHelper(); // Create an instance
  await dbHelper.database; // This will create the database if it doesn't exist

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Program',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
