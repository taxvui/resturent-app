import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';

class QuotationListTile extends StatelessWidget {
  const QuotationListTile({
    super.key,
    required this.data,
    this.onConvertSale,
    this.trailing,
  });
  final QuotationListTileData data;
  final void Function()? onConvertSale;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _style = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _theme.colorScheme.primaryContainer,
        border: Border(bottom: Divider.createBorderSide(context)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.partyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _style,
                ),
              ),
              Expanded(
                child: Text(
                  data.quotationNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: _style?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.amount.quickCurrency(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _style?.copyWith(
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  data.date?.getFormatedString() ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: _style?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 8),
          SizedBox.fromSize(
            size: const Size.fromHeight(28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel(
                        theme: _theme,
                        label: data.status.label(context),
                        backgroundColor: data.status.statusColor.withValues(alpha: 0.2),
                        foregroundColor: data.status.statusColor,
                      ),
                      if (data.status == QuotationStatus.open)
                        Material(
                          child: InkWell(
                            onTap: onConvertSale,
                            child: _buildLabel(
                              theme: _theme,
                              // label: 'Convert',
                              label: context.t.common.convert,
                              backgroundColor: _theme.colorScheme.primary,
                              foregroundColor: _theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      else if (data.status == QuotationStatus.closed)
                        _buildLabel(
                          theme: _theme,
                          // label: "Invoice: ${data.invoiceNumber ?? 'N/A'}",
                          label: "${context.t.common.invoice}: ${data.invoiceNumber ?? 'N/A'}",
                          backgroundColor: _theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          foregroundColor: _theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox.square(dimension: 8), trailing!],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel({
    required ThemeData theme,
    Color? backgroundColor,
    Color? foregroundColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? foregroundColor?.withValues(alpha: 0.20),
        borderRadius: BorderRadiusDirectional.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class QuotationListTileData {
  final String partyName;
  final String quotationNumber;
  final String? invoiceNumber;
  final num amount;
  final DateTime? date;
  final QuotationStatus status;

  const QuotationListTileData({
    required this.partyName,
    required this.quotationNumber,
    this.invoiceNumber,
    this.amount = 0,
    this.date,
    this.status = QuotationStatus.open,
  });
}

enum QuotationStatus {
  open(statusColor: Color(0xffAF52DE)),
  closed(statusColor: DAppColors.kSuccess);

  final Color statusColor;
  const QuotationStatus({required this.statusColor});

  String label(BuildContext context) {
    return switch (this) {
      QuotationStatus.open => context.t.enums.quotationStatus.open,
      QuotationStatus.closed => context.t.enums.quotationStatus.open,
    };
  }
}
