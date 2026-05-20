part of 'manage_category_view.dart';

class ManageCategoryViewNotifier extends ChangeNotifier {
  ManageCategoryViewNotifier(this.ref) : _repo = ref.watch(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //----------------------Form Props----------------------//
  late final categoryNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(ItemCategory data) {
    categoryNameController.text = data.categoryName ?? '';
  }

  Future<Either<String, ItemCategory>> handleManageCategory([
    ItemCategory? data,
  ]) async {
    final _data = (data ?? ItemCategory()).copyWith(
      categoryName: categoryNameController.text,
    );

    return await Future.microtask(() => _repo.manageItemCategory(_data));
  }
}

final manageCategoryProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageCategoryViewNotifier(ref),
);
