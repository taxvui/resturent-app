import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';
import '../../../routes/app_routes.gr.dart';

part '_sign_in_view_provider.dart';

@RoutePage()
class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  @override
  void initState() {
    super.initState();
    ref.read(signinProvider).handleRememberMe();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(signinProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            centerTitle: true,
            title: Text(context.t.common.signIn),
          ),
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox.square(dimension: 40),
                  SizedBox.square(
                    dimension: 64,
                    child: Image.asset(DAppImages.appIcon),
                  ),
                  SizedBox.square(dimension: 30),

                  Text(
                    // 'Welcome Back',
                    context.t.pages.signIn.title,
                    style: _theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox.square(dimension: 8),
                  Text(
                    context.t.pages.signIn.subtitle,
                    textAlign: TextAlign.center,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      color: _theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox.square(dimension: 30),

                  // Email Field
                  TextFormField(
                    controller: controller.emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: context.t.form.email.label,
                      hintText: context.t.form.email.label,
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

                  // Password Field
                  TextFormField(
                    controller: controller.passwordController,
                    textInputAction: TextInputAction.done,
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

                      return null;
                    },
                  ),
                  const SizedBox.square(dimension: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me
                      Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: SizedBox.fromSize(
                                size: Size.square(20),
                                child: Checkbox(
                                  value: controller.rememberMe,
                                  onChanged: controller.toggleRememberMe,
                                ),
                              ).fMarginOnly(right: 8),
                            ),
                            TextSpan(
                              text: context.t.pages.signIn.extra.rememberMe,
                              recognizer: TapGestureRecognizer()..onTap = controller.toggleRememberMe,
                            ),
                          ],
                        ),
                      ),

                      Text.rich(
                        TextSpan(
                          text: context.t.pages.signIn.extra.forgotPassword,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.router.push(
                                const ForgotPasswordRoute(),
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox.square(dimension: 20),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: () async {
                      if (FormWrapper.validate(formContext)) {
                        return await handleFormSubmit(context);
                      }
                    },
                    child: Text(context.t.action.signIn),
                  ),
                  const SizedBox.square(dimension: 20),

                  // Sign Up Navigator
                  Text.rich(
                    context.t.pages.signIn.extra.signUpNavigator(
                      getStarted: (getStarted) {
                        return TextSpan(
                          text: getStarted,
                          style: TextStyle(
                            color: _theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.router.push(const SignUpRoute());
                            },
                        );
                      },
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
    final controller = ref.read(signinProvider);

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: controller.handleSignIn,
    );

    if (context.mounted) {
      if (_result.isFailure) {
        if (_result.left == HttpStatus.created.toString()) {
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
                  email: controller.emailController.text,
                ),
              );
            },
          );

          _modalResult.whenComplete(() async {
            final _email = controller.emailController.text;
            if (context.mounted) {
              context.router.push(
                OtpVerificationRoute(
                  email: _email,
                  nextRoute: MuteHomeRoute(),
                  replaceAllRoutes: true,
                  saveToken: true,
                ),
              );
            }
          });

          return;
        }

        showCustomSnackBar(
          context,
          content: Text(_result.left!),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }
      return context.router.replacePath<void>('/mute-home');
    }
  }
}
