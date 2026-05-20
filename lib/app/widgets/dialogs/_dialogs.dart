import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import '../../../i18n/strings.g.dart';

import '../../core/core.dart';

enum InfoDialogIconType { static, splashSuccess, splashError }

class InfoDialog extends StatelessWidget {
  const InfoDialog._({
    super.key,
    required this.iconType,
    this.icon,
    required this.title,
    this.description,
    this.buttonText,
    this.onPressed,
    required this.hasConfirmation,
    this.acceptionText,
    this.rejectionText,
    this.swapAction,
    this.onDecide,
  });
  final InfoDialogIconType iconType;
  final IconData? icon;
  final String title;
  final String? description;
  final String? buttonText;
  final void Function()? onPressed;

  final bool hasConfirmation;
  final String? acceptionText;
  final String? rejectionText;
  final bool? swapAction;
  final void Function(bool value)? onDecide;

  const InfoDialog.info({
    Key? key,
    InfoDialogIconType iconType = InfoDialogIconType.static,
    IconData? icon,
    required String title,
    String? description,
    String? buttonText,
    void Function()? onPressed,
  }) : this._(
         key: key,
         iconType: iconType,
         icon: icon,
         title: title,
         description: description,
         buttonText: buttonText,
         onPressed: onPressed,
         hasConfirmation: false,
       );

  const InfoDialog.confirmation({
    Key? key,
    InfoDialogIconType iconType = InfoDialogIconType.static,
    IconData? icon,
    required String title,
    String? description,
    String? acceptionText,
    String? rejectionText,
    void Function(bool value)? onDecide,
    bool swapAction = false,
  }) : this._(
         key: key,
         iconType: iconType,
         icon: icon,
         title: title,
         description: description,
         acceptionText: acceptionText,
         rejectionText: rejectionText,
         onDecide: onDecide,
         hasConfirmation: true,
         swapAction: swapAction,
       );

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _confirmationAction = [
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => onDecide?.call(false),
            style: CustomButtonStyles.destructiveOutline(),
            child: Text(rejectionText ?? context.t.action.no),
          ),
        ),
      ),
      const SizedBox.square(dimension: 16),
      Expanded(
        child: SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: () => onDecide?.call(true),
            child: Text(acceptionText ?? context.t.action.yes),
          ),
        ),
      ),
    ];

    final _icon = Icon(
      icon ?? IconlyBold.info_circle,
      size: 34,
      color: _theme.colorScheme.onPrimary,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconType != InfoDialogIconType.static)
            Container(
              alignment: const Alignment(0, 0.195),
              constraints: BoxConstraints.tight(const Size.square(124)),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    DAppImages.splashDrop(
                      isSuccess: iconType != InfoDialogIconType.splashError,
                    ),
                  ),
                ),
              ),
              child: _icon,
            )
          else
            Container(
              constraints: BoxConstraints.tight(const Size.square(64)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _theme.colorScheme.primary,
                border: Border.all(
                  color: _theme.colorScheme.primary.withValues(alpha: 0.25),
                  width: 6,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: _icon,
            ),

          const SizedBox.square(dimension: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (description != null) ...[
            const SizedBox.square(dimension: 8),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: _theme.textTheme.bodyLarge?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
          ],
          const SizedBox.square(dimension: 24),

          // Action Button
          if (hasConfirmation)
            Row(
              children: [...(swapAction! ? _confirmationAction.reversed : _confirmationAction)],
            )
          else
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonText ?? context.t.action.okay),
              ),
            ),
        ],
      ).fMarginSymmetric(horizontal: 16, vertical: 24),
    );
  }
}

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({
    super.key,
    required this.onTryAgain,
  });
  final void Function()? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        constraints: const BoxConstraints.tightFor(
          width: double.maxFinite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 124,
              child: Image.asset(DAppImages.noInternet),
            ),
            const SizedBox.square(dimension: 8),
            Text(
              context.t.prompt.checkInternet.title,
              style: _theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox.square(dimension: 8),
            Text(
              context.t.prompt.checkInternet.message,
              textAlign: TextAlign.center,
              style: _theme.textTheme.bodyMedium?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
            const SizedBox.square(dimension: 16),
            ElevatedButton(
              onPressed: onTryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD2D2D2).withValues(alpha: 0.5),
                foregroundColor: _theme.colorScheme.onPrimaryContainer,
              ),
              child: Text(context.t.action.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class BackButtonInvoker extends StatefulWidget {
  const BackButtonInvoker({
    super.key,
    required this.child,
    this.showFloating = false,
  });

  final Widget child;
  final bool showFloating;

  @override
  State<BackButtonInvoker> createState() => _BackButtonInvokerState();
}

class _BackButtonInvokerState extends State<BackButtonInvoker> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final _now = DateTime.now();

        if (_lastBackPressTime == null || _now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = _now;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              CustomSnackBar(
                content: const Text('Press back again to exit.'),
                behavior: widget.showFloating ? SnackBarBehavior.floating : null,
                backgroundColor: CustomOverlayType.info.backgroundColor,
              ),
            );
        } else {
          return SystemNavigator.pop(animated: true);
        }
      },
      child: widget.child,
    );
  }
}
