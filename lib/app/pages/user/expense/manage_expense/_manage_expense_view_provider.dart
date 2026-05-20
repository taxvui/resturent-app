part of 'manage_expense_view.dart';

class ManageExpenseViewNotifier extends ChangeNotifier {
  ManageExpenseViewNotifier(this.ref) : _repo = ref.watch(expenseRepoProvider);
  final Ref ref;
  final ExpenseRepository _repo;

  //---------------------------Form Props---------------------------//
  late final expenseTitleController = TextEditingController();
  final dropdownValues = <String, dynamic>{
    'expense_category': null,
    'payment_id': null,
  };
  void handleDropdownChange(MapEntry<String, dynamic> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  late final paymentAmountController = TextEditingController();
  late final noteController = TextEditingController();
  //---------------------------Form Props---------------------------//

  void initEdit(Expense data) {
    expenseTitleController.text = data.expanseFor ?? '';
    dropdownValues['expense_category'] = data.expenseCategoryId;
    dropdownValues['payment_id'] = data.paymentTypeId;
    paymentAmountController.setNumber(data.amount);
    noteController.text = data.note ?? '';
  }

  Future<Either<String, Expense>> handleManageExpense([Expense? data]) async {
    final _data = (data ?? Expense()).copyWith(
      expanseFor: expenseTitleController.text,
      expenseCategoryId: dropdownValues['expense_category'],
      amount: paymentAmountController.getNumber,
      paymentTypeId: dropdownValues['payment_id'],
      note: noteController.text,
    );

    return await Future.microtask(() => _repo.manageExpense(_data));
  }
}

final manageExpenseViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageExpenseViewNotifier(ref),
);
