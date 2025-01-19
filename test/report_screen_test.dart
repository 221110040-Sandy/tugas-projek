import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/report_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'username': 'admin@gmail.com',
      'role': 'admin',
    });
  });

  testWidgets('Report testing and Check if admin has access',
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
        home: ReportScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('Adjustment'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);
  });

  testWidgets('Report testing and Check if kasir no access',
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
        home: ReportScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sales'), findsNothing);
    expect(find.text('Buy'), findsNothing);
    expect(find.text('Adjustment'), findsNothing);
    expect(find.text('Stock'), findsNothing);
  });
}
