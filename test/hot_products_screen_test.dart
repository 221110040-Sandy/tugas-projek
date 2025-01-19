import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/hot_product_screen.dart';

// Mock localization
class MockAppLocalization extends Mock implements AppLocalization {}

@GenerateMocks([AppLocalization])
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

    expect(find.text('Produk Terlaris'), findsOneWidget);
    expect(find.text('Hot Products'), findsNothing);
  });
}
