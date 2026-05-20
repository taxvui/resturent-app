import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part 'tabs/_all_income_list.dart';
part 'providers/_all_income_view_provider.dart';

part 'tabs/_income_category_list.dart';
part 'providers/_income_category_view_provider.dart';

@RoutePage()
class IncomeListView extends ConsumerWidget {
  const IncomeListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncome = ref.watch(allIncomeListViewProvider);
    final incomeCategory = ref.watch(incomeCategoryListViewProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        allIncome.initRefreshListener();
        incomeCategory.initRefreshListener();
      }
    });

    final _theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) {
          return Scaffold(
            appBar: CustomAppBar(title: Text(context.t.common.income)),
            body: Column(
              children: [
                ColoredBox(
                  color: _theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      ...[
                        ("all_income", context.t.pages.income.allIncome),
                        ("income_category", context.t.pages.income.incomeCategory),
                      ].map((entry) => Tab(text: entry.$2)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PermissionGate(
                        moduleKey: PMKeys.income,
                        fallback: PermissionGate.imageFallback(),
                        child: AllIncomeList(provider: allIncome),
                      ),
                      PermissionGate(
                        moduleKey: PMKeys.incomeCategory,
                        fallback: PermissionGate.imageFallback(),
                        child: IncomeCategoryList(provider: incomeCategory),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: ValueListenableBuilder<int>(
              valueListenable: TabChangeNotifier(
                DefaultTabController.of(tabContext),
              ),
              builder: (context, tabIndex, child) {
                final actions = [
                  () => context.router.push(ManageIncomeRoute()),
                  () => context.router.push(ManageIncomeCategoryRoute()),
                ];

                return PermissionGate(
                  moduleKey: [PMKeys.income, PMKeys.incomeCategory][tabIndex],
                  action: PermissionAction.create,
                  child: SizedBox(
                    height: 48,
                    child: FloatingActionButton.extended(
                      onPressed: actions[tabIndex],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      label: Text(
                        tabIndex == 1 ? '+ ${context.t.common.addCategory}' : '+ ${context.t.pages.income.addIncome}',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ).unfocusPrimary();
  }
}

class TabChangeNotifier extends ValueNotifier<int> {
  TabChangeNotifier(TabController? controller) : super(controller?.animation?.value.toInt() ?? 0) {
    controller?.animation?.addListener(
      () => value = (controller.animation?.value.round() ?? 0).clamp(
        0,
        controller.length,
      ),
    );
  }
}
