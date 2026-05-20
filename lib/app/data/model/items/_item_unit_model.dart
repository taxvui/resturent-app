part of '_items_model.dart';

class ItemUnit extends Equatable {
  final int? id;
  final int? businessId;
  final String? unitName;
  final int? status;

  const ItemUnit({
    this.id,
    this.businessId,
    this.unitName,
    this.status,
  });

  factory ItemUnit.fromJson(Map<String, dynamic> json) {
    return ItemUnit(
      id: json["id"],
      businessId: json["business_id"],
      unitName: json["unitName"],
      status: json["status"],
    );
  }

  ItemUnit copyWith({
    int? id,
    int? businessId,
    String? unitName,
    int? status,
  }) {
    return ItemUnit(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      unitName: unitName ?? this.unitName,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {"unitName": unitName};
  }

  @override
  List<Object?> get props => [id, businessId];
}

typedef ItemUnitList = PaginatedListModel<ItemUnit>;
