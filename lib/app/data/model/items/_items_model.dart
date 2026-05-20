import '../model.dart';

part '_item_menu_model.dart';
part '_item_category_model.dart';
part '_item_unit_model.dart';
part '_item_modifier_group_model.dart';
part '_item_modifier_model.dart';

class ItemDetailsModel extends BaseDetailsModel<PItem> {
  ItemDetailsModel({
    super.message,
    super.data,
  });

  factory ItemDetailsModel.fromJson(Map<String, dynamic> json) {
    return ItemDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : PItem.fromJson(json["data"]),
    );
  }
}

class PItem {
  int? id;
  String? productName;
  int? businessId;
  int? categoryId;
  int? menuId;
  String? preparationTime;
  String? foodType;
  String? priceType;
  num? salesPrice;
  List<DynamicFileType>? images;
  List<String>? removedImages;
  String? description;
  ItemMenu? menu;
  ItemCategory? category;
  List<PItemVariation>? variations;
  List<ItemModifier>? modifiers;
  List<int>? modifierGroupIds;

  num get minVariationPrice {
    final prices = variations?.map((v) => v.price).whereType<num>();
    if (prices == null || prices.isEmpty) return 0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  num get currentPrice {
    if (priceType?.trim().toLowerCase() == 'variation') {
      return minVariationPrice;
    }

    return salesPrice ?? 0;
  }

  PItem({
    this.id,
    this.productName,
    this.businessId,
    this.categoryId,
    this.menuId,
    this.preparationTime,
    this.foodType,
    this.priceType,
    this.salesPrice,
    this.images,
    this.removedImages,
    this.description,
    this.menu,
    this.category,
    this.variations,
    this.modifiers,
    this.modifierGroupIds,
  });

  PItem copyWith({
    int? id,
    String? productName,
    int? businessId,
    int? categoryId,
    int? menuId,
    String? preparationTime,
    String? foodType,
    String? priceType,
    num? salesPrice,
    List<DynamicFileType>? images,
    List<String>? removedImages,
    String? description,
    ItemMenu? menu,
    ItemCategory? category,
    List<PItemVariation>? variations,
    List<ItemModifier>? modifiers,
    List<int>? modifierGroupIds,
  }) {
    return PItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      menuId: menuId ?? this.menuId,
      preparationTime: preparationTime ?? this.preparationTime,
      foodType: foodType ?? this.foodType,
      priceType: priceType ?? this.priceType,
      salesPrice: salesPrice ?? this.salesPrice,
      images: images ?? this.images,
      removedImages: removedImages ?? this.removedImages,
      description: description ?? this.description,
      menu: menu ?? this.menu,
      category: category ?? this.category,
      variations: variations ?? this.variations,
      modifiers: modifiers ?? this.modifiers,
      modifierGroupIds: modifierGroupIds ?? this.modifierGroupIds,
    );
  }

  factory PItem.fromJson(Map<String, dynamic> json) {
    return PItem(
      id: json["id"],
      productName: json["productName"],
      businessId: json["business_id"],
      categoryId: json["category_id"],
      menuId: json["menu_id"],
      preparationTime: json["preparation_time"],
      foodType: json["food_type"],
      priceType: json["price_type"],
      salesPrice: json["sales_price"],
      images: json["images"] == null
          ? []
          : List<DynamicFileType>.from(
              json["images"]!.map((x) => DynamicFileType(remote: x)),
            ),
      description: json["description"],
      menu: json["menu"] == null ? null : ItemMenu.fromJson(json["menu"]),
      category: json["category"] == null ? null : ItemCategory.fromJson(json["category"]),
      variations: json["variations"] == null
          ? []
          : List<PItemVariation>.from(json["variations"]!.map((x) => PItemVariation.fromJson(x))),
      modifiers: json["modifiers"] == null
          ? []
          : List<ItemModifier>.from(
              json["modifiers"]!.map((x) => ItemModifier.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    final _images = [...?images?.where((image) => image.local?.path.isNotEmpty == true).map((image) => image.local)];

    final variationEntries = [
      for (int i = 0; i < (variations?.length ?? 0); i++) ...[
        MapEntry("variation_names[$i]", variations![i].name),
        MapEntry("variation_prices[$i]", variations![i].price),
      ],
    ];

    return {
      if (_images.isNotEmpty) ..._images.asMap().map((idx, value) => MapEntry("images[$idx]", value)),
      "productName": productName,
      "category_id": categoryId,
      "menu_id": menuId,
      "sales_price": salesPrice,
      "preparation_time": preparationTime,
      "food_type": foodType,
      "price_type": priceType,
      "description": description,

      ...?modifierGroupIds?.asMap().map((idx, groupId) {
        return MapEntry("modifier_group_id[$idx]", groupId);
      }),

      if (variationEntries.isNotEmpty) ...Map.fromEntries(variationEntries),

      // Removed Image [Only when updating product]
      if (removedImages?.isNotEmpty == true)
        ...?removedImages?.asMap().map((idx, value) {
          return MapEntry("removed_images[$idx]", value);
        }),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is PItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PItemVariation {
  int? id;
  int? productId;
  String? name;
  num? price;

  PItemVariation({
    this.id,
    this.name,
    this.price,
    this.productId,
  });

  PItemVariation copyWith({
    int? id,
    int? modifierGroupId,
    String? name,
    num? price,
    int? productId,
  }) {
    return PItemVariation(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      productId: productId ?? this.productId,
    );
  }

  factory PItemVariation.fromJson(Map<String, dynamic> json) {
    return PItemVariation(
      id: json["id"],
      name: json["name"],
      price: json["price"],
      productId: json["product_id"],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PItemVariation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

typedef PItemList = PaginatedListModel<PItem>;
