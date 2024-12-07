import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/firebase_options.dart';
import 'package:tugas_akhir/screen/add_sales_screen.dart';
import 'package:tugas_akhir/screen/change_password_screen.dart';
import 'package:tugas_akhir/screen/customer_screen.dart';
import 'package:tugas_akhir/screen/home_screen.dart';
import 'package:tugas_akhir/screen/hot_product_screen.dart';
import 'package:tugas_akhir/screen/master_items_screen.dart';
import 'package:tugas_akhir/screen/profile_screen.dart';
import 'package:tugas_akhir/screen/sales_transaction_screen.dart';
import 'package:tugas_akhir/screen/splash_screen.dart';
import 'package:tugas_akhir/screen/login_screen.dart';
import 'package:tugas_akhir/screen/user_list_screen.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? username;
  String? role;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    FirestoreService firestoreService = FirestoreService();
    bool superAdminExists = await firestoreService.checkSuperAdminExists();
    if (!superAdminExists) {
      await firestoreService.addSuperAdmin(
          'superadmin@gmail.com', 'superadminpassword');
      print("Superadmin berhasil ditambahkan");
    } else {
      print("Superadmin sudah ada");
    }
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.database;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  username = prefs.getString('username');
  role = prefs.getString('role');

  runApp(MyApp(username: username, role: role));
}

class MyApp extends StatelessWidget {
  final String? username;
  final String? role;

  MyApp({this.username, this.role});

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
        '/customers': (context) => CustomerScreen(),
        '/profile': (context) => ProfileScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/user-list': (context) => UserListScreen(),
        '/hot-product': (context) => HotProductsScreen(),
        '/master-items': (context) => MasterItemsScreen(),
        '/sales-transaction': (context) => SalesTransactionScreen(),
        '/add-sales': (context) => AddSalesScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
