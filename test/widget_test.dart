import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_akhir/screen/profile_screen.dart';
import 'package:tugas_akhir/localization/app_localization.dart';

void main() {
  testWidgets('ProfileScreen displays "Profile" text',
      (WidgetTester tester) async {
    // Build the widget with localization support
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')], // Ensure a locale is supported
        home: ProfileScreen(),
      ),
    );

    // Wait for the widget to be rendered
    await tester.pumpAndSettle();

    // Check if the text "Profile" is present on the screen
    expect(find.text('Profile'), findsOneWidget);
  });
}
