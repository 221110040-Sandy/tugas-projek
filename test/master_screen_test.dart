import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/screen/contact_screen.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/master_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'username': 'superadmin@gmail.com',
      'role': 'super_admin',
    });
  });

  testWidgets('Master item testing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')],
        routes: {
          '/contacts': (context) => ContactScreen(),
        },
        home: MasterScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Hot Products'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);

    await tester.tap(find.text('Contacts'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Contacts'), findsOneWidget);
  });
}
