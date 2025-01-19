import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/transaction_screen.dart';

void main() {
  testWidgets('Transaction testing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', 'US')],
        home: TransactionScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('Adjustment'), findsOneWidget);
  });
}
