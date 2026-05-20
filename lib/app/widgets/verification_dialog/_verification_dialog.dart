import 'package:flutter/material.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';

class VerificationDialog extends StatelessWidget {
  const VerificationDialog({
    super.key,
    this.title,
    this.description,
    this.email,
  });
  final String? title;
  final TextSpan? description;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? context.t.prompt.verify.title,
            style: _theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox.square(dimension: 8),
          Text.rich(
            description ??
                context.t.prompt.verify.description(
                  emailSpan: email == null
                      ? TextSpan(text: '.')
                      : TextSpan(
                          text: context.t.common.to,
                          children: [
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                color: _theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
            textAlign: TextAlign.center,
            style: _theme.textTheme.bodyLarge?.copyWith(
              color: _theme.colorScheme.secondary,
            ),
          ),
        ],
      ).fMarginAll(24),
    );
  }
}
