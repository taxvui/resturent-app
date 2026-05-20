import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../core/core.dart';

@RoutePage()
class CongratulationView extends StatelessWidget {
  const CongratulationView({
    super.key,
    required this.nextRoute,
    this.replaceAll = false,
    this.title,
    this.description,
  });
  final PageRouteInfo<dynamic> nextRoute;
  final bool replaceAll;
  final String? title;
  final TextSpan? description;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 245,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        DAppImages.congratulationAvatar,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: SizedBox.square(
                        dimension: 32,
                        child: Image.asset(DAppImages.appIcon),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.square(dimension: 16),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 324),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? context.t.common.congratulation,
                      style: _theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox.square(dimension: 12),
                    Text.rich(
                      description ??
                          const TextSpan(
                            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris cras',
                          ),
                      textAlign: TextAlign.center,
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                    ),
                    SizedBox.square(dimension: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (replaceAll) {
                          context.router.replaceAll([nextRoute]);
                          return;
                        }

                        context.router.replace(nextRoute);
                        return;
                      },
                      child: Text(context.t.action.kContinue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
