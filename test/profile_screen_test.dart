import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/screen/profile_screen.dart';
import 'package:tugas_akhir/localization/app_localization.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'username': 'superadmin@gmail.com',
      'role': 'super_admin',
    });
  });

  testWidgets('ProfileScreen displays "Profile" text and user information',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')],
        home: ProfileScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    expect(find.text('superadmin@gmail.com'), findsOneWidget);
  });
}
