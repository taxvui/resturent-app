import 'package:flutter/material.dart';

import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

abstract class ManageOrderNotifierBase extends ChangeNotifier {
  ManageOrderNotifierBase(this.ref, {required this.cartProvider}) : repo = ref.read(saleRepoProvider);

  final Ref ref;
  final ItemCartNotifierBase cartProvider;
  final SaleRepository repo;

  //---------------------------Form Props---------------------------//
  final dropdownValues = <String, dynamic>{
    'waiter_id': null,
    'table_id': null,
    'customer_id': null,
    'delivery_address_id': null,
  };
  void handleDropdownChange(MapEntry<String, dynamic> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  late final deliveryChargeController = TextEditingController();
  //---------------------------Form Props---------------------------//

  Sale prepSaleData([Sale? sale]) {
    final _deliveryCharge = deliveryChargeController.getNumber ?? 0;
    final _amount = cartProvider.cartAmountOverview.totalAmount + _deliveryCharge;

    return (sale ?? Sale()).copyWith(
      partyId: dropdownValues['customer_id'],
      tableId: dropdownValues['table_id'],
      staffId: dropdownValues['waiter_id'],
      addressId: dropdownValues['delivery_address_id'],
      saleDate: DateTime.now(),
      dueAmount: _amount,
      totalAmount: _amount,
      paidAmount: 0,
      discountAmount: 0,
      discountPercentage: 0,
      taxAmount: 0,
      taxPercentage: 0,
      details: [
        ...cartProvider.cartItems.map((cartItem) {
          return SaleItem(
            productId: cartItem.itemId,
            quantities: cartItem.cartQuantity,
            price: cartItem.totalPrice,
            instructions: cartItem.instrctions,
            variations: cartItem.variations,
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
      meta: (sale?.meta ?? SaleMeta()).copyWith(
        deliveryCharge: deliveryChargeController.getNumber,
      ),
    );
  }

  Future<Either<String, SaleDetailsModel>> handleManageSale([Sale? data]) async {
    return Future.microtask(() => repo.manageSale(prepSaleData(data)));
  }
}

typedef ManageOrderViewNotifier<T extends ManageOrderNotifierBase> = AutoDisposeChangeNotifierProvider<T>;
