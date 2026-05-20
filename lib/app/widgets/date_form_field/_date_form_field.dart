import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

import '../../core/core.dart';

class DateFormField extends StatelessWidget {
  const DateFormField({
    super.key,
    this.controller,
    this.decoration,
    this.style,
    this.dateFormat,
    this.validator,
  });
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final CustomDateFormat? dateFormat;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return TextFormField(
      style: style,
      controller: controller,
      readOnly: true,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        suffixIcon: decoration?.suffixIcon ??
            Icon(
              IconlyLight.calendar,
              color: _theme.colorScheme.secondary,
            ),
      ),
      onTap: () async => await _handleDatePicker(context),
      validator: validator,
    );
  }

  Future<void> _handleDatePicker(BuildContext context) async {
    DateTime? _initialDate = DateTime.now();
    if (controller?.text != null && controller!.text.isNotEmpty) {
      _initialDate = controller!.text.parseDate;
    }

    final _result = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime(2001),
      lastDate: DateTime(2034),
    );

    if (_result != null) {
      controller?.text = DateFormat(
        dateFormat?.pattern ?? 'dd MMM, yyyy',
      ).format(_result);
    }
  }
}

typedef CustomDateFormat = DateFormat;
