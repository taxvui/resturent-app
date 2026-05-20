import '../model.dart' as model;

class KitchenModel {
  final int? id;
  final String? name;
  final String? description;
  final model.DynamicFileType? image;
  final bool status;
  final int totalProducts;
  final List<model.PItem> products;
  final List<int> existingProductIds;

  const KitchenModel({
    this.id,
    this.name,
    this.description,
    this.image,
    this.status = false,
    this.totalProducts = 0,
    this.products = const [],
    this.existingProductIds = const [],
  });

  KitchenModel copyWith({
    int? id,
    String? name,
    String? description,
    model.DynamicFileType? image,
    bool? status,
    int? totalProducts,
    List<model.PItem>? products,
  }) {
    return KitchenModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      status: status ?? this.status,
      totalProducts: totalProducts ?? this.totalProducts,
      products: products ?? this.products,
      existingProductIds: existingProductIds,
    );
  }

  factory KitchenModel.event(int id) {
    return KitchenModel(id: id);
  }

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    final _products = json['products'] != null
        ? List<model.PItem>.from((json['products']).map((e) => model.PItem.fromJson(e)))
        : const <model.PItem>[];
    return KitchenModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'] != null ? model.DynamicFileType(remote: json['image']) : null,
      status: json['status'] == 1,
      totalProducts: json['total_products'] ?? 0,
      products: _products,
      existingProductIds: _products.map((e) => e.id!).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "image": image?.local,
    };
  }

  Map<String, dynamic> toKitchenItems() {
    final _ids = products.map((e) => e.id!).toList();
    final _removedIds = existingProductIds.where((id) => !_ids.contains(id)).toList();

    return {
      for (int i = 0; i < _ids.length; i++) "product_ids[$i]": _ids[i],
      if (_removedIds.isNotEmpty) ...{
        for (int i = 0; i < _removedIds.length; i++) "removed_ids[$i]": _removedIds[i],
      },
    };
  }
}

typedef KitchenListModel<T extends KitchenModel> = model.PaginatedListModel<T>;
