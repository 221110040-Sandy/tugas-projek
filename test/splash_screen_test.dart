import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/screen/splash_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'username': 'superadmin@gmail.com',
    });
  });

  testWidgets('SplashScreen navigates to /home when logged in',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(),
      routes: {
        '/home': (context) => Scaffold(body: Text('Home')),
        '/login': (context) => Scaffold(body: Text('Login')),
      },
    ));

    await tester.pumpAndSettle(Duration(seconds: 3));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
  });

  testWidgets('SplashScreen navigates to /login when not logged in',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'username': '',
    });

    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(),
      routes: {
        '/home': (context) => Scaffold(body: Text('Home')),
        '/login': (context) => Scaffold(body: Text('Login')),
      },
    ));

    await tester.pumpAndSettle(Duration(seconds: 3));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });
}
