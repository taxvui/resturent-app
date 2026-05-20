import '../model.dart';

class TaxModelResponse {
  String? message;
  List<TaxModel>? data;

  TaxModelResponse({this.message, this.data});

  factory TaxModelResponse.fromJson(Map<String, dynamic> json) {
    return TaxModelResponse(
      message: json["message"],
      data: json["data"] == null ? [] : List<TaxModel>.from(json["data"]!.map((x) => TaxModel.fromJson(x))),
    );
  }
}

class TaxModel extends Equatable {
  final int? id;
  final String? name;
  final int? businessId;
  final num? rate;
  final List<TaxModel>? subTax;
  final bool? status;
  final bool? isVatOnSales;

  const TaxModel({
    this.id,
    this.name,
    this.businessId,
    this.rate,
    this.subTax,
    this.status,
    this.isVatOnSales,
  });

  TaxModel copyWith({
    int? id,
    String? name,
    int? businessId,
    num? rate,
    List<TaxModel>? subTax,
    bool? status,
    bool? isVatOnSales,
  }) {
    return TaxModel(
      id: id ?? this.id,
      name: name ?? this.name,
      businessId: businessId ?? this.businessId,
      rate: rate ?? this.rate,
      subTax: subTax ?? this.subTax,
      status: status ?? this.status,
      isVatOnSales: isVatOnSales ?? this.isVatOnSales,
    );
  }

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json["id"],
      name: json["name"],
      businessId: json["business_id"],
      rate: json["rate"]?.toDouble(),
      subTax: json["sub_tax"] == null ? [] : List<TaxModel>.from(json["sub_tax"]!.map((x) => TaxModel.fromJson(x))),
      status: json["status"],
      isVatOnSales: json["vat_on_sale"] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{
      'name': name,
      'status': status == true ? 1 : 0,
      'vat_on_sale': isVatOnSales == true ? 1 : 0,
    };

    if (subTax?.isNotEmpty ?? false) {
      _data['tax_ids[]'] = subTax!.map((e) => e.id).toList();
    } else if (rate != null) {
      _data['rate'] = rate;
    }

    return _data;
  }

  @override
  List<Object?> get props => [id];
}
