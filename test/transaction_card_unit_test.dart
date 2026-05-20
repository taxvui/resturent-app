import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos/app/core/core.dart';
import 'package:restaurant_pos/app/widgets/widgets.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('TransactionCardStatus Tests', () {
    test('creates a loss status correctly', () {
      final lossStatus = TransactionCardStatus.loss(value: 100);

      expect(lossStatus.label, 'Loss');
      expect(lossStatus.value, 100);
      expect(lossStatus.color, DAppColors.kWarning);
      expect(lossStatus.filled, isFalse);
    });

    test('creates a profit status correctly', () {
      final profitStatus = TransactionCardStatus.profit(value: 500);

      expect(profitStatus.label, 'Profit');
      expect(profitStatus.value, 500);
      expect(profitStatus.color, DAppColors.kSuccess);
      expect(profitStatus.filled, isFalse);
    });
  });

  group('TransactionCardData Tests', () {
    test('constructs with correct default values', () {
      final data = TransactionCardData(
        cardType: TransactionCardType.saleList(),
        invoiceNumber: '12345',
      );

      expect(data.transactionDate, isNull);
      expect(data.primaryValue, 0);
      expect(data.secondaryValue, 0);
      expect(data.decimalDigits, 2);
    });

    test('creates with custom currency and decimal digits', () {
      final data = TransactionCardData(
        cardType: TransactionCardType.purchaseReport(),
        invoiceNumber: '56789',
        customCurrency: '€',
        decimalDigits: 3,
      );

      expect(data.customCurrency, '€');
      expect(data.decimalDigits, 3);
    });
  });

  group('TransactionCardType Tests', () {
    test('constructs predefined saleReport type correctly', () {
      final type = TransactionCardType.saleReport();

      expect(type.primaryKey, 'Sales');
      expect(type.secondaryKey, 'Profit');
      expect(type.status, isNull);
    });

    test('constructs custom type correctly', () {
      final type = TransactionCardType.custom(
        primaryKey: 'CustomKey1',
        secondaryKey: 'CustomKey2',
        status: TransactionCardStatus.paid,
      );

      expect(type.primaryKey, 'CustomKey1');
      expect(type.secondaryKey, 'CustomKey2');
      expect(type.status, TransactionCardStatus.paid);
    });
  });
}
