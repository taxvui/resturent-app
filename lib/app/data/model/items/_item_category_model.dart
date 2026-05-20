part of '_items_model.dart';

class ItemCategory extends Equatable {
  final int? id;
  final int? businessId;
  final String? categoryName;
  final int? status;

  const ItemCategory({
    this.id,
    this.businessId,
    this.categoryName,
    this.status,
  });

  ItemCategory copyWith({
    int? id,
    int? businessId,
    String? categoryName,
    int? status,
  }) {
    return ItemCategory(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
    );
  }

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json["id"],
      businessId: json["business_id"],
      categoryName: json["categoryName"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"categoryName": categoryName};
  }

  @override
  List<Object?> get props => [id, businessId];
}

typedef ItemCategoryList = PaginatedListModel<ItemCategory>;
