part of 'manage_unit_view.dart';

class ManageUnitViewNotifier extends ChangeNotifier {
  ManageUnitViewNotifier(this.ref) : _repo = ref.watch(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //----------------------Form Props----------------------//
  late final unitNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(ItemUnit data) {
    unitNameController.text = data.unitName ?? '';
  }

  Future<Either<String, ItemUnit>> handleManageUnit([
    ItemUnit? data,
  ]) async {
    final _data = (data ?? ItemUnit()).copyWith(
      unitName: unitNameController.text,
    );

    return await Future.microtask(() => _repo.manageItemUnit(_data));
  }
}

final manageUnitProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ManageUnitViewNotifier(ref),
);
