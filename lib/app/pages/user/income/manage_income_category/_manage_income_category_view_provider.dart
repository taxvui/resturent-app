part of 'manage_income_category_view.dart';

class ManageIncomeCategoryViewNotifier extends ChangeNotifier {
  ManageIncomeCategoryViewNotifier(this.ref)
      : _repo = ref.watch(incomeRepoProvider);
  final Ref ref;
  final IncomeRepository _repo;

  //----------------------Form Props----------------------//
  late final categoryNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(IncomeCategory data) {
    categoryNameController.text = data.categoryName ?? '';
  }

  Future<Either<String, IncomeCategory>> handleManageCategory([
    IncomeCategory? data,
  ]) async {
    final _data = (data ?? IncomeCategory()).copyWith(
      categoryName: categoryNameController.text,
    );

    return await Future.microtask(() => _repo.manageIncomeCategory(_data));
  }
}

final manageIncomeCategoryViewProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageIncomeCategoryViewNotifier(ref),
);
