import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../widgets/widgets.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.cardData,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });
  final OrderTransactionCardData cardData;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _cTextStyle = _theme.textTheme.bodyLarge?.copyWith(
      color: _theme.colorScheme.secondary,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(bottom: Divider.createBorderSide(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Left Content
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Invoice Number
                    Text(
                      // 'Invoice: ${cardData.invoiceNumber}',
                      '${context.t.common.invoice}: ${cardData.invoiceNumber}',

                      style: _cTextStyle?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox.square(dimension: 4),

                    // Table
                    if (cardData.tableName != null) ...[
                      const SizedBox.square(dimension: 4),
                      Text(
                        'Table: ${cardData.tableName ?? "N/A"}',
                        style: _theme.textTheme.bodyLarge?.copyWith(),
                      ),
                    ],

                    // Date
                    Text(
                      _getDateTime('dd/MM/yyyy'),
                      textAlign: TextAlign.start,
                      style: _cTextStyle,
                    ),
                  ],
                ),
              ),

              // Top Right Content
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Primary Value
                    Text.rich(
                      TextSpan(
                        text: '${cardData.cardType.primaryKey}: ',
                        children: [
                          TextSpan(
                            text: cardData.primaryValue.quickCurrency(
                              decimalDigits: cardData.decimalDigits,
                            ),
                            style: TextStyle(
                              color: cardData.cardType.primaryKey.trim().toLowerCase().contains('sale')
                                  ? _theme.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.end,
                      style: _cTextStyle,
                    ),
                    const SizedBox.square(dimension: 4),

                    // Secondary Value
                    Text(
                      '${cardData.cardType.secondaryKey}: ${cardData.secondaryValue.quickCurrency(decimalDigits: cardData.decimalDigits)}',
                      textAlign: TextAlign.end,
                      style: _cTextStyle,
                    ),

                    // Time
                    Text(
                      _getDateTime('hh:mm a'),
                      textAlign: TextAlign.start,
                      style: _cTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Status
              if (cardData.cardType.status != null)
                Expanded(
                  flex: 6,
                  child: Text(
                    cardData.cardType.status?.label ?? 'N/A',
                    style: _cTextStyle?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cardData.cardType.status?.color,
                    ),
                  ),
                ),

              // Bottom Right Content
              if (cardData.cardType.status != null || action != null)
                Expanded(
                  flex: 5,
                  child: action ?? const SizedBox.shrink(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateTime([String pattern = 'dd/MM/yyyy']) {
    if (cardData.transactionDate == null) return 'N/A';
    return intl.DateFormat(pattern).format(cardData.transactionDate!);
  }
}

class OrderCardType extends TransactionCardType {
  OrderCardType.orderList({required OrderCardTransactionStatus status, bool hasDue = false})
    : super.custom(
        primaryKey: t.common.total,
        secondaryKey: !hasDue ? t.common.paid : t.common.due,
        status: status,
      );
}

class OrderCardTransactionStatus extends TransactionCardStatus {
  const OrderCardTransactionStatus._({
    required super.label,
    super.color,
  });

  static final pending = OrderCardTransactionStatus._(
    label: 'Pending',
    color: DAppColors.kWarning,
  );
  static const completed = OrderCardTransactionStatus._(
    label: 'Completed',
    color: DAppColors.kSuccess,
  );
}

class OrderTransactionCardData extends TransactionCardData {
  OrderTransactionCardData({
    required super.cardType,
    required super.invoiceNumber,
    super.customCurrency,
    super.decimalDigits,
    super.paymentType,
    super.primaryValue,
    super.secondaryValue,
    super.transactionDate,
    this.tableName,
  });

  final String? tableName;
}
