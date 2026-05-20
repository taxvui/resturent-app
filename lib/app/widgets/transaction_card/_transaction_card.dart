import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../i18n/strings.g.dart';
import '../../core/core.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.cardData,
    this.action,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });
  final TransactionCardData cardData;
  final Widget? action;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _cTextStyle = _theme.textTheme.bodyLarge?.copyWith(
      color: _theme.colorScheme.secondary,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: BorderDirectional(
            bottom: Divider.createBorderSide(context),
          ),
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
                        '${context.t.common.invoice}: ${cardData.invoiceNumber}',
                        style: _cTextStyle?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox.square(dimension: 4),

                      // Date Time
                      Text(
                        _getDate(),
                        textAlign: TextAlign.end,
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Type
                Expanded(
                  flex: 6,
                  child: Text.rich(
                    TextSpan(
                      text: '${context.t.common.paymentType}: ',
                      children: [
                        TextSpan(text: cardData.paymentType ?? 'N/A'),
                      ],
                    ),
                    style: _cTextStyle,
                  ),
                ),

                // Bottom Right Content
                if (cardData.cardType.status != null || action != null)
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Card Status
                        if (cardData.cardType.status != null) _buildStatus(_theme, cardData.cardType.status!),

                        // Action
                        if (action != null) ...[const SizedBox.square(dimension: 8), action!],
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDate() {
    if (cardData.transactionDate == null) return 'N/A';
    return intl.DateFormat('dd/MM/yyyy').format(cardData.transactionDate!);
  }

  Widget _buildStatus(ThemeData theme, TransactionCardStatus status) {
    String _label = status.label;

    if (status.value != null) {
      _label += ": ${status.value!.quickCurrency(decimalDigits: cardData.decimalDigits)}";
    }

    final _content = Text(
      _label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: status.color,
      ),
    );

    if (status.filled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: status.filled ? status.color?.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadiusDirectional.circular(4),
        ),
        child: _content,
      );
    }

    return _content;
  }
}

class TransactionCardData {
  final TransactionCardType cardType;
  final String invoiceNumber;
  final DateTime? transactionDate;
  final String? paymentType;
  final String? customCurrency;
  final int decimalDigits;
  final num primaryValue;
  final num secondaryValue;

  const TransactionCardData({
    required this.cardType,
    required this.invoiceNumber,
    this.transactionDate,
    this.paymentType,
    this.customCurrency,
    this.decimalDigits = 2,
    this.primaryValue = 0.0,
    this.secondaryValue = 0.0,
  });
}

class TransactionCardType {
  TransactionCardType.saleList({
    TransactionCardStatus? status,
  }) : this._(
         // 'Sale',
         t.common.sales,
         // 'Money In',
         t.common.moneyIn,
         status: status,
       );

  TransactionCardType.saleReport({
    TransactionCardStatus? status,
  }) : this._(
         // 'Sale',
         t.common.sales,
         // 'Profit',
         t.common.profit,
         status: status,
       );

  TransactionCardType.quotationSaleReportList({
    TransactionCardStatus? status,
  }) : this._(
         'Quotation Sale',
         'Money In',
         status: status,
       );

  TransactionCardType.purchaseList({
    TransactionCardStatus? status,
  }) : this._(
         t.common.purchase,
         status?.label ?? t.common.moneyOut,
         status: status,
       );

  TransactionCardType.purchaseReport({
    TransactionCardStatus? status,
  }) : this._(
         t.common.purchase,
         status?.label ?? t.common.paid,
         status: status,
       );

  TransactionCardType.dueReport({
    String primaryKey = 'Purchase',
    TransactionCardStatus? status,
  }) : this._(
         'Purchase',
         status == TransactionCardStatus.partial ? 'Due' : status?.label ?? 'Paid',
         status: status,
       );

  final String primaryKey;
  final String secondaryKey;
  final TransactionCardStatus? status;

  const TransactionCardType._(
    this.primaryKey,
    this.secondaryKey, {
    this.status,
  });

  const TransactionCardType.custom({
    required this.primaryKey,
    required this.secondaryKey,
    this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TransactionCardType &&
        other.primaryKey == primaryKey &&
        other.secondaryKey == secondaryKey &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(primaryKey, secondaryKey, status);
}

class TransactionCardStatus {
  static final paid = TransactionCardStatus(
    // label: 'Paid',
    label: t.common.paid,
    color: DAppColors.kSuccess,
  );

  static final due = TransactionCardStatus(
    // label: 'Due',
    label: t.common.due,
    color: DAppColors.kWarning,
  );

  static final partial = TransactionCardStatus(
    // label: 'Partial',
    label: t.common.partial,
    color: Color(0xff5856D6),
  );

  final String label;
  final num? value;
  final Color? color;
  final bool filled;

  const TransactionCardStatus({
    required this.label,
    this.value,
    this.color,
    this.filled = true,
  });

  factory TransactionCardStatus.loss({num? value}) {
    return TransactionCardStatus(
      // label: 'Loss',
      label: t.common.loss,
      value: value,
      color: DAppColors.kWarning,
      filled: false,
    );
  }

  factory TransactionCardStatus.profit({num? value}) {
    return TransactionCardStatus(
      // label: 'Profit',
      label: t.common.profit,
      value: value,
      color: DAppColors.kSuccess,
      filled: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TransactionCardStatus &&
        other.label == label &&
        other.value == value &&
        other.color == color &&
        other.filled == filled;
  }

  @override
  int get hashCode => Object.hash(label, value, color, filled);
}
