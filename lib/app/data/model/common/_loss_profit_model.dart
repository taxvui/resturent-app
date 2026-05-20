import '../model.dart';

class LossProfit {
  int? id;
  String? invoiceNumber;
  DateTime? saleDate;
  num? lossProfit;
  num? totalAmount;
  BusinessPaymentMethod? paymentType;

  LossProfit({
    this.id,
    this.invoiceNumber,
    this.saleDate,
    this.lossProfit,
    this.totalAmount,
    this.paymentType,
  });

  bool get isLoss => (lossProfit ?? 0) < 0;

  factory LossProfit.fromJson(Map<String, dynamic> json) {
    return LossProfit(
      id: json["id"],
      invoiceNumber: json["invoiceNumber"],
      saleDate:
          json["saleDate"] == null ? null : DateTime.parse(json["saleDate"]),
      lossProfit: json["lossProfit"],
      totalAmount: json["totalAmount"],
      paymentType: json["payment_type"] == null
          ? null
          : BusinessPaymentMethod.fromJson(json["payment_type"]),
    );
  }
}

class PaginatedLossProfitListModel extends PaginatedListModel<LossProfit> {
  PaginatedLossProfitListModel({
    super.message,
    super.data,
    this.totalLoss,
    this.totalProfit,
  });
  final num? totalLoss;
  final num? totalProfit;

  factory PaginatedLossProfitListModel.fromJson(Map<String, dynamic> json) {
    return PaginatedLossProfitListModel(
      message: json["message"],
      totalLoss: json["total_loss"],
      totalProfit: json["total_profit"],
      data: json["data"] == null
          ? null
          : PaginatedData<LossProfit>.fromJson(
              json["data"],
              (x) => LossProfit.fromJson(x),
            ),
    );
  }
}
