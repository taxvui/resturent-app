part of '_user_model.dart';

class SubscriptionPlanModel {
  String? message;
  List<Plan>? data;

  SubscriptionPlanModel({this.message, this.data});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) => SubscriptionPlanModel(
        message: json["message"],
        data: json["data"] == null ? [] : List<Plan>.from(json["data"]!.map((x) => Plan.fromJson(x))),
      );
}

class Plan {
  int? id;
  String? subscriptionName;
  int? duration;
  num? offerPrice;
  num? subscriptionPrice;
  int? status;
  List<PlanFeature>? features;
  DynamicFileType? icon;
  String? symbol;
  bool isPopular;

  Plan({
    this.id,
    this.subscriptionName,
    this.duration,
    this.offerPrice,
    this.subscriptionPrice,
    this.status,
    this.features,
    this.icon,
    this.symbol,
    this.isPopular = false,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json["id"],
      subscriptionName: json["subscriptionName"],
      duration: json["duration"],
      offerPrice: json["offerPrice"],
      subscriptionPrice: json["subscriptionPrice"],
      status: json["status"],
      features:
          json["features"] == null ? [] : List<PlanFeature>.from(json["features"]!.map((x) => PlanFeature.fromJson(x))),
      icon: json["icon"] == null ? null : DynamicFileType(remote: json["icon"]),
      symbol: json["symbol"] ?? "\$",
      isPopular: json["is_popular"] == 1,
    );
  }
}

class PlanFeature {
  String? feature;
  int? status;

  PlanFeature({this.feature, this.status});

  factory PlanFeature.fromJson(Map<String, dynamic> json) => PlanFeature(
        feature: json["feature"],
        status: int.tryParse(json["status"]),
      );
}
