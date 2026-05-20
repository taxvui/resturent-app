part of 'manage_income_view.dart';

class ManageIncomeViewNotifier extends ChangeNotifier {
  ManageIncomeViewNotifier(this.ref) : _repo = ref.watch(incomeRepoProvider);
  final Ref ref;
  final IncomeRepository _repo;
  //---------------------------Form Props---------------------------//
  late final incomeTitleController = TextEditingController();
  final dropdownValues = <String, dynamic>{
    'income_category': null,
    'payment_id': null,
  };
  void handleDropdownChange(MapEntry<String, dynamic> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  late final paymentAmountController = TextEditingController();
  late final noteController = TextEditingController();
  //---------------------------Form Props---------------------------//

  void initEdit(Income data) {
    incomeTitleController.text = data.incomeFor ?? '';
    dropdownValues['income_category'] = data.incomeCategoryId;
    dropdownValues['payment_id'] = data.paymentTypeId;
    paymentAmountController.setNumber(data.amount);
    noteController.text = data.note ?? '';
  }

  Future<Either<String, Income>> handleManageIncome([Income? data]) async {
    final _data = (data ?? Income()).copyWith(
      incomeFor: incomeTitleController.text,
      incomeCategoryId: dropdownValues['income_category'],
      amount: paymentAmountController.getNumber,
      paymentTypeId: dropdownValues['payment_id'],
      note: noteController.text,
    );

    return await Future.microtask(() => _repo.manageIncome(_data));
  }
}

final manageIncomeViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageIncomeViewNotifier(ref),
);
