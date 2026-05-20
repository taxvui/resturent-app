part of 'manage_modifier_group_view.dart';

class ManageModifierGroupViewNotifier extends ChangeNotifier {
  ManageModifierGroupViewNotifier(this.ref)
      : _repo = ref.read(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //--------------------------Form Field Props--------------------------//
  late final modifierNameController = TextEditingController(),
      descriptionController = TextEditingController();

  final List<int> selectedLocations = [];
  void handleSelectLocations(List<int> newVal) {
    selectedLocations
      ..clear()
      ..addAll(newVal);
    notifyListeners();
  }

  List<ModifierOptionFormController> modifierOptions = [
    // Default One
    ModifierOptionFormController()
  ];
  void handleModifierOption([int index = -1]) {
    if (index == -1) {
      modifierOptions.add(ModifierOptionFormController());
    } else {
      modifierOptions.removeAt(index);
    }
    notifyListeners();
  }
  //--------------------------Form Field Props--------------------------//

  void initEdit(ItemModifierGroup data) {
    modifierNameController.text = data.name ?? '';
    descriptionController.text = data.description ?? '';

    modifierOptions
      ..clear()
      ..addAll([
        ...?data.options?.map((option) {
          final _data = ModifierOptionFormController()
            ..initEdit(ModifierOptionFormData(
              name: option.name,
              price: option.price ?? 0,
              isAvailable: option.isAvailable,
            ));
          return _data;
        })
      ]);
  }

  Future<Either<String, ItemModifierGroup>> handleManageModifierGroup([
    ItemModifierGroup? data,
  ]) async {
    final _data = (data ?? ItemModifierGroup()).copyWith(
      name: modifierNameController.text,
      description: descriptionController.text,
      productIds: selectedLocations,
      options: modifierOptions.map((e) {
        return ModifierOption(
          name: e.nameController.text,
          price: e.priceController.getNumber,
          isAvailable: e.isAvailable,
        );
      }).toList(),
    );

    return _repo.manageItemModifierGroup(_data);
  }
}

final manageModifierGroupViewProvider = ChangeNotifierProvider.autoDispose(
  ManageModifierGroupViewNotifier.new,
);
