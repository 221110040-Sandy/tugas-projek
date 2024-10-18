import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/firebase_options.dart';
import 'package:tugas_akhir/pages/home_screen.dart';
import 'package:tugas_akhir/pages/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseAnalytics.instance.logBeginCheckout(
        value: 10.0,
        currency: 'USD',
        items: [
          AnalyticsEventItem(
              itemName: 'SANDY BOY', itemId: 'xjw73ndnw', price: 10),
        ],
        coupon: '10PERCENTOFF');
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
