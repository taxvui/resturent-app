import 'package:flutter/material.dart';

import '../../core/core.dart';

class SelectedButton extends StatelessWidget {
  const SelectedButton({
    super.key,
    required this.isSelected,
    this.onPressed,
    this.minimumSize = const Size.fromWidth(120),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.child,
  }) : _isOutlined = false;

  const SelectedButton.outlined({
    super.key,
    required this.isSelected,
    this.onPressed,
    this.minimumSize = const Size.fromWidth(120),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.child,
  }) : _isOutlined = true;

  final bool isSelected;
  final VoidCallback? onPressed;
  final Size minimumSize;
  final EdgeInsetsGeometry padding;
  final Widget child;

  final bool _isOutlined;

  @override
  Widget build(BuildContext context) {
    final filledStyle = FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      minimumSize: minimumSize,
      padding: padding,
    );

    final outlinedStyle = CustomButtonStyles.themedOutlinedFilled(
      context,
      isFilled: _isOutlined && isSelected,
    ).copyWith(
      minimumSize: WidgetStateProperty.all(minimumSize),
      padding: WidgetStateProperty.all(padding),
    );

    if (_isOutlined || !isSelected) {
      return OutlinedButton(
        onPressed: onPressed,
        style: outlinedStyle,
        child: child,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: filledStyle,
      child: child,
    );
  }
}
