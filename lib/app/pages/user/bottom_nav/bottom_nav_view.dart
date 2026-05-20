import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../../../i18n/strings.g.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';
import '../../../routes/app_routes.gr.dart';
import 'components/components.export.dart';

@RoutePage()
class BottomNavView extends ConsumerStatefulWidget {
  const BottomNavView({super.key});

  @override
  ConsumerState<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends ConsumerState<BottomNavView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(
        subscriptionDialogProvider((context: context, callback: () => setState(() {}))),
      ),
    );

    final _theme = Theme.of(context);

    return BackButtonInvoker(
      showFloating: true,
      child: AutoTabsScaffold(
        scaffoldKey: scaffoldKey,
        animationDuration: Duration.zero,
        resizeToAvoidBottomInset: false,
        routes: [
          QuickOrderRoute(scaffoldKey: scaffoldKey),
          OrderListRoute(scaffoldKey: scaffoldKey),
          ItemListRoute(scaffoldKey: scaffoldKey),
          ReportListRoute(scaffoldKey: scaffoldKey),
          UserSettingsRoute(scaffoldKey: scaffoldKey),
        ],
        bottomNavigationBuilder: (_, tabsRouter) {
          return Theme(
            data: _theme.copyWith(
              splashColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              backgroundColor: _theme.colorScheme.primaryContainer,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  // label: 'Sales',
                  label: context.t.common.sales,
                  icon: Icon(FontAwesome.cart_arrow_down_solid),
                ),
                BottomNavigationBarItem(
                  // label: 'Orders',
                  label: context.t.common.orders,
                  icon: Icon(IconlyBold.document),
                ),
                BottomNavigationBarItem(
                  // label: 'Items',
                  label: context.t.common.items,
                  icon: Icon(Bootstrap.box_seam_fill),
                ),
                BottomNavigationBarItem(
                  // label: 'Reports',
                  label: context.t.common.reports,
                  icon: Icon(IconlyBold.chart),
                ),
                BottomNavigationBarItem(
                  // label: 'Profile',
                  label: context.t.common.profile,
                  icon: Icon(Bootstrap.person_circle),
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
