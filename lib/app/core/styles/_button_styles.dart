import 'package:flutter/material.dart';

import '../core.dart';

abstract class CustomButtonStyles {
  static ButtonStyle destructiveOutline({
    Color? borderColor,
    Color? foregroundColor,
  }) {
    final _color = borderColor ?? Colors.red;

    return OutlinedButton.styleFrom(
      side: BorderSide(
        color: _color,
        strokeAlign: BorderSide.strokeAlignInside,
        width: 1.25,
      ),
      foregroundColor: foregroundColor ?? _color,
    );
  }

  static ButtonStyle themedOutlinedFilled(
    BuildContext context, {
    bool isFilled = false,
  }) {
    final _theme = Theme.of(context);
    return IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      minimumSize: const Size.square(48),
      backgroundColor: isFilled
          ? _theme.colorScheme.primary.withValues(alpha: 0.0725)
          : null,
      foregroundColor:
          isFilled ? _theme.colorScheme.primary : _theme.paragraphColor,
      side: isFilled
          ? null
          : BorderSide(
              color: _theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
    ).copyWith(
      textStyle: WidgetStateProperty.all(
        _theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
