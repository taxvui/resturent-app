part of 'manage_menu_view.dart';

class ManageMenuViewNotifier extends ChangeNotifier {
  ManageMenuViewNotifier(this.ref) : _repo = ref.read(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //----------------------Form Props----------------------//
  final menuNameController = TextEditingController();
  //----------------------Form Props----------------------//

  void initEdit(ItemMenu data) {
    menuNameController.text = data.name ?? '';
  }

  Future<Either<String, ItemMenu>> handleManageMenu([
    ItemMenu? data,
  ]) async {
    final _data = (data ?? ItemMenu()).copyWith(
      name: menuNameController.text,
    );

    return await Future.microtask(() => _repo.manageItemMenu(_data));
  }
}

final manageMenuProvider = ChangeNotifierProvider.autoDispose(
  ManageMenuViewNotifier.new,
);
