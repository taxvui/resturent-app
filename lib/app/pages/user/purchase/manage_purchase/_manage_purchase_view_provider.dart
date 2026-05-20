part of 'manage_purchase_view.dart';

class ManagePurchaseViewNotifier extends ChangeNotifier {
  ManagePurchaseViewNotifier(this.ref) : _repo = ref.read(purchaseRepoProvider);
  final Ref ref;
  final PurchaseRepository _repo;

  //---------------------------Form Props---------------------------//
  late final invoiceNumberController = TextEditingController();
  late final invoiceDateController = TextEditingController(
    text: DateTime.now().backSlashDateFormat,
  );

  final dropdownValues = <String, dynamic>{
    'supplier_id': null,
    'payment_id': null,
  };
  void handleDropdownChange(MapEntry<String, int?> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  RateModifierData discountModifier = RateModifierData(
    type: RateModifierEnum.flat,
  );
  late final discountController = TextEditingController();
  void handleDiscountModifierChange(RateModifierData data) {
    discountModifier = data;
    notifyListeners();
  }

  late final vatController = TextEditingController();

  late final payAmountController = TextEditingController();
  bool get isPaid {
    final _isPaid = netPayableAmount == (payAmountController.getNumber ?? 0);

    return _isPaid && purchaseItems.isNotEmpty;
  }

  void toggleIsPaid([bool? value]) {
    value == true ? payAmountController.setNumber(netPayableAmount) : payAmountController.clear();
    notifyListeners();
  }

  // Purchase Items
  final purchaseItems = <IngredientCartItem>[];
  void handleAddingToCart(IngredientCartItem item) {
    if (item.quantity <= 0) {
      purchaseItems.removeWhere((element) => element.id == item.id);
    } else {
      final _itemIndex = purchaseItems.indexWhere(
        (element) => element.id == item.id,
      );

      _itemIndex < 0 ? purchaseItems.add(item) : purchaseItems[_itemIndex] = item;
    }
    notifyListeners();
  }

  num get subtotalAmount {
    return purchaseItems.fold<num>(0, (p, eV) => p + eV.totalPrice);
  }

  num get vatAmount {
    final _vatPercent = vatController.getNumber ?? 0;

    final _subtotalWithDiscount = subtotalAmount - discountModifier.valueInFlat;
    return (_vatPercent * _subtotalWithDiscount) / 100;
  }

  num get netPayableAmount {
    final _discount = discountController.getNumber ?? 0;
    final _payableAmount = subtotalAmount - _discount;

    return _payableAmount + vatAmount;
  }

  num get dueAmount {
    return netPayableAmount - (payAmountController.getNumber ?? 0);
  }

  void update() => notifyListeners();
  //---------------------------Form Props---------------------------//

  void initEdit(Purchase data) {
    invoiceNumberController.text = data.invoiceNumber ?? '';
    invoiceDateController.text = data.purchaseDate?.backSlashDateFormat ?? '';
    dropdownValues['supplier_id'] = data.partyId;
    dropdownValues['payment_id'] = data.paymentTypeId;

    // Items
    purchaseItems
      ..clear()
      ..addAll([
        ...?data.details?.map(
          (purchaseItem) => IngredientCartItem(
            id: purchaseItem.ingredientId,
            name: purchaseItem.ingredient?.name,
            quantity: purchaseItem.quantities ?? 0,
            unitPrice: purchaseItem.unitPrice,
            unitId: purchaseItem.unitId,
            unit: purchaseItem.unit,
          ),
        )
      ]);

    discountModifier = discountModifier.copyWith(
      type: RateModifierEnum.flat,
      valueInFlat: data.discountAmount,
      valueInPercent: data.discountPercentage,
    );
    discountController.text = discountModifier.valueInFlat.toString();

    vatController.text = data.taxPercentage.toString();
    payAmountController.text = data.paidAmount.toString();
  }

  Future<Either<String, PurchaseDetailsModel>> handleManagePurchase([
    Purchase? data,
  ]) async {
    final _data = (data ?? Purchase()).copyWith(
      partyId: dropdownValues['supplier_id'],
      purchaseDate: invoiceDateController.text.parseDate,
      discountAmount: discountModifier.valueInFlat,
      discountPercentage: discountModifier.valueInPercent,
      taxAmount: vatAmount,
      taxPercentage: vatController.getNumber ?? 0,
      totalAmount: netPayableAmount,
      dueAmount: dueAmount,
      paidAmount: payAmountController.getNumber ?? 0,
      paymentTypeId: dropdownValues['payment_id'],
      details: [
        ...purchaseItems.map((item) {
          return PurchaseItem(
            ingredientId: item.id,
            unitId: item.unitId,
            unitPrice: item.unitPrice,
            quantities: item.quantity,
          );
        })
      ],
    );

    return await Future.microtask(() => _repo.managePurchase(_data));
  }
}

final managePurchaseViewProvider = ChangeNotifierProvider.autoDispose(
  ManagePurchaseViewNotifier.new,
);
