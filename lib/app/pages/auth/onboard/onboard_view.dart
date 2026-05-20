import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/core.dart';
import '../../../../app/services/services.dart';
import '../../../routes/app_routes.gr.dart';
import '../../../widgets/widgets.dart';

part '_onboard_view_provider.dart';
part 'data/onboard_data.dart';

@RoutePage()
class OnboardView extends ConsumerStatefulWidget {
  const OnboardView({super.key});

  @override
  ConsumerState<OnboardView> createState() => _OnboardViewState();
}

class _OnboardViewState extends ConsumerState<OnboardView> {
  late final PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final obProv = ref.read(onboardProvider.notifier);
    final _current = ref.watch(onboardProvider);
    final _isLast = obProv.obCount == (_current + 1);

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          Text.rich(
            TextSpan(
              text: context.t.action.skip,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  return await _completeTour(context, obProv);
                },
            ),
            style: _theme.textTheme.bodyMedium?.copyWith(
              color: _theme.colorScheme.onPrimaryContainer,
            ),
          ).fMarginOnly(right: 24),
        ],
      ),
      body: Column(
        children: [
          // App Icon
          Center(
            child: Image.asset(
              DAppImages.appIcon,
              height: 64,
              width: 64,
            ),
          ),
          SizedBox.square(dimension: 16),

          // Onboard Slider
          Flexible(
            child: PageView.builder(
              controller: controller,
              onPageChanged: obProv.updateIndex,
              itemCount: obProv.obCount,
              itemBuilder: (_, index) {
                final _obItem = obProv.obData[index];
                return Column(
                  children: [
                    // Overview Text
                    Text(
                      _obItem.title,
                      textAlign: TextAlign.center,
                      style: _theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox.square(dimension: 8),
                    Text(
                      _obItem.description,
                      textAlign: TextAlign.center,
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        color: _theme.colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox.square(dimension: 40),

                    // Onboard Image
                    Flexible(
                      child: AspectRatio(
                        aspectRatio: 1.fScaleFactor,
                        child: Image.asset(_obItem.imagePath),
                      ),
                    ),
                  ],
                ).fMarginSymmetric(horizontal: 16);
              },
            ),
          ),
          SizedBox.square(dimension: 30),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              obProv.obCount,
              (index) {
                final _isActive = _current == index;
                return Container(
                  height: 8,
                  width: (_isActive ? 20 : 8),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _isActive ? _theme.colorScheme.primary : null,
                    border: _isActive ? null : Border.all(color: _theme.colorScheme.primary),
                  ),
                );
              },
            ),
          ),
          SizedBox.square(dimension: 30),

          // Action Button
          ElevatedButton(
            onPressed: () async {
              if (!_isLast) {
                return await controller.nextPage(
                  duration: Durations.medium4,
                  curve: Curves.linearToEaseOut,
                );
              }

              await _completeTour(context, obProv);
            },
            child: Text(
              _isLast ? context.t.action.getStarted : context.t.action.next,
            ),
          ).fMarginSymmetric(horizontal: 16),
          SizedBox.square(dimension: 30),
        ],
      ),
    );
  }

  Future<void> _completeTour(BuildContext context, OnboardViewNotifier obProv) async {
    final _result = await obProv.saveTour();

    if (context.mounted) {
      if (!_result) {
        showCustomSnackBar(
          context,
          // content: const Text('Something went wrong, please try again'),
          content: Text(context.t.exceptions.somethingWentWrong),
          customSnackBarType: CustomOverlayType.error,
        );

        return;
      }
      context.router.replaceAll([const SignInRoute()]);
    }
  }
}
