part of 'manage_item_modifier_view.dart';

class ManageItemModifierViewNotifier extends ChangeNotifier {
  ManageItemModifierViewNotifier(this.ref) : _repo = ref.read(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //------------------------Form Field Props------------------------//
  final dropdownValues = <String, int?>{
    'item_id': null,
    'modifier_group_id': null,
  };
  void handleDropdownChange(MapEntry<String, int?> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  bool isRequired = false;
  bool isMultiSelect = false;
  void handleToggleMultiSelect([bool? value]) {
    isMultiSelect = value ?? !isMultiSelect;
    notifyListeners();
  }

  void handleToggleRequired([bool? value]) {
    isRequired = value ?? !isRequired;
    notifyListeners();
  }
  //------------------------Form Field Props------------------------//

  void initEdit(ItemModifier data) {
    dropdownValues['item_id'] = data.productId;
    dropdownValues['modifier_group_id'] = data.modifierGroupId;
    isRequired = data.isRequired;
    isMultiSelect = data.isMultiple;
  }

  Future<Either<String, ItemModifier>> handleManageItemModifier([
    ItemModifier? data,
  ]) async {
    final _data = (data ?? ItemModifier()).copyWith(
      productId: dropdownValues['item_id'],
      modifierGroupId: dropdownValues['modifier_group_id'],
      isRequired: isRequired,
      isMultiple: isMultiSelect,
    );

    return _repo.manageItemModifier(_data);
  }
}

final manageItemModifierViewProvider = ChangeNotifierProvider.autoDispose(
  ManageItemModifierViewNotifier.new,
);
