import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'chef_kot_order_report_view.dart';

@RoutePage()
class KotOrderReportView extends StatelessWidget implements AutoRouteWrapper {
  const KotOrderReportView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return this;
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return const ChefKotOrderReportView();
  }
}
