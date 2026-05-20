part of 'purchase_payment_receive_view.dart';

class PurchasePaymentReceiveViewNotifier extends ChangeNotifier {
  //---------------------------Form Props---------------------------//
  late final invoiceNumberController = TextEditingController(text: '101');
  late final invoiceDateController = TextEditingController(
    text: CustomDateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  final dropdownValues = <String, dynamic>{
    'supplier': null,
    'payment_method': null,
  };
  void handleDropdownChange(MapEntry<String, dynamic> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  late final receivedAmountController = TextEditingController();
  bool isReceived = false;
  void toggleIsReceived([bool? value]) {
    isReceived = !isReceived;
    notifyListeners();
  }

  //---------------------------Form Props---------------------------//
}

final purchasePaymentReceiveViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => PurchasePaymentReceiveViewNotifier(),
);
