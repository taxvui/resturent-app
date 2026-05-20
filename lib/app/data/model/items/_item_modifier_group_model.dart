part of '_items_model.dart';

class ItemModifierGroup {
  int? id;
  int? businessId;
  String? name;
  String? description;
  List<ModifierOption>? options;
  List<int>? productIds;
  int? totalModifier;

  ItemModifierGroup({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.options,
    this.productIds,
    this.totalModifier,
  });

  ItemModifierGroup copyWith({
    int? id,
    int? businessId,
    String? name,
    String? description,
    List<ModifierOption>? options,
    List<int>? productIds,
    int? totalModifier,
  }) {
    return ItemModifierGroup(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      options: options ?? this.options,
      productIds: productIds ?? this.productIds,
      totalModifier: totalModifier ?? this.totalModifier,
    );
  }

  factory ItemModifierGroup.fromJson(Map<String, dynamic> json) {
    return ItemModifierGroup(
      id: json["id"],
      businessId: json["business_id"],
      name: json["name"],
      description: json["description"],
      options: json["modifier_group_option"] == null
          ? []
          : List<ModifierOption>.from(
              json["modifier_group_option"]!.map((x) => ModifierOption.fromJson(x)),
            ),
      totalModifier: json["total_modifier"],
    );
  }

  Map<String, dynamic> toJson() {
    final _data = {
      "name": name,
      "description": description,
      "product_id[]": productIds,
    };

    for (int i = 0; i < (options?.length ?? 0); i++) {
      final option = options![i];
      _data["option_name[$i]"] = option.name;
      _data["option_price[$i]"] = option.price;
      _data["is_available[$i]"] = option.isAvailable ? "1" : "0";
    }

    return _data;
  }

  @override
  bool operator ==(Object other) {
    return other is ItemModifierGroup && other.id == id && other.options == options;
  }

  @override
  int get hashCode => Object.hash(id, options);
}

class ModifierOption {
  int? id;
  int? groupId;
  String? name;
  num? price;
  bool isAvailable;

  ModifierOption({
    this.id,
    this.groupId,
    this.name,
    this.price,
    this.isAvailable = false,
  });

  ModifierOption copyWith({
    int? id,
    int? groupId,
    String? name,
    num? price,
    bool? isAvailable,
  }) {
    return ModifierOption(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory ModifierOption.fromJson(Map<String, dynamic> json) {
    return ModifierOption(
      id: json["id"],
      groupId: json["modifier_group_id"],
      name: json["name"],
      price: json["price"],
      isAvailable: json["is_available"]?.toString() == "1",
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModifierOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

typedef ModifierGroupList = PaginatedListModel<ItemModifierGroup>;
