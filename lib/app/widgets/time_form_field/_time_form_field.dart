import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeFormField extends StatelessWidget {
  const TimeFormField({
    super.key,
    this.controller,
    this.decoration,
    this.style,
    this.validator,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return TextFormField(
      style: style,
      controller: controller,
      readOnly: true,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        suffixIcon:
            decoration?.suffixIcon ??
            Icon(
              Icons.access_time,
              color: _theme.colorScheme.secondary,
            ),
      ),
      onTap: () => handleTimePicker(context),
      validator: validator,
    );
  }

  Future<void> handleTimePicker(BuildContext context) async {
    final _initialTime = parseTime(controller?.text) ?? TimeOfDay.now();

    final _result = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );

    if (_result != null) {
      final _now = DateTime.now();
      final _dateTime = DateTime(
        _now.year,
        _now.month,
        _now.day,
        _result.hour,
        _result.minute,
      );
      controller?.text = DateFormat.jm().format(_dateTime);
    }
  }

  TimeOfDay? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      final dateTime = DateFormat.jm().parse(timeString);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      return null;
    }
  }
}
