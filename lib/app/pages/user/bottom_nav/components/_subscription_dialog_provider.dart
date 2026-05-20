import 'package:auto_route/auto_route.dart';
import 'package:fdevs_pops/fdevs_pops.dart';
import 'package:flutter/material.dart';

import '../../../../data/repository/repository.dart';
import '../../../../routes/app_routes.gr.dart';

final subscriptionDialogProvider = FutureProvider.autoDispose
    .family<void, ({BuildContext context, VoidCallback? callback})>(
      (ref, params) async {
        final _user = ref.read(userRepositoryProvider).valueOrNull;

        if (_user?.isPlanExpired != true) return;

        final _currentName = params.context.router.current.name;
        final _isOnBottomNav = _currentName == BottomNavRoute.name || _currentName == ChefBottomNavRoute.name;

        if (!_isOnBottomNav || !params.context.mounted) return;

        return await FPops.I.showDialog<void>(
          id: 'subscription_dialog',
          barrierDismissible: false,
          builder: (popContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Subscription Expired!'),
              content: const Text('Please subscribe to continue.'),
              actionsPadding: const EdgeInsets.all(12),
              actions: [
                TextButton(
                  onPressed: () async {
                    while (FPops.I.isOverlayOpen('subscription_dialog')) {
                      FPops.I.dismiss('subscription_dialog');
                    }

                    if (!params.context.mounted) return;

                    await params.context.router.push<void>(
                      const SubscriptionPlanListRoute(),
                    );

                    return params.callback?.call();
                  },
                  child: const Text('Subscribe'),
                ),
              ],
            );
          },
        );
      },
    );
