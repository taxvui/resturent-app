part of 'quick_order_view.dart';

class BottomActionBuilder extends ConsumerWidget {
  const BottomActionBuilder({
    super.key,
    this.onDetails,
    this.onKOT,
    this.onPayment,
  });
  final VoidCallback? onDetails;
  final VoidCallback? onKOT;
  final VoidCallback? onPayment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCartProvider = ref.watch(quickOrderCartProvider);

    return BottomNavWrapper(
      child: Row(
        children: [
          // Details Button
          Expanded(
            child: SizedBox.expand(
              child: OutlinedButton(
                onPressed: onDetails,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: onDetails == null ? Divider.createBorderSide(context) : null,
                ),
                child: Text(context.t.common.kitchen(n: 1)),
              ),
            ),
          ),
          const SizedBox.square(dimension: 8),

          // KOT Button
          Expanded(
            child: SizedBox.expand(
              child: OutlinedButton(
                onPressed: onKOT,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: onKOT == null ? Divider.createBorderSide(context) : null,
                ),
                child: Text(context.t.common.kot),
              ),
            ),
          ),
          const SizedBox.square(dimension: 8),

          // Payment Button
          Expanded(
            flex: 3,
            child: ItemCartWidget.totalButton(
              onPressed: onPayment,
              buttonText: context.t.common.pay,
              totalAmount: orderCartProvider.cartAmountOverview.totalAmount,
              totalQuantity: orderCartProvider.cartAmountOverview.totalQuantity,
              showTrailing: false,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
