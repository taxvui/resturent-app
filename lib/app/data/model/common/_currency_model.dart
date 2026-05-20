class CurrencyReponseModel {
  String? message;
  List<Currency>? data;

  CurrencyReponseModel({
    this.message,
    this.data,
  });

  factory CurrencyReponseModel.fromJson(Map<String, dynamic> json) {
    return CurrencyReponseModel(
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<Currency>.from(json["data"]!.map((x) => Currency.fromJson(x))),
    );
  }
}

class Currency {
  int? id;
  String? name;
  String? countryName;
  String? code;
  double? rate;
  String? symbol;
  String? position;
  bool? status;
  bool? isDefault;

  bool get isRight => position == 'right';

  Currency({
    this.id,
    this.name,
    this.countryName,
    this.code,
    this.rate,
    this.symbol,
    this.position,
    this.status,
    this.isDefault,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json["id"],
      name: json["name"],
      countryName: json["country_name"],
      code: json["code"],
      rate: json["rate"]?.toDouble(),
      symbol: json["symbol"],
      position: json["position"],
      status: json["status"],
      isDefault: json["is_default"],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Currency) return code == other.code;
    return false;
  }

  @override
  int get hashCode => code.hashCode;
}
