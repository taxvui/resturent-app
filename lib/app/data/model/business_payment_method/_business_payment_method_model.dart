import '../model.dart';

class BusinessPaymentMethod {
  int? id;
  int? businessId;
  String? name;
  bool? isView;
  bool? status;

  BusinessPaymentMethod({
    this.id,
    this.businessId,
    this.name,
    this.isView,
    this.status,
  });

  BusinessPaymentMethod copyWith({
    int? id,
    int? businessId,
    String? name,
    bool? isView,
    bool? status,
  }) {
    return BusinessPaymentMethod(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      isView: isView ?? this.isView,
      status: status ?? this.status,
    );
  }

  factory BusinessPaymentMethod.fromJson(Map<String, dynamic> json) {
    return BusinessPaymentMethod(
      id: json["id"],
      businessId: json["business_id"],
      name: json["name"],
      isView: json["is_view"] == 1,
      status: json["status"] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "is_view": isView == true ? 1 : 0,
      "status": status == true ? 1 : 0,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessPaymentMethod && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

typedef BusinessPaymentMethodList = PaginatedListModel<BusinessPaymentMethod>;
