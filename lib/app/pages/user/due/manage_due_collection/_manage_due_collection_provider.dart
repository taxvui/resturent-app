part of 'manage_due_collection_view.dart';

class ManageDuCollectionNotifier extends ChangeNotifier {
  ManageDuCollectionNotifier(this.ref) : _repo = ref.read(dueRepoProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      receivedAmountController.addListener(notifyListeners);
    });
  }
  final Ref ref;
  final DueRepository _repo;

  //---------------------------Form Props---------------------------//
  late final invoiceNumberController = TextEditingController();
  late final invoiceDateController = TextEditingController(
    text: DateTime.now().backSlashDateFormat,
  );
  late final receivedAmountController = TextEditingController();
  final dropdownValues = <String, dynamic>{
    'party_id': null,
    'payment_id': null,
  };
  void handleDropdownChange(MapEntry<String, dynamic> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  bool get isReceived {
    return dueAmount == (receivedAmountController.getNumber ?? 0);
  }

  void toggleIsReceived([bool? value]) {
    value == true ? receivedAmountController.setNumber(dueAmount) : receivedAmountController.clear();
    notifyListeners();
  }

  num dueAmount = 0;

  num get balanceDue {
    final _dueAmount = dueAmount - (receivedAmountController.getNumber ?? 0);

    return _dueAmount.isNegative ? 0 : _dueAmount;
  }

  num get changeAmount {
    final _changeAmount = dueAmount - (receivedAmountController.getNumber ?? 0);
    return _changeAmount.isNegative ? _changeAmount.abs() : 0;
  }

  bool get isChangeAmount {
    return num.parse(changeAmount.toStringAsFixed(2)) > 0;
  }
  //---------------------------Form Props---------------------------//

  void initEdit(DueCollection data) {
    invoiceNumberController.text = data.refInvoiceNumber ?? '';
    if (data.paymentDate != null) {
      invoiceDateController.text = data.paymentDate!.backSlashDateFormat;
    }
    dropdownValues['party_id'] = data.partyId;
    dropdownValues['payment_id'] = data.paymentTypeId;
    receivedAmountController.text = data.payDueAmount?.toString() ?? '';
    dueAmount = data.dueAmountAfterPay ?? 0;
  }

  Future<Either<String, DueCollectionDetailsModel>> handleManageDueCollection(
    DueCollection data,
  ) async {
    final _data = data.copyWith(
      invoiceNumber: data.refInvoiceNumber,
      partyId: dropdownValues['party_id'],
      paymentTypeId: dropdownValues['payment_id'],
      paymentDate: invoiceDateController.text.parseDate,
      payDueAmount: isChangeAmount ? dueAmount : receivedAmountController.getNumber,
    );
    return await Future.microtask(() => _repo.manageDueCollection(_data));
  }
}

final manageDueCollectionProvider = ChangeNotifierProvider.autoDispose(
  ManageDuCollectionNotifier.new,
);
