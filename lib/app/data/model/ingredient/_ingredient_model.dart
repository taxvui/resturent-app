import '../model.dart';

class Ingredient {
  int? id;
  int? businessId;
  String? name;

  Ingredient({this.id, this.businessId, this.name});

  Ingredient copyWith({
    int? id,
    int? businessId,
    String? name,
  }) {
    return Ingredient(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json["id"],
      businessId: json["businessId"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

typedef IngredientList = PaginatedListModel<Ingredient>;
