import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../widgets/widgets.dart';

import '../../../data/repository/repository.dart';

part '_otp_verification_view_provider.dart';

@RoutePage()
class OtpVerificationView extends ConsumerStatefulWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
    required this.nextRoute,
    this.replaceAllRoutes = false,
    this.saveToken = false,
  });
  final String email;
  final PageRouteInfo<dynamic> nextRoute;
  final bool replaceAllRoutes;
  final bool? saveToken;
  @override
  ConsumerState<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends ConsumerState<OtpVerificationView> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(otpViewProvider);
    final _theme = Theme.of(context);

    final _basePinFieldTheme = PinTheme(
      height: 50,
      width: 46,
      decoration: BoxDecoration(
        border: Border.all(color: _theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: _theme.textTheme.headlineSmall?.copyWith(fontSize: 20),
    );

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            title: Text(context.t.common.verifyEmail),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    // 'Verifications',
                    context.t.pages.otpVerification.title,
                    style: _theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox.square(dimension: 8),
                  Text.rich(
                    TextSpan(
                      text: '${context.t.pages.otpVerification.subtitle}: ',
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            color: _theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: _theme.colorScheme.secondary,
                    ),
                  ),
                  SizedBox.square(dimension: 30),

                  // OTP Field
                  Pinput(
                    length: 6,
                    controller: controller.otpController,
                    defaultPinTheme: _basePinFieldTheme,
                    focusedPinTheme: _basePinFieldTheme.copyDecorationWith(
                      border: Border.all(color: _theme.colorScheme.primary),
                      color: _theme.colorScheme.primary.withValues(alpha: 0.175),
                    ),
                    errorPinTheme: _basePinFieldTheme.copyDecorationWith(
                      border: Border.all(color: _theme.inputDecorationTheme.errorStyle?.color ?? Colors.red),
                      color: (_theme.inputDecorationTheme.errorStyle?.color ?? Colors.red).withValues(alpha: 0.275),
                    ),
                    forceErrorState: controller.fieldErrors['otp_field'] != null,
                    errorText: controller.fieldErrors['otp_field'],
                    errorBuilder: (errorText, pin) {
                      return Text(
                        errorText ?? '',
                        style: _theme.inputDecorationTheme.errorStyle,
                      ).fMarginOnly(top: 8);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the otp.';
                      }
                      if (value.length < 6) {
                        return 'Please enter corrent otp.';
                      }
                      return null;
                    },
                  ),
                  SizedBox.square(dimension: 16),

                  // Resent Button
                  Align(
                    child: StreamBuilder(
                      stream: controller.resendDelayInSeconds,
                      builder: (context, sn) {
                        final _time = sn.data ?? 0;
                        final _minutes = (_time ~/ 60);
                        final _seconds = (_time % 60);

                        return Text.rich(
                          TextSpan(
                            text:
                                '${context.t.pages.otpVerification.extra.codeResend.codeSendIn} ${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                            children: [
                              if (_minutes < 1)
                                TextSpan(
                                  text: ' ${context.t.pages.otpVerification.extra.codeResend.resendCode}',
                                  style: TextStyle(
                                    color: _theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()..onTap = () => _handleResendButton(context),
                                ),
                            ],
                          ),
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            color: _theme.colorScheme.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox.square(dimension: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      if (FormWrapper.validate(formContext)) {
                        return await handleFormSubmit(context);
                      }
                    },
                    child: Text(context.t.action.verify),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    final controller = ref.read(otpViewProvider);

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () {
        return controller.handleOTPSubmit(
          widget.email,
          saveToken: widget.saveToken,
        );
      },
    );

    if (_result.isSuccess) {
      if (widget.saveToken != null) {
        await controller._repo.getUser();
      }

      if (context.mounted) {
        if (widget.replaceAllRoutes) {
          return context.router.replaceAll([widget.nextRoute]);
        }

        return context.router.replace<void>(widget.nextRoute);
      }
    }
  }

  Future<void> _handleResendButton(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref
          .read(otpViewProvider)
          .handleOTPResend(
            widget.email,
          ),
    );
    if (_result == null) return;

    if (context.mounted) {
      showCustomSnackBar(
        context,
        content: Text(_result.left ?? _result.right ?? ''),
        customSnackBarType: _result.isSuccess ? CustomOverlayType.success : CustomOverlayType.info,
      );
    }
  }
}
