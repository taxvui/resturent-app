import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../routes/app_routes.gr.dart';
import '../../../widgets/widgets.dart';

part '_reset_password_view_provider.dart';

@RoutePage()
class ResetPasswordView extends ConsumerStatefulWidget {
  const ResetPasswordView({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(resetPasswordProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            title: Text(context.t.common.createNewPassword),
          ),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    context.t.pages.resetPassword.title,
                    style: _theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox.square(dimension: 8),
                  Text(
                    context.t.pages.resetPassword.subtitle,
                    textAlign: TextAlign.center,
                    style: _theme.textTheme.bodyLarge,
                  ),
                  const SizedBox.square(dimension: 30),

                  // Password Field
                  TextFormField(
                    controller: controller.passwordController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: controller.obscurePassword,
                    decoration: InputDecoration(
                      labelText: context.t.form.password.label,
                      hintText: context.t.form.password.hint,
                      suffixIcon: IconButton(
                        onPressed: controller.toggleObscure,
                        color: _theme.colorScheme.outline,
                        icon: Icon(
                          controller.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t.form.password.errors.required;
                      }

                      if (value.length < 6) {
                        return context.t.form.password.errors.minLength(count: 6);
                      }

                      return null;
                    },
                  ),
                  const SizedBox.square(dimension: 16),

                  // Confirm Password
                  TextFormField(
                    controller: controller.confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: controller.obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: context.t.form.confirmPassword.label,
                      hintText: context.t.form.confirmPassword.hint,
                      suffixIcon: IconButton(
                        onPressed: () => controller.toggleObscure(true),
                        color: _theme.colorScheme.outline,
                        icon: Icon(
                          controller.obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t.form.confirmPassword.errors.required;
                      }
                      if (controller.passwordController.text != value) {
                        return context.t.form.confirmPassword.errors.invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox.square(dimension: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () async {
                      if (FormWrapper.validate(formContext)) {
                        return await handleFormSubmit(context);
                      }
                    },
                    child: Text(
                      context.t.action.kContinue,
                    ),
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
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref
          .read(resetPasswordProvider)
          .handleResetPassword(
            widget.email,
          ),
    );

    if (context.mounted) {
      if (_result.isFailure) {
        showCustomSnackBar(
          context,
          content: Text(_result.left!),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }

      final _modalResult = showCustomDialog(
        context: context,
        builder: (popContext) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (popContext.mounted) {
              Navigator.of(popContext).pop();
            }
          });
          return PopScope(
            canPop: false,
            child: VerificationDialog(
              title: 'Changed successfully!',
              description: TextSpan(
                text: 'Sign in with your new password.\n Redirecting you to Sign In...',
              ),
            ),
          );
        },
      );

      _modalResult.whenComplete(() async {
        if (context.mounted) {
          context.router.replaceAll([const SignInRoute()]);
        }
      });
    }
  }
}
