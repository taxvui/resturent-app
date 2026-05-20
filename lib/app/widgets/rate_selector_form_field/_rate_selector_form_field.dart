import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets.dart';
import '../../core/core.dart';

class RateSelectorFormField extends StatelessWidget {
  const RateSelectorFormField({
    super.key,
    this.baseAmount = 0,
    this.showModifierSelector = true,
    required this.controller,
    required this.selectedModifier,
    this.onChanged,
    this.decoration,
  })  : _customBuilder = false,
        builder = null;

  const RateSelectorFormField.builder({
    super.key,
    this.baseAmount = 0,
    required this.controller,
    required this.selectedModifier,
    this.onChanged,
    required this.builder,
  })  : _customBuilder = true,
        showModifierSelector = false,
        decoration = null;

  final bool _customBuilder;
  final RateSelectorFormFieldBuilder? builder;

  final num baseAmount;
  final bool showModifierSelector;
  final TextEditingController controller;
  final RateModifierData selectedModifier;
  final ValueChanged<RateModifierData>? onChanged;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    if (_customBuilder && builder != null) {
      return builder!(
        context,
        selectedModifier,
        _handleDropdownChange,
        (value) => _handleTextFieldChange(context, value),
        controller,
      );
    }

    final _theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        // Mode Selector
        if (showModifierSelector)
          Flexible(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _theme.colorScheme.outline,
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<RateModifierEnum>(
                  isDense: true,
                  isExpanded: true,
                  value: selectedModifier.type,
                  buttonStyleData: ButtonStyleData(
                    width: double.maxFinite,
                    height: 28,
                  ),
                  iconStyleData: IconStyleData(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    openMenuIcon: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                  items: [
                    ...RateModifierEnum.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    })
                  ],
                  onChanged: _handleDropdownChange,
                ),
              ),
            ),
          ),

        // Input Field
        Expanded(
          flex: 3,
          child: NumberFormField(
            controller: controller,
            textAlign: TextAlign.end,
            decoration: CustomFieldStyles.kUnderlined(
              context,
              hinText: selectedModifier.type == RateModifierEnum.flat ? 'Ex: \$200' : 'Ex: 20%',
            ),
            inputFormatters: [
              if (selectedModifier.type == RateModifierEnum.flat) NumberFormField.defaultFormatter(),
              if (selectedModifier.type == RateModifierEnum.percent) RateSelectorFormField.percentFormatter(),
            ],
            onChanged: (v) => _handleTextFieldChange(context, v),
          ),
        )
      ],
    );
  }

  void _handleDropdownChange(RateModifierEnum? value) {
    final inputValue = controller.getNumber ?? 0;
    if ((value == RateModifierEnum.percent && inputValue > 100) ||
        (value == RateModifierEnum.flat && inputValue > baseAmount)) {
      controller.clear();
      return;
    }

    return onChanged?.call(_handleFieldsChanged(value!));
  }

  void _handleTextFieldChange(BuildContext context, String value) {
    final _inputValue = value.plainNumber;
    if (selectedModifier.type == RateModifierEnum.flat && _inputValue > baseAmount) {
      controller.clear();
      showCustomSnackBar(
        context,
        content: Text('Amount cannot be greater than total amount.'),
        customSnackBarType: CustomOverlayType.info,
      );
    }
    return onChanged?.call(
      _handleFieldsChanged(selectedModifier.type),
    );
  }

  RateModifierData _handleFieldsChanged(RateModifierEnum type) {
    final inputValue = controller.getNumber ?? 0;

    num calculatedDiscountAmount = (inputValue / baseAmount) * 100;
    num calculatedDiscountFlat = (inputValue * baseAmount) / 100;

    return RateModifierData(
      type: type,
      valueInFlat: type == RateModifierEnum.flat ? inputValue : calculatedDiscountFlat,
      valueInPercent: type == RateModifierEnum.percent ? inputValue : calculatedDiscountAmount,
    );
  }

  static TextInputFormatter percentFormatter({int decimalDigits = 2}) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      final regexPattern = RegExp(
        '^([0-9]{1,3})(\\.([0-9]{0,$decimalDigits}))?\$',
      );

      if (!regexPattern.hasMatch(newValue.text)) {
        return oldValue;
      }

      final numericValue = double.tryParse(newValue.text);
      if (numericValue == null || numericValue < 0 || numericValue > 100) {
        return oldValue;
      }

      if (newValue.text.contains('.')) {
        final parts = newValue.text.split('.');
        if (parts.length > 1 && parts[1].length > decimalDigits) {
          final truncatedDecimals = parts[1].substring(0, decimalDigits);
          final truncated = '${parts[0]}.$truncatedDecimals';
          return TextEditingValue(
            text: truncated,
            selection: TextSelection.collapsed(offset: truncated.length),
          );
        }
      }

      return newValue;
    });
  }
}

enum RateModifierEnum {
  flat(key: 'flat'),
  percent(key: 'percentage');

  final String key;
  String get label {
    return switch (this) {
      RateModifierEnum.flat => '\$',
      RateModifierEnum.percent => '%',
    };
  }

  String labelExt(BuildContext context) {
    return switch (this) {
      RateModifierEnum.flat => 'Fixed',
      RateModifierEnum.percent => 'Percentage',
    };
  }

  String? Function(String? value) get validator {
    return switch (this) {
      RateModifierEnum.flat => _flatValidator,
      RateModifierEnum.percent => _percentValidator,
    };
  }

  const RateModifierEnum({required this.key});

  String? _flatValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount.';
    }
    final parsedValue = value.plainNumber;
    if (parsedValue <= 0) {
      return 'Amount must be greater than 0.';
    }
    return null;
  }

  String? _percentValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a percentage.';
    }
    final parsedValue = value.plainNumber;
    if (parsedValue <= 0 || parsedValue > 100) {
      return 'Percentage must be between 1 and 100.';
    }
    return null;
  }

  static RateModifierEnum fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'flat' => RateModifierEnum.flat,
      'percentage' => RateModifierEnum.percent,
      _ => RateModifierEnum.flat,
    };
  }
}

class RateModifierData {
  final RateModifierEnum type;
  final num valueInPercent;
  final num valueInFlat;

  const RateModifierData({
    required this.type,
    this.valueInPercent = 0,
    this.valueInFlat = 0,
  });

  RateModifierData copyWith({
    RateModifierEnum? type,
    num? valueInPercent,
    num? valueInFlat,
  }) {
    return RateModifierData(
      type: type ?? this.type,
      valueInPercent: valueInPercent ?? this.valueInPercent,
      valueInFlat: valueInFlat ?? this.valueInFlat,
    );
  }

  @override
  String toString() {
    return '''
    RateModifierData(
      type: $type,
      valueInPercent: $valueInPercent, 
      valueInFlat: $valueInFlat
    )''';
  }
}

typedef RateSelectorFormFieldBuilder = Widget Function(
  BuildContext context,
  RateModifierData selectedModifier,
  ValueChanged<RateModifierEnum?> onModifierChanged,
  ValueChanged<String> onTextFieldChanged,
  TextEditingController controller,
);
