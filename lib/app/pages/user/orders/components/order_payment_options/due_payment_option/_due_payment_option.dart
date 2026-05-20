part of '../_order_payment_options.dart';

class DuePaymentOptionWidget extends PaymentOptionWidgetBase {
  const DuePaymentOptionWidget({super.key}) : super(option: PaymentOptionEnum.duePayment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(duePaymentOptionProvider);

    final _theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment
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

        // Overview
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              orderSummary(showTotal: false),
              const Divider(height: 10),

              // Net Payable
              DefaultTextStyle(
                style: TextStyle().merge(
                  _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  children: [
                    // Expanded(child: Text('Net Payable')),
                    Expanded(child: Text(t.common.netPayable)),
                    Expanded(
                      child: Text(
                        controller.netPayable.quickCurrency(),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 10),

              // Received Amount
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            // text: 'Receive Amount',
                            text: t.common.receiveAmount,
                            recognizer: TapGestureRecognizer()..onTap = controller.toggleIsPaid,
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: SizedBox.square(
                              dimension: 16,
                              child: Checkbox(
                                value: controller.isPaid,
                                onChanged: controller.toggleIsPaid,
                              ),
                            ).fMarginOnly(left: 8),
                          ),
                        ],
                      ),
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        color: _theme.paragraphColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 105,
                      minWidth: 75,
                    ),
                    child: NumberFormField(
                      controller: controller.receivedAmountController,
                      textAlign: TextAlign.end,
                      decoration: CustomFieldStyles.kUnderlined(
                        context,
                        hinText: 'Ex: \$200',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 10),

              // Due Amount
              DefaultTextStyle(
                style: TextStyle().merge(
                  _theme.textTheme.bodyMedium?.copyWith(
                    color: _theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Row(
                  children: [
                    // Expanded(child: Text(controller.isChangeAmount ? 'Change Amount' : 'Due')),
                    Expanded(child: Text(controller.isChangeAmount ? t.common.changeAmount : t.common.due)),
                    Expanded(
                      child: Text(
                        (controller.isChangeAmount ? controller.changeAmount : controller.dueAmount).quickCurrency(),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class DuePaymentOptionWidgetNotifier extends PaymentOptionWidgetBaseNotifier {
  DuePaymentOptionWidgetNotifier(super.ref) : super(paymentOption: PaymentOptionEnum.duePayment);

  //--------------Form Fields----------------------//
  late final receivedAmountController = TextEditingController()..addListener(notifyListeners);
  bool get isPaid {
    return netPayable.toFixedDecimal() == (receivedAmountController.getNumber ?? 0).toFixedDecimal();
  }

  void toggleIsPaid([bool? value]) {
    value ?? !isPaid ? receivedAmountController.setNumber(netPayable) : receivedAmountController.clear();

    notifyListeners();
  }

  num get dueAmount {
    final _dueAmount = netPayable - (receivedAmountController.getNumber ?? 0);

    return (_dueAmount.isNegative ? 0 : _dueAmount).toFixedDecimal();
  }

  num get changeAmount {
    final _changeAmount = netPayable - (receivedAmountController.getNumber ?? 0);
    return (_changeAmount.isNegative ? _changeAmount.abs() : 0).toFixedDecimal();
  }

  bool get isChangeAmount {
    return changeAmount.toFixedDecimal() > 0;
  }
  //--------------Form Fields----------------------//

  @override
  void initEdit(Sale sale, {bool resetState = false}) {
    receivedAmountController.text = sale.paidAmount?.toString() ?? '';
    return super.initEdit(sale, resetState: resetState);
  }

  @override
  PaymentOptionData get paymentData {
    return super.paymentData.copyWith(
          paidAmount: (isChangeAmount ? netPayable : (receivedAmountController.getNumber ?? 0)).toFixedDecimal(),
        );
  }
}

final duePaymentOptionProvider = PaymentOptionWidgetBaseProvider(
  DuePaymentOptionWidgetNotifier.new,
);
