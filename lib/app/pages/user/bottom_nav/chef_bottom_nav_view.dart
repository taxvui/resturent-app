import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../routes/app_routes.gr.dart';
import '../../../widgets/widgets.dart';
import 'components/components.export.dart';

@RoutePage()
class ChefBottomNavView extends ConsumerStatefulWidget {
  const ChefBottomNavView({super.key});

  @override
  ConsumerState<ChefBottomNavView> createState() => _ChefBottomNavViewState();
}

class _ChefBottomNavViewState extends ConsumerState<ChefBottomNavView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(subscriptionDialogProvider((context: context, callback: null))),
    );

    final _theme = Theme.of(context);

    return BackButtonInvoker(
      showFloating: true,
      child: AutoTabsScaffold(
        scaffoldKey: scaffoldKey,
        animationDuration: Duration.zero,
        resizeToAvoidBottomInset: false,
        routes: [
          KitchenListRoute(scaffoldKey: scaffoldKey),
          KotListRoute(scaffoldKey: scaffoldKey),
          ChefKotOrderReportRoute(scaffoldKey: scaffoldKey),
          UserSettingsRoute(scaffoldKey: scaffoldKey),
        ],
        bottomNavigationBuilder: (_, tabsRouter) {
          return Theme(
            data: _theme.copyWith(splashColor: Colors.transparent),
            child: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              backgroundColor: _theme.colorScheme.primaryContainer,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  label: context.t.common.kitchen(n: 2),
                  icon: const Icon(HugeIconsSolid.kitchenUtensils),
                ),
                BottomNavigationBarItem(
                  label: context.t.common.orders,
                  icon: const Icon(FontAwesome.cart_arrow_down_solid),
                ),
                BottomNavigationBarItem(
                  label: context.t.common.reports,
                  icon: const Icon(IconlyBold.chart),
                ),
                BottomNavigationBarItem(
                  label: context.t.common.profile,
                  icon: const Icon(Bootstrap.person_circle),
                ),
              ],
            ),
          );
        },
        drawer: NavigationDrawerBuilder(scaffoldKey: scaffoldKey),
      ),
    );
  }
}
