import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final void Function(bool value)? onChanged;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Switch(
      value: value,
      onChanged: onChanged,
      inactiveTrackColor: _theme.colorScheme.secondary.withValues(alpha: 0.5),
      inactiveThumbColor: _theme.colorScheme.onPrimary,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}
