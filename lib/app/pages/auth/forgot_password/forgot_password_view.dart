import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../routes/app_routes.gr.dart';
import '../../../widgets/widgets.dart';

part '_forgot_password_view_provider.dart';

@RoutePage()
class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(forgotPasswordProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            title: Text(context.t.common.forgotPassword),
          ),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    context.t.pages.forgotPassword.title,
                    style: _theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox.square(dimension: 8),
                  Text(
                    context.t.pages.forgotPassword.subtitle,
                    textAlign: TextAlign.center,
                    style: _theme.textTheme.bodyLarge,
                  ),
                  const SizedBox.square(dimension: 30),

                  // Email Field
                  TextFormField(
                    controller: controller.emailController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: context.t.form.email.label,
                      hintText: context.t.form.email.hint,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t.form.email.errors.required;
                      }
                      if (!value.isEmail) {
                        return context.t.form.email.errors.invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox.square(dimension: 20),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: () async {
                      if (FormWrapper.validate(formContext)) {
                        return await handleFormSubmit(context);
                      }
                    },
                    child: Text(context.t.action.kContinue),
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
    final controller = ref.read(forgotPasswordProvider);

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: controller.handleForgotPassword,
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
            child: VerificationDialog(email: controller.emailController.text),
          );
        },
      );

      _modalResult.whenComplete(() async {
        final _email = controller.emailController.text;
        if (context.mounted) {
          context.router.push(
            OtpVerificationRoute(
              email: _email,
              nextRoute: ResetPasswordRoute(email: _email),
            ),
          );
        }
      });
    }
  }
}
