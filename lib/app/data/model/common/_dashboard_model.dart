class DashboardSummary extends DashboardModelBase<DashboardSummary> {
  num? totalSales;
  num? totalPurchase;
  num? totalItems;
  num? totalHold;
  num? totalExpense;

  DashboardSummary({
    this.totalSales,
    this.totalPurchase,
    this.totalItems,
    this.totalHold,
    this.totalExpense,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSales: json["total_sales"],
      totalPurchase: json["total_purchase"],
      totalItems: json["total_items"],
      totalHold: json["total_hold"],
      totalExpense: json["total_expense"],
    );
  }

  @override
  DashboardSummary fromJson(Map<String, dynamic> json) {
    return DashboardSummary.fromJson(json);
  }
}

class DashboardChart extends DashboardModelBase<DashboardChart> {
  num? totalLoss;
  num? totalProfit;
  num? lossPercent;
  num? profitPercent;
  num? totalMoneyIn;
  num? totalMoneyOut;
  num? maxValue;
  num? minValue;
  List<ChartData>? moneyIn;
  List<ChartData>? moneyOut;

  DashboardChart({
    this.totalLoss,
    this.totalProfit,
    this.lossPercent,
    this.profitPercent,
    this.totalMoneyIn,
    this.totalMoneyOut,
    this.moneyIn,
    this.moneyOut,
    this.maxValue,
    this.minValue,
  });

  factory DashboardChart.fromJson(Map<String, dynamic> json) {
    return DashboardChart(
      totalLoss: json["total_loss"],
      totalProfit: json["total_profit"],
      lossPercent: json["loss_percentage"],
      profitPercent: json["profit_percentage"],
      totalMoneyIn: json["total_money_in"],
      totalMoneyOut: json["total_money_out"],
      moneyIn: json["money_in"] == null
          ? []
          : List<ChartData>.from(
              json["money_in"]!.map((x) => ChartData.fromJson(x))),
      moneyOut: json["money_out"] == null
          ? []
          : List<ChartData>.from(
              json["money_out"]!.map((x) => ChartData.fromJson(x))),
      maxValue: json['max_value'],
      minValue: json['min_value'],
    );
  }

  @override
  DashboardChart fromJson(Map<String, dynamic> json) {
    return DashboardChart.fromJson(json);
  }
}

class ChartData {
  String? date;
  num? amount;

  ChartData({
    this.date,
    this.amount,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: json["date"],
      amount: json["amount"],
    );
  }
}

abstract class DashboardModelBase<T> {
  DashboardModelBase<T> fromJson(Map<String, dynamic> json);
}

class DashboardResponseModel<T extends DashboardModelBase<T>> {
  final String? message;
  final T? data;

  DashboardResponseModel({this.message, this.data});

  factory DashboardResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return DashboardResponseModel<T>(
      message: json["message"],
      data: json["data"] == null ? null : fromJsonT(json["data"]),
    );
  }
}
