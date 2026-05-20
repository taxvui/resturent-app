part of 'edit_order_view.dart';

class EditOrderViewNotifier extends ManageOrderNotifierBase {
  EditOrderViewNotifier(super.ref) : super(cartProvider: ref.read(editOrderCartProvider));

  //--------------------------Form Fields-----------------------------------//
  OrderTypeEnum selectedOrderType = OrderTypeEnum.dineIn;
  PaymentOptionEnum selectedPaymentOption = PaymentOptionEnum.fullPayment;
  void handleSelectPaymentOption(PaymentOptionEnum paymentOption) {
    if (selectedPaymentOption == paymentOption) return;
    selectedPaymentOption = paymentOption;
    notifyListeners();
  }
  //--------------------------Form Fields-----------------------------------//

  void initEdit(Sale sale) {
    dropdownValues["waiter_id"] = sale.staffId;
    dropdownValues["table_id"] = sale.tableId;
    dropdownValues["customer_id"] = sale.partyId;
    dropdownValues["delivery_address_id"] = sale.addressId;

    selectedOrderType = OrderTypeEnum.fromString(sale.salesType);
    selectedPaymentOption = PaymentOptionEnum.fromString(
      sale.meta?.paymentType,
    );

    deliveryChargeController.text = sale.meta?.deliveryCharge?.toString() ?? '';

    // Items
    cartProvider.cartItems
      ..clear()
      ..addAll([
        ...?sale.details?.map(
          (saleItem) => ItemCartModel(
            item: saleItem.product!,
            cartQuantity: saleItem.quantities ?? 0,
            variations: saleItem.variations,
            instrctions: saleItem.instructions,
            modifierOptions: <int, List<ModifierOption>>{
              ...?saleItem.saleItemOptions?.fold<Map<int, List<ModifierOption>>>(
                <int, List<ModifierOption>>{},
                (map, saleOpt) {
                  if (saleOpt.modifierId != null && saleOpt.modifierGroupOption != null) {
                    map.putIfAbsent(saleOpt.modifierId!, () => []).add(saleOpt.modifierGroupOption!);
                  }
                  return map;
                },
              ),
            },
          ),
        ),
      ]);

    // Payment Options
    final paymentProvider = ref.read(selectedPaymentOption.provider);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => paymentProvider.initEdit(sale, resetState: true),
    );
  }

  @override
  Sale prepSaleData([Sale? sale]) {
    final _deliveryCharge = deliveryChargeController.getNumber ?? 0;

    if (sale?.meta?.paymentType == null) {
      final _amount = cartProvider.cartAmountOverview.totalAmount + _deliveryCharge;
      return super
          .prepSaleData(sale)
          .copyWith(
            totalAmount: _amount,
            dueAmount: _amount,
            paidAmount: 0,
          );
    }

    final _paymentOptionController = ref.read(selectedPaymentOption.provider);

    return super
        .prepSaleData(sale)
        .copyWith(
          couponId: _paymentOptionController.coupon?.id,
          paidAmount: _paymentOptionController.paymentData.paidAmount,
          discountAmount: _paymentOptionController.discountAmount,
          discountPercentage: _paymentOptionController.discountController.getNumber,
          couponAmount: _paymentOptionController.couponDiscount.couponAmount,
          couponPercentage: _paymentOptionController.couponDiscount.couponPercent,
          taxId: _paymentOptionController.vatOnSale?.id,
          taxAmount: _paymentOptionController.vatAmount,
          taxPercentage: _paymentOptionController.vatPercent,
          paymentTypeId: _paymentOptionController.paymentData.paymentMethodId,
          totalAmount: _paymentOptionController.netPayable,
          dueAmount: _paymentOptionController.paymentData.dueAmount,
          meta: SaleMeta(
            tip: _paymentOptionController.paymentData.tipAmount,
            paymentType: selectedPaymentOption.stringValue,
            deliveryCharge: deliveryChargeController.getNumber,
          ),
        );
  }
}

final editOrderViewProvider = ManageOrderViewNotifier(
  EditOrderViewNotifier.new,
);
