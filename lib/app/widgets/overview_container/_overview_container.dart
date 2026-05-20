import 'package:flutter/material.dart';

import '../../core/core.dart';

class OverviewContainer extends StatelessWidget {
  const OverviewContainer({
    super.key,
    required this.label,
    required this.value,
    this.alignment = OverviewAlignment.center,
    this.color,
    this.isCurrency = false,
    this.decimalDigits = 2,
    this.customCurrencySymbol,
    this.obscureValue = false,
    this.showCompactValue = false,
  });

  final String label;
  final num value;
  final OverviewAlignment alignment;
  final Color? color;
  final bool isCurrency;
  final int decimalDigits;
  final String? customCurrencySymbol;
  final bool obscureValue;
  final bool showCompactValue;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Container(
      alignment: alignment.alignment,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: alignment.crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getValue(),
            style: _theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox.square(dimension: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _theme.textTheme.bodyMedium?.copyWith(
              color: _theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String getValue() {
    if (obscureValue) return value.toString().obscure;

    if (isCurrency) {
      if (showCompactValue) {
        return value.compactCurrency(
          customCurrency: customCurrencySymbol,
          decimalDigits: decimalDigits,
        );
      }
      return value.quickCurrency(
        customCurrency: customCurrencySymbol,
        decimalDigits: decimalDigits,
      );
    }

    if (showCompactValue) {
      return value.compactNumber();
    }
    return value.commaSeparated(decimalDigits: decimalDigits);
  }
}

enum OverviewAlignment {
  start,
  center,
  end;

  CrossAxisAlignment get crossAxisAlignment {
    return switch (this) {
      start => CrossAxisAlignment.start,
      end => CrossAxisAlignment.end,
      center => CrossAxisAlignment.center,
    };
  }

  AlignmentGeometry get alignment {
    return switch (this) {
      start => AlignmentDirectional.centerStart,
      center => AlignmentDirectional.center,
      end => AlignmentDirectional.centerEnd,
    };
  }
}
