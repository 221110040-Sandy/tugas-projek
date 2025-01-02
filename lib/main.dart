import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/firebase_options.dart';
import 'package:tugas_akhir/screen/add_adjust_screen.dart';
import 'package:tugas_akhir/screen/add_buy_screen.dart';
import 'package:tugas_akhir/screen/add_sales_screen.dart';
import 'package:tugas_akhir/screen/adjusts_transaction_screen.dart';
import 'package:tugas_akhir/screen/buys_transaction_screen.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tugas_akhir/localization/app_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? username;
  String? role;

  String languageCode = 'en';

  SharedPreferences prefs = await SharedPreferences.getInstance();
  languageCode = prefs.getString('language') ?? 'en';

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

  username = prefs.getString('username');
  role = prefs.getString('role');

  runApp(MyApp(username: username, role: role, languageCode: languageCode));
}

class MyApp extends StatelessWidget {
  final String? username;
  final String? role;
  final String languageCode;

  MyApp({this.username, this.role, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Program',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      supportedLocales: const [
        Locale('en', ''),
        Locale('id', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(languageCode),
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
        '/add-sales': (context) => AddSalesScreen(),
        '/buys-transaction': (context) => BuysTransactionScreen(),
        '/add-buys': (context) => AddBuysScreen(),
        '/adjusts-transaction': (context) => AdjustsTransactionScreen(),
        '/add-adjusts': (context) => AddAdjustsScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
