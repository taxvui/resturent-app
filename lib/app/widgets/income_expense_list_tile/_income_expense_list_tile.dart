import 'package:flutter/material.dart';

import '../../core/core.dart';

class IncomeExpenseListTile extends StatelessWidget {
  const IncomeExpenseListTile({
    super.key,
    required this.tileData,
    this.onTap,
    this.trailing,
  });
  final IncomeExpenseListTileData tileData;

  final void Function()? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _cTitleStyle = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final _cSubtitleStyle = _theme.textTheme.bodyMedium?.copyWith(
      color: _theme.colorScheme.secondary,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          border: BorderDirectional(
            bottom: Divider.createBorderSide(context),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          tileData.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _cTitleStyle,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          tileData.amount.quickCurrency(),
                          textAlign: TextAlign.end,
                          style: _cTitleStyle?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.square(dimension: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          tileData.categoryName ?? 'N/A',
                          style: _cSubtitleStyle,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          tileData.date?.getFormatedString() ?? '',
                          textAlign: TextAlign.end,
                          style: _cSubtitleStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox.square(dimension: 8),
              trailing!,
            ]
          ],
        ),
      ),
    );
  }
}

class IncomeExpenseListTileData {
  final String name;
  final String? categoryName;
  final num amount;
  final DateTime? date;

  const IncomeExpenseListTileData({
    required this.name,
    this.categoryName,
    this.amount = 0,
    this.date,
  });
}
