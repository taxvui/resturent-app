import '../model.dart';

class CouponModel {
  int? id;
  String? name;
  int? businessId;
  DynamicFileType? image;
  String? code;
  DateTime? startDate;
  DateTime? endDate;
  String? discountType;
  num? discount;
  String? description;

  bool get isPercentage => discountType == 'percentage';

  CouponModel({
    this.id,
    this.name,
    this.businessId,
    this.image,
    this.code,
    this.startDate,
    this.endDate,
    this.discountType,
    this.discount,
    this.description,
  });

  CouponModel copyWith({
    int? id,
    String? name,
    int? businessId,
    DynamicFileType? image,
    String? code,
    DateTime? startDate,
    DateTime? endDate,
    String? discountType,
    num? discount,
    String? description,
  }) {
    return CouponModel(
      id: id ?? this.id,
      name: name ?? this.name,
      businessId: businessId ?? this.businessId,
      image: image ?? this.image,
      code: code ?? this.code,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      discountType: discountType ?? this.discountType,
      discount: discount ?? this.discount,
      description: description ?? this.description,
    );
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json["id"],
        name: json["name"],
        businessId: json["business_id"],
        image: json["image"] == null ? null : DynamicFileType(remote: json["image"]),
        code: json["code"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        discountType: json["discount_type"],
        discount: json["discount"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "code": code,
      "start_date": startDate?.dbFormat,
      "end_date": endDate?.dbFormat,
      "discount_type": discountType,
      "discount": discount,
      "description": description,
      "image": image?.local,
    };
  }
}

typedef CouponList = PaginatedListModel<CouponModel>;
