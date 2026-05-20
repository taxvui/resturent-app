import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';

@RoutePage()
class CouponListView extends ConsumerWidget {
  const CouponListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _theme = Theme.of(context);

    final tabs = [
      ('upcoming', 'Upcoming'),
      ('available', 'Available'),
      ('expired', 'Expired'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (tabContext) {
          return Scaffold(
            appBar: CustomAppBar(
              title: const Text('Coupon'),
            ),
            body: Column(
              children: [
                // Tabbar
                ColoredBox(
                  color: _theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [...tabs.map((entry) => Tab(text: entry.$2))],
                  ),
                ),

                // Tabbar View
                Expanded(
                  child: TabBarView(
                    children: List.generate(
                      tabs.length,
                      (tabIndex) {
                        return CouponListWidget(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 72),
                          filter: tabs[tabIndex].$1,
                          cardActionBuilder:
                              tabIndex ==
                                  2 // Means Expired
                              ? null
                              : (context, data) {
                                  return PopupMenuButton<String>(
                                    itemBuilder: (context) {
                                      return [
                                        if (ref.can(PMKeys.coupon, action: PermissionAction.update)) ...[
                                          ("Edit", 'edit'),
                                        ],
                                        if (ref.can(PMKeys.coupon, action: PermissionAction.delete)) ...[
                                          ("Delete", 'delete'),
                                        ],
                                      ].map((menu) {
                                        return PopupMenuItem<String>(
                                          value: menu.$2,
                                          child: Text(menu.$1),
                                        );
                                      }).toList();
                                    },
                                    onSelected: (v) async {
                                      return switch (v) {
                                        'edit' => _handleEdit(context, data),
                                        'delete' => _handleDelete(
                                          context,
                                          () => ref.read(couponRepoProvider).deleteCoupon(data.id!),
                                        ),
                                        _ => null,
                                      };
                                    },
                                    child: const Icon(Icons.more_vert, size: 20),
                                  );
                                },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: SizedBox(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  return await context.router.push<void>(
                    ManageCouponRoute(),
                  );
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                label: const Text('+ Add Coupon'),
              ),
            ).can(PMKeys.coupon, action: PermissionAction.create),
          );
        },
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context, CouponModel data) async {
    return await context.router.push<void>(
      ManageCouponRoute(editModel: data),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: 'Do you want to delete this coupon?',
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(callback),
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
      }
    }
  }
}
