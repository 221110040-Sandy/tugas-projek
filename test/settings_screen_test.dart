import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'username': 'superadmin@gmail.com',
      'role': 'super_admin',
    });
  });

  testWidgets('User list is displayed for super admin',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')],
        home: SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hello, superadmin@gmail.com!'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('User List'), findsOneWidget);
  });

  testWidgets('User list is not displayed for non super admin',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'username': 'kasir@gmail.com',
      'role': 'kasir',
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')],
        home: SettingsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('User List'), findsNothing);
  });
}
