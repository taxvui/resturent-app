import 'package:flutter/material.dart';

abstract class RetryButtons {
  // Text Span
  static TextSpan inlineText(
    Object error, {
    required void Function() onRetry,
    String? buttonText,
    Widget? icon,
  }) {
    return TextSpan(
      text: error.toString(),
      children: [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: TextButton.icon(
            onPressed: onRetry,
            label: Text(buttonText ?? 'Retry'),
            icon: icon ?? const Icon(Icons.refresh),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2),
              visualDensity: const VisualDensity(
                horizontal: -4,
                vertical: -4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ScrollView
  static Column scrollView(
    Object error, {
    required void Function() onRetry,
    Widget Function(Object error)? builder,
    String? buttonText,
    Widget? icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        builder?.call(error) ??
            Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
        TextButton.icon(
          onPressed: onRetry,
          icon: icon ?? const Icon(Icons.refresh),
          label: Text(buttonText ?? 'Retry'),
        ),
      ],
    );
  }
}
