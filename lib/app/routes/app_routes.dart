import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../middlewares/middlewares.dart';
import 'app_routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page|View,Route')
class AppRoutes extends RootStackRouter {
  AppRoutes(this.ref);
  final WidgetRef ref;

  @override
  List<AutoRoute> get routes {
    return [
      // App Entry
      AutoRoute(
        path: '/',
        page: SplashRoute.page,
        initial: true,
      ),

      // Auth Routes
      AutoRoute(
        path: '/auth',
        // page: AuthRoute.page,
        page: const PageInfo.emptyShell('auth'),
        children: [
          AutoRoute(path: 'onboard', page: OnboardRoute.page),
          AutoRoute(path: 'sign-in', page: SignInRoute.page),
          AutoRoute(path: 'sign-up', page: SignUpRoute.page),
          AutoRoute(path: 'otp-verify', page: OtpVerificationRoute.page),
          AutoRoute(path: 'forgot-password', page: ForgotPasswordRoute.page),
          AutoRoute(path: 'reset-password', page: ResetPasswordRoute.page),
        ],
      ),

      // Home Redirect Route
      AutoRoute(
        path: '/mute-home',
        page: MuteHomeRoute.page,
        guards: [AuthGuard(ref)],
      ),

      // User Routes
      AutoRoute(
        path: '/user-panel',
        page: const PageInfo.emptyShell('user-panel'),
        children: [
          // Bottom Nav Route
          AutoRoute(
            path: 'bottom-nav',
            page: BottomNavRoute.page,
            children: [
              AutoRoute(path: 'quick-sale', page: QuickOrderRoute.page),
              AutoRoute(path: 'item-list', page: ItemListRoute.page),
              AutoRoute(path: 'order-list', page: OrderListRoute.page),
              AutoRoute(path: 'report-list', page: ReportListRoute.page),
              AutoRoute(path: 'user-settings', page: UserSettingsRoute.page),
            ],
          ),

          ...[
            AutoRoute(path: 'quick-sale', page: QuickOrderRoute.page),
            AutoRoute(path: 'item-list', page: ItemListRoute.page),
            AutoRoute(path: 'order-list', page: OrderListRoute.page),
            AutoRoute(path: 'report-list', page: ReportListRoute.page),
            AutoRoute(path: 'user-settings', page: UserSettingsRoute.page),
            AutoRoute(path: 'kitchen-list', page: KitchenListRoute.page),
          ],

          // Dashboard Route
          AutoRoute(path: 'dashboard', page: DashboardRoute.page),

          // Manage Profile
          AutoRoute(
            path: 'setup-profile',
            page: SetupProfileRoute.page,
          ),
          AutoRoute(
            path: 'edit-profile',
            page: EditProfileRoute.page,
          ),

          // Staff Management Route
          AutoRoute(
            path: 'staff-list',
            page: StaffListRoute.page,
          ),

          // Parties Route
          AutoRoute(path: 'party-list', page: PartyListRoute.page),
          AutoRoute(path: 'party-details', page: PartyDetailsRoute.page),
          AutoRoute(
            path: 'party-ledger-details',
            page: PartyLedgerDetailsRoute.page,
          ),
          AutoRoute(path: 'manage-party', page: ManagePartyRoute.page),

          // Orders Route
          AutoRoute(path: 'order-details', page: OrderDetailsRoute.page),
          AutoRoute(path: 'manage-order', page: EditOrderRoute.page),
          AutoRoute(path: 'order-payment', page: OrderPaymentRoute.page),

          //---------------------------Purchase---------------------------//
          AutoRoute(path: 'purchase-list', page: PurchaseListRoute.page),
          AutoRoute(path: 'manage-purchase', page: ManagePurchaseRoute.page),
          AutoRoute(
            path: 'purchase-payment-receive',
            page: PurchasePaymentReceiveRoute.page,
          ),

          // Ingredients
          AutoRoute(
            path: 'ingredient-list',
            page: IngredientListRoute.page,
          ),
          AutoRoute(
            path: 'manage-ingredient',
            page: ManageIngredientRoute.page,
          ),

          // Unit
          AutoRoute(path: 'manage-unit', page: ManageUnitRoute.page),
          AutoRoute(path: 'unit-list', page: UnitListRoute.page),
          //---------------------------Purchase---------------------------//

          // Due Routes
          AutoRoute(path: 'due-list', page: DueListRoute.page),
          AutoRoute(
            path: 'manage-due-collection',
            page: ManageDueCollectionRoute.page,
          ),

          // Quotation
          AutoRoute(path: 'quotation-list', page: QuotationListRoute.page),
          AutoRoute(
            path: 'quotation-item-list',
            page: QuotationItemListRoute.page,
          ),
          AutoRoute(
            path: 'manage-quotation',
            page: ManageQuotationRoute.page,
          ),

          // Transaction
          AutoRoute(path: 'transaction-list', page: TransactionListRoute.page),

          // Income
          AutoRoute(path: 'income-list', page: IncomeListRoute.page),
          AutoRoute(path: 'manage-income', page: ManageIncomeRoute.page),
          AutoRoute(
            path: 'manage-income-category',
            page: ManageIncomeCategoryRoute.page,
          ),

          // Expense
          AutoRoute(path: 'expense-list', page: ExpenseListRoute.page),
          AutoRoute(path: 'manage-expense', page: ManageExpenseRoute.page),
          AutoRoute(
            path: 'manage-expense-category',
            page: ManageExpenseCategoryRoute.page,
          ),

          // Finance Overview
          /*
          AutoRoute(path: 'loss-profit-list', page: LossProfitListRoute.page),
          */
          AutoRoute(path: 'money-in-list', page: MoneyInListRoute.page),
          AutoRoute(path: 'money-out-list', page: MoneyOutListRoute.page),

          // Table
          AutoRoute(path: 'table-list', page: TableListRoute.page),
          // Area
          AutoRoute(path: 'area-list', page: AreaListRoute.page),

          //---------------------------Items---------------------------//
          AutoRoute(path: 'manage-item', page: ManageItemRoute.page),
          AutoRoute(path: 'item-details', page: ItemDetailsRoute.page),
          /*
          AutoRoute(path: 'stock-list', page: StockListRoute.page),
          */

          // Category
          AutoRoute(path: 'manage-category', page: ManageCategoryRoute.page),
          AutoRoute(path: 'category-list', page: CategoryListRoute.page),

          // Menu
          AutoRoute(path: 'manage-menu', page: ManageMenuRoute.page),
          AutoRoute(path: 'menu-list', page: MenuListRoute.page),

          // Modifier Group
          AutoRoute(
            path: 'manage-modifier-group',
            page: ManageModifierGroupRoute.page,
          ),
          AutoRoute(
            path: 'modifier-group-list',
            page: ModifierGroupListRoute.page,
          ),

          // Item Modifier
          AutoRoute(
            path: 'manage-item-modifier',
            page: ManageItemModifierRoute.page,
          ),
          AutoRoute(
            path: 'item-modifier-list',
            page: ItemModifierListRoute.page,
          ),
          //---------------------------Items---------------------------//

          // Report Routes
          AutoRoute(
            path: 'reports',
            page: const PageInfo.emptyShell('reports'),
            children: [
              AutoRoute(
                path: 'sales-report-list',
                page: SalesReportListRoute.page,
              ),
              AutoRoute(
                path: 'sales-quotation-report-list',
                page: SalesQuotationReportListRoute.page,
              ),
              AutoRoute(
                path: 'purchase-report-list',
                page: PurchaseReportListRoute.page,
              ),

              /*
              AutoRoute(
                path: 'stock-report-list',
                page: StockReportListRoute.page,
              ),
              */
              AutoRoute(
                path: 'due-report-list',
                page: DueReportListRoute.page,
              ),
              AutoRoute(
                path: 'due-collection-report-list',
                page: DueCollectionReportListRoute.page,
              ),
              AutoRoute(
                path: 'transaction-report-list',
                page: TransactionReportListRoute.page,
              ),
              AutoRoute(
                path: 'income-report-list',
                page: IncomeReportListRoute.page,
              ),
              AutoRoute(
                path: 'expense-report-list',
                page: ExpenseReportListRoute.page,
              ),
              AutoRoute(
                path: 'kot-order-report-list',
                page: KotOrderReportRoute.page,
              ),
            ],
          ),

          // Currency
          AutoRoute(path: 'currency', page: CurrencyRoute.page),
          AutoRoute(path: 'printing-option', page: PrintingOptionRoute.page),

          // Notifications
          AutoRoute(
            path: 'notification-list',
            page: NotificationListRoute.page,
          ),
          AutoRoute(
            path: 'notification-details',
            page: NotificationDetailsRoute.page,
          ),

          // Tax
          AutoRoute(
            path: 'tax-list',
            page: TaxListRoute.page,
          ),
          AutoRoute(
            path: 'manage-tax',
            page: ManageTaxRoute.page,
          ),
          AutoRoute(
            path: 'manage-tax-group',
            page: ManageTaxGroupRoute.page,
          ),

          // Coupon
          AutoRoute(
            path: 'coupon-list',
            page: CouponListRoute.page,
          ),
          AutoRoute(
            path: 'manage-coupon',
            page: ManageCouponRoute.page,
          ),

          // Payment Method
          AutoRoute(
            path: 'business-payment-method-list',
            page: BusinessPaymentMethodListRoute.page,
          ),
          AutoRoute(
            path: 'manage-business-payment-method',
            page: ManageBusinessPaymentMethodRoute.page,
          ),

          // User Roles & Permissions
          AutoRoute(
            path: 'user-role-permission-list',
            page: UserRolePermissionListRoute.page,
          ),
          AutoRoute(
            path: 'manage-user-role-permission',
            page: ManageUserRolePermissionRoute.page,
          ),

          // Chef Bottom Nav Route
          AutoRoute(
            path: 'chef-bottom-nav',
            page: ChefBottomNavRoute.page,
            children: [
              AutoRoute(path: 'kitchen-list', page: KitchenListRoute.page),
              AutoRoute(path: 'kot-list', page: KotListRoute.page),
              AutoRoute(path: 'chef-kot-order-report', page: ChefKotOrderReportRoute.page),
              AutoRoute(path: 'user-settings', page: UserSettingsRoute.page),
            ],
          ),

          // HRM Routes
          ...[
            // HRM
            AutoRoute(
              path: 'hrm',
              page: HrmRoute.page,
            ),

            // Department
            AutoRoute(
              path: 'department-list',
              page: DepartmentListRoute.page,
            ),

            // Manage Department
            AutoRoute(
              path: 'manage-department',
              page: ManageDepartmentRoute.page,
            ),

            // Designation
            AutoRoute(
              path: 'designation-list',
              page: DesignationListRoute.page,
            ),

            // Manage Designation
            AutoRoute(
              path: 'manage-designation',
              page: ManageDesignationRoute.page,
            ),

            // Shift
            AutoRoute(
              path: 'shift-list',
              page: ShiftListRoute.page,
            ),

            // Manage Shift
            AutoRoute(
              path: 'manage-shift',
              page: ManageShiftRoute.page,
            ),

            // Employee
            AutoRoute(
              path: 'employee-list',
              page: EmployeeListRoute.page,
            ),

            // Manage Employee
            AutoRoute(
              path: 'manage-employee',
              page: ManageEmployeeRoute.page,
            ),

            // Attendance
            AutoRoute(
              path: 'attendance-list',
              page: AttendanceListRoute.page,
            ),
            // Manage Attendance
            AutoRoute(
              path: 'manage-attendance',
              page: ManageAttendanceRoute.page,
            ),

            // Payroll
            AutoRoute(
              path: 'payroll-list',
              page: PayrollListRoute.page,
            ),
            // Manage Payroll
            AutoRoute(
              path: 'manage-payroll',
              page: ManagePayrollRoute.page,
            ),

            // Holiday
            AutoRoute(
              path: 'holiday-list',
              page: HolidayListRoute.page,
            ),
            // Manage Holiday
            AutoRoute(
              path: 'manage-holiday',
              page: ManageHolidayRoute.page,
            ),

            // Leave Type
            AutoRoute(
              path: 'leave-type-list',
              page: LeaveTypeListRoute.page,
            ),
            // Manage Leave Type
            AutoRoute(
              path: 'manage-leave-type',
              page: ManageLeaveTypeRoute.page,
            ),

            // Leave
            AutoRoute(
              path: 'leave-list',
              page: LeaveListRoute.page,
            ),
            // Manage Leave
            AutoRoute(
              path: 'manage-leave',
              page: ManageLeaveRoute.page,
            ),

            // Reports
            ...[
              // Attendance Report
              AutoRoute(
                path: 'attendance-report-list',
                page: AttendanceReportListRoute.page,
              ),

              // Payroll Report
              AutoRoute(
                path: 'payroll-report-list',
                page: PayrollReportListRoute.page,
              ),

              // Leave Report
              AutoRoute(
                path: 'leave-report-list',
                page: LeaveReportListRoute.page,
              ),
            ],
          ],
        ],
      ),

      // Common Routes
      ...[
        AutoRoute(path: '/language', page: LanguageRoute.page),
        AutoRoute(path: '/terms-conditions', page: TermsConditionsRoute.page),
        AutoRoute(path: '/privacy-policy', page: PrivacyNPolicyRoute.page),
        AutoRoute(path: '/about-us', page: AboutUsRoute.page),
        AutoRoute(path: '/congratulation', page: CongratulationRoute.page),
        AutoRoute(path: '/invoice-preview', page: InvoicePreviewRoute.page),
        AutoRoute(
          path: '/subscription-plan-list',
          page: SubscriptionPlanListRoute.page,
        ),
        AutoRoute(
          path: '/payment-method-list',
          page: PaymentMethodListRoute.page,
        ),
      ],
    ];
  }

  @override
  List<AutoRouteGuard> get guards => [ContextProviderMiddleware(ref)];
}
