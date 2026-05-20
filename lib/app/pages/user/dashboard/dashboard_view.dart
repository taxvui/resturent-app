import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../../core/core.dart';
import '../../../data/repository/repository.dart';
import 'components/components.dart';
import '../../../widgets/widgets.dart';
import '../../../routes/app_routes.gr.dart';

part '_dashboard_view_provider.dart';

@RoutePage()
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final _dashboardPrivacy = ref.watch(_dashboardPrivacyProvider);
    final _dashboardSummary = ref.watch(dashboardSummaryProvider);
    final _dashboardChart = ref.watch(dashboardChartProvider);
    final _recentTransaction = ref.watch(recentTransactionProvider);

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.dashboard),
      ),
      body: Column(
        children: [
          // Dashboard Privacy
          Container(
            color: _theme.scaffoldBackgroundColor,
            constraints: BoxConstraints.loose(
              const Size.fromHeight(48),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // 'Dashboard Privacy',
                  context.t.pages.dashboard.dashboardPrivacy,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: _theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox.square(dimension: 6),
                SizedBox(
                  width: 40,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: CustomSwitch(
                      value: _dashboardPrivacy,
                      onChanged: (value) {
                        ref.read(_dashboardPrivacyProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overview Content
          Expanded(
            child: Container(
              color: _theme.colorScheme.primaryContainer,
              constraints: const BoxConstraints.expand(),
              child: RefreshIndicator.adaptive(
                onRefresh: groupRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Containers
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: _dashboardSummary.when(
                          skipLoadingOnRefresh: false,
                          data: (data) {
                            return _buildOverviewContainers(
                              context,
                              dashboardPrivacy: _dashboardPrivacy,
                              data: data.data!,
                            );
                          },
                          error: (error, stackTrace) {
                            return RetryButtons.scrollView(
                              error,
                              onRetry: groupRefresh,
                            );
                          },
                          loading: () {
                            return Skeletonizer(
                              child: _buildOverviewContainers(
                                context,
                                data: DashboardSummary(),
                              ),
                            );
                          },
                        ),
                      ),

                      _dashboardChart.when(
                        skipLoadingOnRefresh: false,
                        data: (data) {
                          return _buildChartOverview(
                            context,
                            dashboardPrivacy: _dashboardPrivacy,
                            data: data.data!,
                          );
                        },
                        error: (error, stackTrace) {
                          return RetryButtons.scrollView(
                            error,
                            onRetry: groupRefresh,
                          );
                        },
                        loading: () {
                          return Skeletonizer(
                            child: _buildChartOverview(
                              context,
                              data: DashboardChart(),
                            ),
                          );
                        },
                      ),

                      const SizedBox.square(dimension: 16),

                      // Recent Transactions
                      _recentTransaction.when(
                        data: (data) {
                          return _buildRecentTransactionList(
                            context,
                            [...?data.data?.data],
                          );
                        },
                        error: (error, stackTrace) {
                          return RetryButtons.scrollView(
                            error,
                            onRetry: groupRefresh,
                          );
                        },
                        loading: () {
                          return Skeletonizer(
                            child: _buildRecentTransactionList(
                              context,
                              List.generate(5, (index) => Transaction()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> groupRefresh() async {
    await Future.wait<void>([
      ref.refresh(dashboardSummaryProvider.future),
      ref.refresh(dashboardChartProvider.future),
      ref.refresh(recentTransactionProvider.future),
    ]);
  }

  Widget _buildOverviewContainers(
    BuildContext context, {
    bool dashboardPrivacy = false,
    required DashboardSummary data,
  }) {
    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 8,
              child: Text(
                // 'Overview',
                context.t.pages.dashboard.overview,
                style: _sectionHeaderStyle,
              ),
            ),
            Flexible(
              flex: 4,
              child: DropdownDateFilter(
                showCustom: false,
                decoration: DropdownDateFilter.defaultDecoration(context).copyWith(
                  border: Border.all(
                    color: _theme.colorScheme.outline.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  color: _theme.colorScheme.primaryContainer,
                  buttonWidth: double.maxFinite,
                  buttonPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  foregroundColor: _theme.colorScheme.secondary,
                  selectedLabelStyle: _theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: ref.watch(overviewDateFilterProvider),
                onChanged: (v) {
                  ref.read(overviewDateFilterProvider.notifier).state = v;
                },
              ),
            ),
          ],
        ).fSizedBox(size: Size.fromHeight(34)),
        const SizedBox.square(dimension: 16),
        Row(
          children: [
            Expanded(
              child: OverviewContainer(
                label: context.t.common.totalSales,
                value: data.totalSales ?? 0,
                color: const Color(0xffE1FFD8),
                isCurrency: true,
                obscureValue: dashboardPrivacy,
                decimalDigits: 2,
              ),
            ),
            SizedBox.square(dimension: 8),
            Expanded(
              child: OverviewContainer(
                label: context.t.common.totalPurchase,
                value: data.totalPurchase ?? 0,
                color: const Color(0xffF0E2FF),
                isCurrency: true,
                obscureValue: dashboardPrivacy,
                decimalDigits: 2,
              ),
            ),
          ],
        ),
        const SizedBox.square(dimension: 8),
        Row(
          children: [
            Expanded(
              child: OverviewContainer(
                label: context.t.common.totalItems,
                value: data.totalItems ?? 0,
                color: const Color(0xffFFF8CE),
                obscureValue: dashboardPrivacy,
              ),
            ),
            SizedBox.square(dimension: 8),
            Expanded(
              child: OverviewContainer(
                label: context.t.common.holdNumber,
                value: data.totalHold ?? 0,
                color: const Color(0xffFFEBE2),
                obscureValue: dashboardPrivacy,
              ),
            ),
          ],
        ),
        const SizedBox.square(dimension: 8),
        OverviewContainer(
          label: context.t.common.totalExpense,
          value: data.totalExpense ?? 0,
          isCurrency: true,
          color: const Color(0xffFFE2E2),
          obscureValue: dashboardPrivacy,
          decimalDigits: 2,
        ),
        const SizedBox.square(dimension: 24),
      ],
    );
  }

  Widget _buildChartOverview(
    BuildContext context, {
    bool dashboardPrivacy = false,
    required DashboardChart data,
  }) {
    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Money In & Money Out Chart
        Row(
          children: [
            Expanded(
              flex: 8,
              child: Text(
                // 'Money In & Money Out',
                context.t.pages.dashboard.moneyInAndMoneyOut,
                style: _sectionHeaderStyle,
              ),
            ),
            Flexible(
              flex: 4,
              child: DropdownDateFilter(
                showCustom: false,
                replaceDefault: true,
                decoration: DropdownDateFilter.defaultDecoration(context).copyWith(
                  border: Border.all(
                    color: _theme.colorScheme.outline.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  color: _theme.colorScheme.primaryContainer,
                  buttonWidth: double.maxFinite,
                  buttonPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  foregroundColor: _theme.colorScheme.secondary,
                  selectedLabelStyle: _theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                items: [
                  DropdownDateFilter.weekly,
                  DropdownDateFilter.monthly,
                  DropdownDateFilter.yearly,
                ],
                value: ref.watch(chartDateFilterProvider),
                onChanged: (v) {
                  ref.read(chartDateFilterProvider.notifier).state = v;
                },
              ),
            ),
          ],
        ).fSizedBox(size: Size.fromHeight(34)).fMarginSymmetric(horizontal: 16),
        const SizedBox.square(dimension: 16),
        ConstrainedBox(
          constraints: BoxConstraints.loose(
            const Size.fromHeight(320),
          ),
          child: MoneyInMoneyOutChart(
            obscureValue: dashboardPrivacy,
            chartData: data,
          ),
        ),
        const SizedBox.square(dimension: 16),

        // Profit & Loss Overview
        Text(
          // "Profit & Loss Overview",
          context.t.pages.dashboard.lossAndProfitOverView,
          style: _sectionHeaderStyle,
        ).fMarginSymmetric(horizontal: 16),
        ConstrainedBox(
          constraints: BoxConstraints.loose(const Size.fromHeight(260)),
          child: Center(
            child: CustomPiChart(
              chartData: [
                CustomPiChartData(
                  color: DAppColors.kWarning,
                  value: data.lossPercent ?? 0,
                  label: TextSpan(
                    text: '${context.t.common.loss}: ',
                    children: [
                      TextSpan(
                        text: getObscureValue(
                          (data.totalLoss ?? 0).compactCurrency(),
                        ),
                        style: TextStyle(
                          color: _theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPiChartData(
                  color: DAppColors.kSuccess,
                  value: data.profitPercent ?? 0,
                  label: TextSpan(
                    text: '${context.t.common.profit}: ',
                    children: [
                      TextSpan(
                        text: getObscureValue(
                          (data.totalProfit ?? 0).compactCurrency(),
                        ),
                        style: TextStyle(
                          color: _theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionList(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // "Recent Transaction",
              context.t.common.recentTransaction,
              style: _sectionHeaderStyle,
            ),
            TextButton(
              onPressed: () async {
                return context.router.push<void>(
                  const TransactionListRoute(),
                );
              },
              style: TextButton.styleFrom(
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
              child: Text(context.t.action.viewAll),
            ),
          ],
        ).fMarginSymmetric(horizontal: 16),

        // Transaction List
        ...List.generate(
          transactions.length,
          (index) {
            final transaction = transactions[index];
            late final TransactionCardType _cardType;

            if (transaction.isSale) {
              _cardType = TransactionCardType.saleList();
            } else {
              if (transaction.isPaid) {
                _cardType = TransactionCardType.purchaseList(
                  status: TransactionCardStatus.paid,
                );
              } else {
                _cardType = TransactionCardType.purchaseList(
                  status: TransactionCardStatus.due,
                );
              }
            }

            return TransactionCard(
              cardData: TransactionCardData(
                cardType: _cardType,
                invoiceNumber: transaction.invoiceNumber ?? "N/A",
                transactionDate: transaction.date,
                paymentType: transaction.paymentType?.name,
                primaryValue: transaction.totalAmount ?? 0,
                secondaryValue: (transaction.isPaid ? transaction.paidAmount : transaction.dueAmount) ?? 0,
              ),
            ).fMarginOnly(bottom: index == 9 ? 0 : 12);
          },
        ),
      ],
    );
  }

  String getObscureValue<T>(T value) {
    return ref.read(_dashboardPrivacyProvider) ? value.toString().obscure : value.toString();
  }
}

final _dashboardPrivacyProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);
