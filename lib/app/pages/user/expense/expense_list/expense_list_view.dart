import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part 'tabs/_all_expense_list.dart';
part 'providers/_all_expense_view_provider.dart';

part 'tabs/_expense_category_list.dart';
part 'providers/_expense_category_view_provider.dart';

@RoutePage()
class ExpenseListView extends ConsumerWidget {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpense = ref.watch(allExpenseListViewProvider);
    final expenseCategory = ref.watch(expenseCategoryListViewProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        allExpense.initRefreshListener();
        expenseCategory.initRefreshListener();
      }
    });

    final _theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (tabContext) {
          return Scaffold(
            appBar: CustomAppBar(title: Text(context.t.pages.expense.title)),
            body: Column(
              children: [
                ColoredBox(
                  color: _theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      ...[
                        ("all_expense", context.t.pages.expense.allExpense),
                        ("expense_category", context.t.pages.expense.expenseCategory),
                      ].map((entry) => Tab(text: entry.$2)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PermissionGate(
                        moduleKey: PMKeys.expense,
                        fallback: PermissionGate.imageFallback(),
                        child: AllExpenseList(provider: allExpense),
                      ),
                      PermissionGate(
                        moduleKey: PMKeys.expenseCategory,
                        fallback: PermissionGate.imageFallback(),
                        child: ExpenseCategoryList(provider: expenseCategory),
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
                  () => context.router.push(ManageExpenseRoute()),
                  () => context.router.push(ManageExpenseCategoryRoute()),
                ];

                return PermissionGate(
                  moduleKey: [PMKeys.expense, PMKeys.expenseCategory][tabIndex],
                  action: PermissionAction.create,
                  child: SizedBox(
                    height: 48,
                    child: FloatingActionButton.extended(
                      onPressed: actions[tabIndex],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      label: Text(
                        tabIndex == 1 ? '+ ${context.t.common.addCategory}' : '+ ${context.t.common.addExpense}',
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
