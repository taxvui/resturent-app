import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

export 'package:flutter/services.dart'
    show
        TextInputFormatter,
        FilteringTextInputFormatter,
        LengthLimitingTextInputFormatter;

class NumberFormField extends StatelessWidget {
  const NumberFormField({
    super.key,
    this.enabled,
    this.decoration,
    this.textAlign = TextAlign.start,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.maxLength = 16,
    this.decimalDigits = defaultDecimalDigits,
    this.onChanged,
  });

  final bool? enabled;
  final InputDecoration? decoration;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final String? Function(String? value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;
  final int decimalDigits;
  final void Function(String value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      focusNode: focusNode,
      decoration: decoration?.copyWith(counterText: ''),
      textAlign: textAlign,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalDigits > 0,
      ),
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters ?? [defaultFormatter()],
      maxLength: maxLength,
      onChanged: onChanged,
    );
  }

  static String? nonZeroRequired(
    String? value, {
    String? emptyErrorText,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: emptyErrorText),
      FormBuilderValidators.notZeroNumber(),
    ])(value);
  }

  static const int defaultDecimalDigits = 2;
  static TextInputFormatter defaultFormatter({
    int decimalDigits = defaultDecimalDigits,
  }) {
    {
      return TextInputFormatter.withFunction(
        (oldValue, newValue) {
          final text = newValue.text;
          if (text.isEmpty) return newValue;

          final regexPattern = decimalDigits > 0
              ? '^-?(\\d+)?(\\.\\d{0,$decimalDigits})?\$'
              : '^-?\\d+\$';
          final regex = RegExp(regexPattern);

          if (!regex.hasMatch(text)) {
            return oldValue;
          }

          if (decimalDigits > 0 && text.contains('.')) {
            final parts = text.split('.');
            if (parts.length > 1) {
              final decimals = parts[1];
              final truncatedDecimals = decimals.substring(
                0,
                math.min(decimalDigits, decimals.length),
              );
              final truncated = '${parts[0]}.$truncatedDecimals';
              return TextEditingValue(
                text: truncated,
                selection: TextSelection.collapsed(offset: truncated.length),
              );
            }
          }
          return newValue;
        },
      );
    }
  }
}

extension NumberEditingUtils on TextEditingController {
  num? get getNumber => num.tryParse(text.trim());

  void setNumber(num? value, {int decimal = 2}) {
    if (value == null) return;
    final _isInt = value.toInt() == value;

    text = value.toStringAsFixed(_isInt ? 0 : decimal);
  }
}
