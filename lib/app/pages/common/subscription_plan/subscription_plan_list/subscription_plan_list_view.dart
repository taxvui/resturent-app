import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../widgets/widgets.dart';
import 'components/components.dart';

@RoutePage()
class SubscriptionPlanListView extends ConsumerWidget {
  const SubscriptionPlanListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _subscriptionPlansAsync = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 16,
        leading: const SizedBox.shrink(),
        title: Text(context.t.pages.subscriptionPlan.title),
        actions: [
          AutoLeadingButton(
            builder: (_, _, action) {
              return CloseButton(onPressed: action);
            },
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(subscriptionPlansProvider.future),
        child: _subscriptionPlansAsync.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          data: (data) {
            final _plans = [
              ...?data.data?.map((plan) {
                final features = Map<String, bool>.fromEntries([
                  ...?plan.features
                      ?.where((feat) => feat.feature != null)
                      .map(
                        (feat) => MapEntry(
                          feat.feature!,
                          feat.status == 1,
                        ),
                      ),
                ]);

                final _cardType = switch (plan.subscriptionPrice ?? 0) {
                  final price when price <= 0 => PlanCardType.basic,
                  final price when price >= 30 => PlanCardType.advance,
                  _ => PlanCardType.basic,
                };

                return PlanCardData(
                  planId: plan.id!,
                  planName: plan.subscriptionName ?? "N/A",
                  price: plan.subscriptionPrice ?? 0,
                  discountPrice: plan.offerPrice,
                  features: features,
                  cardType: plan.isPopular ? PlanCardType.mostPopular : _cardType,
                  iconPath: plan.icon?.remote,
                  symbol: plan.symbol,
                );
              }),
            ];
            return _buildPlanList(plans: _plans);
          },
          error: (error, _) {
            return EmptyWidget(
              replaceDefault: false,
              emptyBuilder: (_) {
                return RetryButtons.scrollView(
                  error,
                  onRetry: () => ref.refresh(subscriptionPlansProvider.future),
                );
              },
            );
          },
          loading: () {
            return Skeletonizer(
              child: _buildPlanList(
                plans: [
                  PlanCardData(
                    planId: 1,
                    planName: 'Basic',
                    price: 1,
                    billingFrequency: '14 Days',
                    features: {
                      'Sales': true,
                      'Parties list': true,
                      'Estimate List': true,
                      'Purchase List': true,
                      'Supplier Due List': true,
                      'Item List & Stocks': true,
                      'Table': true,
                      'Loss / Profit': true,
                      'Transaction List': true,
                      'Income & Expense': false,
                    },
                    cardType: PlanCardType.basic,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanList({required List<PlanCardData> plans}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final _plan = plans[index];
        return PlanCardWidget(
          cardData: _plan,
          onPressedAction: _plan.currentPrice == 0
              ? null
              : () async {
                  return await _handlePurchasePayment(context, _plan.planId);
                },
        );
      },
      separatorBuilder: (c, i) {
        return const SizedBox.square(dimension: 16);
      },
    );
  }

  Future<void> _handlePurchasePayment(BuildContext context, int planId) async {
    final didSuccess = await SharedWidgets.handleOnlinePayment(
      context,
      paymentId: planId,
    );
    if (context.mounted && didSuccess) {
      // ignore: unused_result
      ProviderScope.containerOf(context).read(userRepositoryProvider.notifier).getUser();
      return await context.router.pushWidget<void>(
        PaymentStatusView(
          onPressed: () => context.router.maybePop(true),
          status: PaymentStatusViewType.custom(
            imagePath: PaymentStatusViewType.success.imagePath,
            actionButtonText: context.t.pages.subscriptionPlan.extra.actionButtonText,
            title: PaymentStatusViewType.success.title,
            description: "Subscription payment successfully.\n\nYou can access the subscribed features now.",
          ),
        ),
      );
    }
  }
}
