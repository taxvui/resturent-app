part of '_party_model.dart';

class Transaction {
  int? id;
  int? businessId;
  int? saleId;
  int? purchaseId;
  int? paymentTypeId;
  String? invoiceNumber;
  DateTime? date;
  num? totalAmount;
  num? paidAmount;
  num? dueAmount;
  String? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  BusinessPaymentMethod? paymentType;

  bool get isSale => saleId != null && purchaseId == null;
  bool get isPurchase => !isSale;
  bool get isPaid => (totalAmount == paidAmount) && (dueAmount ?? 0) == 0;

  Transaction({
    this.id,
    this.businessId,
    this.saleId,
    this.purchaseId,
    this.paymentTypeId,
    this.invoiceNumber,
    this.date,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.paymentType,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["id"],
      businessId: json["business_id"],
      saleId: json["sale_id"],
      purchaseId: json["purchase_id"],
      paymentTypeId: json["payment_type_id"],
      invoiceNumber: json["invoiceNumber"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      totalAmount: json["total_amount"],
      paidAmount: json["paid_amount"],
      dueAmount: json["due_amount"],
      type: json["type"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      paymentType: json["payment_type"] == null
          ? null
          : BusinessPaymentMethod.fromJson(json["payment_type"]),
    );
  }
}

typedef TransactionList = PaginatedListModel<Transaction>;

typedef TransactionReport = Transaction;
typedef TransactionReportList = PaginatedListModel<TransactionReport>;
