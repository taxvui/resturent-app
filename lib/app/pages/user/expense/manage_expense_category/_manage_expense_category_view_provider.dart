part of 'manage_expense_category_view.dart';

class ManageExpenseCategoryViewNotifier extends ChangeNotifier {
  ManageExpenseCategoryViewNotifier(this.ref)
      : _repo = ref.watch(expenseRepoProvider);
  final Ref ref;
  final ExpenseRepository _repo;

  //----------------------Form Props----------------------//
  late final categoryNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(ExpenseCategory data) {
    categoryNameController.text = data.categoryName ?? '';
  }

  Future<Either<String, ExpenseCategory>> handleManageCategory([
    ExpenseCategory? data,
  ]) async {
    final _data = (data ?? ExpenseCategory()).copyWith(
      categoryName: categoryNameController.text,
    );

    return await Future.microtask(() => _repo.manageExpenseCategory(_data));
  }
}

final manageExpenseCategoryViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageExpenseCategoryViewNotifier(ref),
);
