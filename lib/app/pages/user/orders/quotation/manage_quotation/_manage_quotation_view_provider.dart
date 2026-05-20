part of 'manage_quotation_view.dart';

class ManageQuotationViewNotifier extends ManageOrderNotifierBase {
  ManageQuotationViewNotifier(super.ref) : super(cartProvider: ref.read(quotationCartProvider));

  //--------------------------Form Field Props--------------------------//
  PaymentOptionEnum selectedPaymentOption = PaymentOptionEnum.fullPayment;
  void handleSelectPaymentOption(PaymentOptionEnum paymentOption) {
    selectedPaymentOption = paymentOption;
    notifyListeners();
  }
  //--------------------------Form Field Props--------------------------//

  void initEdit(Quotation data) {
    dropdownValues['customer_id'] = data.partyId;

    selectedPaymentOption = PaymentOptionEnum.fromString(
      data.meta?.paymentType,
    );

    // Items
    cartProvider.cartItems
      ..clear()
      ..addAll([
        ...?data.details?.map(
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
      (_) => paymentProvider.initEdit(data, resetState: true),
    );
  }

  Quotation prepQuotationData([Quotation? quotation]) {
    final _paymentOptionController = ref.read(selectedPaymentOption.provider);

    return (quotation ?? Quotation()).copyWith(
      partyId: dropdownValues['customer_id'],
      tableId: dropdownValues['table_id'],
      staffId: dropdownValues['waiter_id'],
      addressId: dropdownValues['delivery_address_id'],
      details: [
        ...cartProvider.cartItems.map((cartItem) {
          return SaleItem(
            productId: cartItem.itemId,
            quantities: cartItem.cartQuantity,
            price: cartItem.totalPrice,
            instructions: cartItem.instrctions,
            saleItemOptions: [
              ...?cartItem.modifierOptions?.entries.expand(
                (modifierEntry) => modifierEntry.value.map(
                  (option) {
                    return SaleItemOption(
                      modifierId: modifierEntry.key,
                      optionId: option.id,
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
      couponId: _paymentOptionController.coupon?.id,
      paidAmount: _paymentOptionController.paymentData.paidAmount,
      discountAmount: _paymentOptionController.discountAmount,
      discountPercentage: _paymentOptionController.discountController.getNumber ?? 0,
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

  Future<Either<String, QuotationDetailsModel>> handleManageQuotation([Quotation? data]) async {
    return Future.microtask(() => repo.manageQuotation(prepQuotationData(data)));
  }

  @override
  Sale prepSaleData([Sale? sale]) {
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

final manageQuotationViewProvider = ChangeNotifierProvider.autoDispose(
  ManageQuotationViewNotifier.new,
);
