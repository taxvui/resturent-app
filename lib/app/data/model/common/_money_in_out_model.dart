import '../../model/model.dart';

class MoneyInOutModel {
  int? id;
  num? paidAmount;
  num? totalAmount;
  num? dueAmount;
  String? invoiceNumber;
  DateTime? purchaseDate;
  BusinessPaymentMethod? paymentType;
  String? salesType;
  DateTime? saleDate;

  bool get hasDue {
    return (dueAmount ?? 0) > 0;
  }

  bool get isEstimateSale {
    return salesType?.trim().toLowerCase() == 'estimate';
  }

  MoneyInOutModel({
    this.id,
    this.paidAmount,
    this.totalAmount,
    this.dueAmount,
    this.invoiceNumber,
    this.purchaseDate,
    this.paymentType,
    this.salesType,
    this.saleDate,
  });

  factory MoneyInOutModel.fromJson(Map<String, dynamic> json) {
    return MoneyInOutModel(
      id: json["id"],
      paidAmount: json["paidAmount"],
      totalAmount: json["totalAmount"],
      dueAmount: json["dueAmount"],
      invoiceNumber: json["invoiceNumber"],
      purchaseDate: json["purchaseDate"] == null
          ? null
          : DateTime.parse(json["purchaseDate"]),
      paymentType: json["payment_type"] == null
          ? null
          : BusinessPaymentMethod.fromJson(json["payment_type"]),
      salesType: json["sales_type"],
      saleDate:
          json["saleDate"] == null ? null : DateTime.parse(json["saleDate"]),
    );
  }
}

class PaginatedMoneyInOutListModel extends PaginatedListModel<MoneyInOutModel> {
  PaginatedMoneyInOutListModel({super.message, super.data, this.amount});
  final num? amount;

  factory PaginatedMoneyInOutListModel.fromJson(Map<String, dynamic> json) {
    return PaginatedMoneyInOutListModel(
      message: json["message"],
      amount: json["amount"],
      data: json["data"] == null
          ? null
          : PaginatedData<MoneyInOutModel>.fromJson(
              json["data"],
              (x) => MoneyInOutModel.fromJson(x),
            ),
    );
  }
}
