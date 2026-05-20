part of '../_order_payment_options.dart';

class FullPaymentOptionWidget extends PaymentOptionWidgetBase {
  const FullPaymentOptionWidget({super.key}) : super(option: PaymentOptionEnum.fullPayment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(fullPaymentOptionProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Methods
        paymentMethodListWidget(
          selectedId: controller.selectedPaymentMethod,
          onSelected: controller.selectPaymentMethod,
        ),
        const SizedBox.square(dimension: 10),

        // Tip Amount
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: tipSelectorBuilder(),
        ),

        // Coupon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: couponSelectorBuilder(),
        ),
        const SizedBox.square(dimension: 8),

        // Summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: orderSummary(),
        )
      ],
    );
  }
}

class FullPaymentOptionWidgetNotifier extends PaymentOptionWidgetBaseNotifier {
  FullPaymentOptionWidgetNotifier(super.ref) : super(paymentOption: PaymentOptionEnum.fullPayment);

  @override
  PaymentOptionData get paymentData {
    return super.paymentData.copyWith(paidAmount: netPayable);
  }
}

final fullPaymentOptionProvider = PaymentOptionWidgetBaseProvider(
  FullPaymentOptionWidgetNotifier.new,
);
