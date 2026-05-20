part of '_items_model.dart';

class ItemModifier {
  int? id;
  int? businessId;
  int? productId;
  int? modifierGroupId;
  bool isRequired;
  bool isMultiple;
  PItem? product;
  ItemModifierGroup? modifierGroup;

  ItemModifier({
    this.id,
    this.businessId,
    this.productId,
    this.modifierGroupId,
    this.isRequired = false,
    this.isMultiple = false,
    this.product,
    this.modifierGroup,
  });

  ItemModifier copyWith({
    int? id,
    int? businessId,
    int? productId,
    int? modifierGroupId,
    bool? isRequired,
    bool? isMultiple,
    DateTime? createdAt,
    DateTime? updatedAt,
    PItem? product,
    ItemModifierGroup? modifierGroup,
  }) {
    return ItemModifier(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      productId: productId ?? this.productId,
      modifierGroupId: modifierGroupId ?? this.modifierGroupId,
      isRequired: isRequired ?? this.isRequired,
      isMultiple: isMultiple ?? this.isMultiple,
      product: product ?? this.product,
      modifierGroup: modifierGroup ?? this.modifierGroup,
    );
  }

  factory ItemModifier.fromJson(Map<String, dynamic> json) {
    return ItemModifier(
      id: json["id"],
      businessId: json["business_id"],
      productId: json["product_id"],
      modifierGroupId: json["modifier_group_id"],
      isRequired: json["is_required"] == 1,
      isMultiple: json["is_multiple"] == 1,
      product: json["product"] == null ? null : PItem.fromJson(json["product"]),
      modifierGroup: json['modifier_group'] == null ? null : ItemModifierGroup.fromJson(json['modifier_group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "is_required": isRequired ? 1 : 0,
      "is_multiple": isMultiple ? 1 : 0,
      "modifier_group_id": modifierGroupId,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ItemModifier &&
        other.id == id &&
        other.productId == productId &&
        other.modifierGroupId == modifierGroupId;
  }

  @override
  int get hashCode => Object.hash(id, productId, modifierGroupId);
}

typedef ItemModifierList = PaginatedListModel<ItemModifier>;
