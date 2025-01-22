import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/hot_product_screen.dart';

void main() {
  testWidgets('Testing Translation Hot Product Screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('id', 'ID')],
        home: HotProductsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Terlaris'), findsOneWidget);
    expect(find.text('Hot Products'), findsNothing);
  });
}
