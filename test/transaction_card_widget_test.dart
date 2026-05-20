import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos/app/widgets/widgets.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('TransactionCard Widget Test', () {
    testWidgets('renders TransactionCard correctly', (WidgetTester tester) async {
      // Mock Data
      final mockData = TransactionCardData(
        cardType: TransactionCardType.saleReport(),
        invoiceNumber: '12345',
        transactionDate: DateTime(2023, 11, 27),
        paymentType: 'Cash',
        primaryValue: 500,
        secondaryValue: 200,
      );

      // Build Widget
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: TransactionCard(cardData: mockData),
            ),
          ),
        ),
      );

      // Assertions
      expect(find.text('Invoice: 12345'), findsOneWidget);
      expect(find.text('27/11/2023'), findsOneWidget);
      expect(find.text('Sales: \$500'), findsOneWidget);
      expect(find.text('Profit: \$200'), findsOneWidget);
      expect(find.text('Payment Type: Cash'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (WidgetTester tester) async {
      bool isTapped = false;

      // Mock Data
      final mockData = TransactionCardData(
        cardType: TransactionCardType.purchaseList(),
        invoiceNumber: '98765',
        transactionDate: DateTime(2023, 11, 26),
        primaryValue: 800,
        secondaryValue: 300,
      );

      // Build Widget
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionCard(
                cardData: mockData,
                onTap: () {
                  isTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Perform Tap
      await tester.tap(find.byType(TransactionCard));
      await tester.pumpAndSettle();

      // Assertions
      expect(isTapped, isTrue);
    });

    testWidgets('renders custom action widget', (WidgetTester tester) async {
      // Mock Data
      final mockData = TransactionCardData(
        cardType: TransactionCardType.saleList(),
        invoiceNumber: '56789',
        transactionDate: DateTime(2023, 11, 25),
        primaryValue: 400,
        secondaryValue: 100,
      );

      // Build Widget
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionCard(
                cardData: mockData,
                action: Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
      );

      // Assertions
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });
}
