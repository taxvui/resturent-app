part of 'manage_item_view.dart';

class ManageItemViewNotifier extends ChangeNotifier {
  ManageItemViewNotifier(this.ref) : _repo = ref.read(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository _repo;

  //-----------------------------Form Props-----------------------------//
  late final images = <DynamicFileType>[];
  List<String>? _previousImages;
  void handleImage(DynamicFileType value, [int? index]) {
    index != null ? images.removeAt(index) : images.add(value);

    notifyListeners();
  }

  late final itemNameController = TextEditingController();
  final dropdownValues = <String, int?>{
    'category': null,
    'menu': null,
  };
  void handleDropdownChange(MapEntry<String, int?> data) {
    dropdownValues[data.key] = data.value;
    notifyListeners();
  }

  final List<int> selectedModifierGroups = [];
  void handleSelectModifierGroups(List<int> newVal) {
    selectedModifierGroups
      ..clear()
      ..addAll(newVal);
    notifyListeners();
  }

  late final preparationTimeController = TextEditingController();
  ItemFoodTypeEnum? foodType;
  void handleSelectFoodType(ItemFoodTypeEnum? value) {
    if (value == foodType) {
      foodType = null;
    } else {
      foodType = value;
    }
    notifyListeners();
  }

  ItemTypeEnum itemType = ItemTypeEnum.single;
  void handleSelectItemType(ItemTypeEnum? value) {
    itemType = value!;
    notifyListeners();
  }

  late final salePriceController = TextEditingController();
  late final descriptionController = TextEditingController();

  List<VariationFormController> variations = [
    // Default One
    VariationFormController()
  ];
  void handleVariation([int index = -1]) {
    if (index == -1) {
      variations.add(VariationFormController());
    } else {
      variations.removeAt(index);
    }
    notifyListeners();
  }
  //-----------------------------Form Props-----------------------------//

  void initEdit(PItem data) {
    images
      ..clear()
      ..addAll([...?data.images]);

    if (data.images?.isNotEmpty == true) {
      _previousImages = [...?data.images?.where((element) => element.remote != null).map((e) => e.remote!)];
    }

    itemNameController.text = data.productName ?? "";
    dropdownValues['menu'] = data.menuId;
    dropdownValues['category'] = data.categoryId;
    selectedModifierGroups
      ..clear()
      ..addAll([
        ...?data.modifiers?.map((im) => im.modifierGroupId).whereType<int>(),
      ]);

    preparationTimeController.text = data.preparationTime?.toString() ?? '';
    foodType = ItemFoodTypeEnum.fromString(data.foodType);
    itemType = ItemTypeEnum.fromString(data.priceType);

    if (itemType.isVariation) {
      variations
        ..clear()
        ..addAll(
          [
            ...?data.variations?.map((variation) {
              final _data = VariationFormController()
                ..initEdit(VariationFormData(
                  name: variation.name,
                  price: variation.price,
                ));
              return _data;
            })
          ],
        );
    } else {
      salePriceController.text = data.salesPrice?.toString() ?? '';
    }

    descriptionController.text = data.description ?? '';
  }

  Future<Either<String, PItem>> handleManageItem([
    PItem? data,
  ]) async {
    var _data = (data ?? PItem()).copyWith(
      images: images,
      productName: itemNameController.text,
      menuId: dropdownValues['menu'],
      categoryId: dropdownValues['category'],
      modifierGroupIds: selectedModifierGroups,
      preparationTime: preparationTimeController.text,
      foodType: foodType?.stringValue,
      priceType: itemType.stringValue,
      variations: [
        if (itemType.isVariation)
          ...variations.map((variation) {
            return PItemVariation(
              name: variation.data.name,
              price: variation.data.price,
            );
          })
      ],
      salesPrice: itemType.isVariation ? null : salePriceController.getNumber,
      description: descriptionController.text,
    );

    if (_previousImages?.isNotEmpty == true) {
      List<String> _removedImages = [];
      for (var previousImage in _previousImages!) {
        final isRemoved = !(_data.images?.any(
              (newImage) => newImage.remote == previousImage,
            ) ??
            false);

        if (isRemoved) {
          _removedImages.add(
            previousImage.split('${DAPIEndpoints.baseURL}/').last,
          );
        }
      }
      _data = _data.copyWith(removedImages: _removedImages);
    }
    return _repo.manageItem(_data);
  }
}

final manageItemProvider = ChangeNotifierProvider.autoDispose(
  ManageItemViewNotifier.new,
);
