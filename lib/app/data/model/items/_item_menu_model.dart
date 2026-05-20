part of '_items_model.dart';

class ItemMenu extends Equatable {
  final int? id;
  final int? businessId;
  final String? name;
  final int? status;

  const ItemMenu({
    this.id,
    this.businessId,
    this.name,
    this.status,
  });

  factory ItemMenu.fromJson(Map<String, dynamic> json) {
    return ItemMenu(
      id: json["id"],
      businessId: json["business_id"],
      name: json["name"],
      status: json["status"],
    );
  }

  ItemMenu copyWith({
    int? id,
    int? businessId,
    String? name,
    int? status,
  }) {
    return ItemMenu(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name};
  }

  @override
  List<Object?> get props => [id, businessId];
}

typedef ItemMenuList = PaginatedListModel<ItemMenu>;
