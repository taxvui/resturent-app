import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';

class PaymentStatusView extends StatelessWidget {
  const PaymentStatusView({
    super.key,
    required this.status,
    required this.onPressed,
  });
  final PaymentStatusViewType status;

  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Splash Icon
                Align(
                  child: SizedBox.square(
                    dimension: 170,
                    child: Lottie.asset(
                      status.imagePath,
                      renderCache: RenderCache.raster,
                      repeat: status != PaymentStatusViewType.success,
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 50),

                // Title
                Text(
                  status.title,
                  style: _theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: status.colorScheme,
                  ),
                ),
                const SizedBox.square(dimension: 12),

                // Description
                Text(
                  status.description,
                  textAlign: TextAlign.center,
                  style: _theme.textTheme.titleLarge?.copyWith(
                    color: _theme.colorScheme.secondary,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(status.actionButtonText),
        ),
      ).fMarginLTRB(24, 16, 24, 16),
    );
  }
}

class PaymentStatusViewType {
  final String imagePath;
  final Widget? centerIcon;
  final String actionButtonText;
  final String title;
  final String description;
  final Color? colorScheme;

  const PaymentStatusViewType._({
    required this.imagePath,
    this.centerIcon,
    required this.actionButtonText,
    required this.title,
    required this.description,
    this.colorScheme,
  });

  static PaymentStatusViewType success = PaymentStatusViewType._(
    imagePath: DAppImages.splashDropLottie(isSuccess: true),
    centerIcon: Icon(Bootstrap.check_lg, size: 34, color: Colors.white),
    // actionButtonText: 'View Invoice',
    actionButtonText: t.pages.paymentStatus.success.actionButtonText,
    // title: 'Thank You!',
    title: t.pages.paymentStatus.success.title,
    // description: 'We will review the payment & approve it within 24 hours.',
    description: t.pages.paymentStatus.success.message,
    colorScheme: DAppColors.kPrimary,
  );

  static PaymentStatusViewType fail = PaymentStatusViewType._(
    imagePath: DAppImages.splashDropLottie(isSuccess: false),
    centerIcon: Icon(Bootstrap.exclamation_lg, size: 34, color: Colors.white),
    // actionButtonText: 'Try Again',
    actionButtonText: t.pages.paymentStatus.fail.actionButtonText,
    // title: 'Oops! Payment Failed',
    title: t.pages.paymentStatus.fail.title,
    // description: 'Your transaction has failed due to some technical error.',
    description: t.pages.paymentStatus.fail.message,
    colorScheme: DAppColors.kError,
  );

  factory PaymentStatusViewType.custom({
    required String imagePath,
    Widget? centerIcon,
    required String actionButtonText,
    required String title,
    required String description,
    Color? colorScheme,
  }) {
    return PaymentStatusViewType._(
      imagePath: imagePath,
      centerIcon: centerIcon,
      actionButtonText: actionButtonText,
      title: title,
      description: description,
      colorScheme: colorScheme,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentStatusViewType) return false;

    return imagePath == other.imagePath && centerIcon == other.centerIcon && actionButtonText == other.actionButtonText && title == other.title && description == other.description;
  }

  @override
  int get hashCode {
    return imagePath.hashCode ^ centerIcon.hashCode ^ actionButtonText.hashCode ^ title.hashCode ^ description.hashCode;
  }
}
