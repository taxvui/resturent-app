import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart' as repo;
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';

class NavigationDrawerBuilder extends ConsumerWidget {
  const NavigationDrawerBuilder({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettingsAsync = ref.watch(repo.modulesProvider);

    return CustomNavigationDrawer(
      title: Text(AppConfig.appName),
      navigationTiles: [
        // Home / Quick Order
        NavDrawerTileItem(
          title: context.t.common.home,
          svgIconPath: DAppDrawerIcons.home.svgPath,
          tileType: NavDrawerTileType.bottomNav,
          bottomNavIndex: 0,
        ),

        // Dashboard
        if (ref.can(PMKeys.dashboard)) ...[
          NavDrawerTileItem(
            title: context.t.common.dashboard,
            svgIconPath: DAppDrawerIcons.dashboard.svgPath,
            route: const DashboardRoute(),
          ),
        ],

        // Parties
        if (ref.can(PMKeys.parties)) ...[
          NavDrawerTileItem(
            title: context.t.common.parties,
            svgIconPath: DAppDrawerIcons.parties.svgPath,
            route: const PartyListRoute(),
          ),
        ],

        // Subscription Plan
        if (ref.can(PMKeys.planSubscription)) ...[
          NavDrawerTileItem(
            title: context.t.common.subscriptionPlan,
            svgIconPath: DAppDrawerIcons.subscriptionPlan.svgPath,
            route: const SubscriptionPlanListRoute(),
          ),
        ],

        // Quotation List
        if (ref.can(PMKeys.quotations)) ...[
          NavDrawerTileItem(
            title: context.t.common.quotationList,
            svgIconPath: DAppDrawerIcons.quotationList.svgPath,
            route: const QuotationListRoute(),
          ),
        ],

        // Purchase
        if (ref.canAny([PMKeys.purchases, PMKeys.ingreditents, PMKeys.units])) ...[
          NavDrawerTileItem(
            title: context.t.common.purchase,
            svgIconPath: DAppDrawerIcons.purchaseList.svgPath,
            tileType: NavDrawerTileType.submenu,
            submenu: [
              // Purchase List
              if (ref.can(PMKeys.purchases))
                NavDrawerTileItem(
                  title: context.t.common.purchaseList,
                  route: const PurchaseListRoute(),
                ),

              // Ingredient List
              if (ref.can(PMKeys.ingreditents))
                NavDrawerTileItem(
                  title: context.t.common.ingredient,
                  route: IngredientListRoute(),
                ),

              // Units
              if (ref.can(PMKeys.units))
                NavDrawerTileItem(
                  title: context.t.common.unit,
                  route: const UnitListRoute(),
                ),
            ],
          ),
        ],

        // Due List
        if (ref.can(PMKeys.dueCollection)) ...[
          NavDrawerTileItem(
            title: context.t.common.dueList,
            svgIconPath: DAppDrawerIcons.dueList.svgPath,
            route: const DueListRoute(),
          ),
        ],

        // Items
        if (ref.canAny([
          PMKeys.products,
          PMKeys.menus,
          PMKeys.categories,
          PMKeys.modifierGroups,
          PMKeys.itemModifiers,
        ])) ...[
          NavDrawerTileItem(
            title: context.t.common.items,
            svgIconPath: DAppDrawerIcons.itemList.svgPath,
            tileType: NavDrawerTileType.submenu,
            submenu: [
              // Item Menus
              if (ref.can(PMKeys.menus)) ...[
                NavDrawerTileItem(
                  title: context.t.common.menus,
                  route: const MenuListRoute(),
                ),
              ],

              // Item Categories
              if (ref.can(PMKeys.categories)) ...[
                NavDrawerTileItem(
                  title: context.t.common.category(n: 2),
                  route: const CategoryListRoute(),
                ),
              ],

              // Item List
              if (ref.can(PMKeys.products)) ...[
                if (ref.user?.role?.isKitchenOrChef == true) ...[
                  NavDrawerTileItem(
                    title: context.t.common.itemsList,
                    route: ItemListRoute(),
                  ),
                ] else ...[
                  NavDrawerTileItem(
                    title: context.t.common.itemsList,
                    tileType: NavDrawerTileType.bottomNav,
                    bottomNavIndex: 2,
                  ),
                ],
              ],

              // Modifier Groups
              if (ref.can(PMKeys.modifierGroups)) ...[
                NavDrawerTileItem(
                  title: context.t.common.modifierGroups,
                  route: const ModifierGroupListRoute(),
                ),
              ],

              // Item Modifiers
              if (ref.can(PMKeys.itemModifiers)) ...[
                NavDrawerTileItem(
                  title: context.t.common.itemModifiers,
                  route: const ItemModifierListRoute(),
                ),
              ],
            ],
          ),
        ],

        // Table List
        if (ref.can(PMKeys.tables)) ...[
          NavDrawerTileItem(
            title: context.t.common.table,
            svgIconPath: DAppDrawerIcons.table.svgPath,
            route: const TableListRoute(),
          ),
        ],

        // Area List
        if (ref.can(PMKeys.areas)) ...[
          NavDrawerTileItem(
            title: context.t.common.areas,
            svgIconPath: DAppDrawerIcons.areas.svgPath,
            route: const AreaListRoute(),
          ),
        ],

        /*
        // Loss/Profit
        if (ref.can(PMKeys.lossProfit))
          NavDrawerTileItem(
            title: "Loss/Profit",
            svgIconPath: DAppDrawerIcons.lossProfit.svgPath,
            route: const LossProfitListRoute(),
          ),
        NavDrawerTileItem(
          title: "Stocks",
          svgIconPath: DAppDrawerIcons.stocks.svgPath,
          route: const StockListRoute(),
        ),
        */

        // Staff
        if (ref.can(PMKeys.staff)) ...[
          NavDrawerTileItem(
            title: context.t.common.staff,
            svgIconPath: DAppDrawerIcons.staff.svgPath,
            route: const StaffListRoute(),
          ),
        ],

        // Money In
        if (ref.can(PMKeys.moneyIn)) ...[
          NavDrawerTileItem(
            title: context.t.common.moneyInList,
            svgIconPath: DAppDrawerIcons.moneyInList.svgPath,
            route: const MoneyInListRoute(),
          ),
        ],

        // Money Out
        if (ref.can(PMKeys.moneyOut)) ...[
          NavDrawerTileItem(
            title: context.t.common.moneyOutList,
            svgIconPath: DAppDrawerIcons.moneyOutList.svgPath,
            route: const MoneyOutListRoute(),
          ),
        ],

        //  Transaction List
        if (ref.can(PMKeys.transactions)) ...[
          NavDrawerTileItem(
            title: context.t.common.transactionList,
            svgIconPath: DAppDrawerIcons.transactionList.svgPath,
            route: const TransactionListRoute(),
          ),
        ],

        // Income
        if (ref.can(PMKeys.income)) ...[
          NavDrawerTileItem(
            title: context.t.common.income,
            svgIconPath: DAppDrawerIcons.income.svgPath,
            route: const IncomeListRoute(),
          ),
        ],

        // Expense
        if (ref.can(PMKeys.expense)) ...[
          NavDrawerTileItem(
            title: context.t.common.expense,
            svgIconPath: DAppDrawerIcons.expense.svgPath,
            route: const ExpenseListRoute(),
          ),
        ],

        // Coupon
        if (ref.can(PMKeys.coupon)) ...[
          NavDrawerTileItem(
            title: context.t.common.coupon,
            svgIconPath: DAppDrawerIcons.couponList.svgPath,
            route: const CouponListRoute(),
          ),
        ],

        // VAT
        if (ref.can(PMKeys.vat)) ...[
          NavDrawerTileItem(
            title: context.t.common.vat,
            svgIconPath: DAppDrawerIcons.taxList.svgPath,
            route: const TaxListRoute(),
          ),
        ],

        // HRM
        ...?appSettingsAsync.whenOrNull(
          data: (data) {
            if (!data.hrmAddon) return null;

            if (!ref.canAny([
              PMKeys.department,
              PMKeys.designation,
              PMKeys.shift,
              PMKeys.employee,
              PMKeys.leaveType,
              PMKeys.leave,
              PMKeys.holiday,
              PMKeys.attendance,
              PMKeys.payroll,
              PMKeys.attendanceReport,
              PMKeys.payrollReport,
              PMKeys.leaveReport,
            ])) {
              return null;
            }

            return [
              NavDrawerTileItem(
                title: context.t.common.hrm,
                svgIconPath: DAppDrawerIcons.hrm.svgPath,
                route: const HrmRoute(),
              ),
            ];
          },
        ),

        // Kitchen
        if (ref.can(PMKeys.kitchen)) ...[
          NavDrawerTileItem(
            title: context.t.common.kitchen(n: 2),
            svgIconPath: DAppDrawerIcons.kitchen.svgPath,
            route: KitchenListRoute(),
          ),
        ],
      ],
      onTap: (tile) {
        scaffoldKey.currentState?.closeDrawer();

        if (tile.tileType == NavDrawerTileType.bottomNav) {
          return AutoTabsRouter.of(context).setActiveIndex(tile.bottomNavIndex!);
        }

        if (tile.tileType == NavDrawerTileType.action) {
          return;
        }

        if (tile.tileType == NavDrawerTileType.route && tile.route != null) {
          context.router.push(tile.route!);
          return;
        }
      },
    );
  }
}
