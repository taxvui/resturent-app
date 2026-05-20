import '../model.dart';

class DueModel {
  int? id;
  int? partyId;
  int? paymentTypeId;
  String? invoiceNumber;
  num? totalAmount;
  num? paidAmount;
  num? dueAmount;
  DateTime? date;
  String? type;
  BusinessPaymentMethod? paymentMethod;
  Party? party;

  bool get isPurchaseDue => party?.type == 'supplier';

  bool get isPaid => paidAmount == totalAmount && dueAmount == 0;
  bool get isPartial {
    return (paidAmount ?? 0) < (totalAmount ?? 0) && (dueAmount ?? 0) > 0;
  }

  DueModel({
    this.id,
    this.partyId,
    this.paymentTypeId,
    this.invoiceNumber,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.date,
    this.type,
    this.party,
    this.paymentMethod,
  });

  DueModel copyWith({
    int? id,
    int? partyId,
    int? paymentTypeId,
    String? invoiceNumber,
    num? totalAmount,
    num? paidAmount,
    num? dueAmount,
    DateTime? date,
    String? type,
    Party? party,
    BusinessPaymentMethod? paymentMethod,
  }) {
    return DueModel(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      date: date ?? this.date,
      type: type ?? this.type,
      party: party ?? this.party,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  factory DueModel.fromJson(Map<String, dynamic> json) {
    return DueModel(
      id: json["id"],
      partyId: json["party_id"],
      paymentTypeId: json["payment_type_id"],
      invoiceNumber: json["invoiceNumber"],
      totalAmount: json["totalAmount"],
      paidAmount: json["paidAmount"],
      dueAmount: json["dueAmount"],
      date: json["date"] == null ? null : DateTime.parse(json["date"]),
      type: json["type"],
      party: json["party"] == null ? null : Party.fromJson(json["party"]),
      paymentMethod: json["payment_type"] == null ? null : BusinessPaymentMethod.fromJson(json["payment_type"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "party_id": partyId,
      "payment_type_id": paymentTypeId,
      "invoiceNumber": invoiceNumber,
      "totalAmount": totalAmount,
      "dueAmount": dueAmount,
      "date": date?.toIso8601String(),
      "type": type,
      "payment_type": paymentMethod?.toJson(),
    };
  }
}

typedef DueList = PaginatedListModel<DueModel>;

class DueCollectionDetailsModel extends BaseDetailsModel<DueCollection> {
  DueCollectionDetailsModel({super.message, super.data});

  factory DueCollectionDetailsModel.fromJson(Map<String, dynamic> json) {
    return DueCollectionDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : DueCollection.fromJson(json["data"]),
    );
  }
}

class DueCollection {
  int? id;
  int? businessId;
  int? partyId;
  int? userId;
  int? paymentTypeId;
  int? purchaseId;
  int? saleId;
  String? invoiceNumber;
  String? refInvoiceNumber;
  num? totalDue;
  num? dueAmountAfterPay;
  num? payDueAmount;
  DateTime? paymentDate;
  bool isLast;
  User? user;
  Party? party;
  BusinessPaymentMethod? paymentType;

  bool get isPurchaseDue => party?.type == 'supplier';

  bool get isFullyPaid => (dueAmountAfterPay ?? 0) == 0;
  bool get isPartiallyPaid => (dueAmountAfterPay ?? 0) > 0;

  DueCollection({
    this.id,
    this.businessId,
    this.partyId,
    this.userId,
    this.paymentTypeId,
    this.purchaseId,
    this.saleId,
    this.invoiceNumber,
    this.refInvoiceNumber,
    this.totalDue,
    this.dueAmountAfterPay,
    this.payDueAmount,
    this.paymentDate,
    this.isLast = false,
    this.user,
    this.party,
    this.paymentType,
  });

  DueCollection copyWith({
    int? id,
    int? businessId,
    int? partyId,
    int? userId,
    int? paymentTypeId,
    int? purchaseId,
    int? saleId,
    String? invoiceNumber,
    String? refInvoiceNumber,
    num? totalDue,
    num? dueAmountAfterPay,
    num? payDueAmount,
    DateTime? paymentDate,
    bool? isLast,
    User? user,
    Party? party,
    BusinessPaymentMethod? paymentType,
  }) {
    return DueCollection(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      purchaseId: purchaseId ?? this.purchaseId,
      saleId: saleId ?? this.saleId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      refInvoiceNumber: refInvoiceNumber ?? this.refInvoiceNumber,
      totalDue: totalDue ?? this.totalDue,
      dueAmountAfterPay: dueAmountAfterPay ?? this.dueAmountAfterPay,
      payDueAmount: payDueAmount ?? this.payDueAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      isLast: isLast ?? this.isLast,
      user: user ?? this.user,
      party: party ?? this.party,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  factory DueCollection.fromJson(Map<String, dynamic> json) {
    return DueCollection(
      id: json["id"],
      businessId: json["business_id"],
      partyId: json["party_id"],
      userId: json["user_id"],
      paymentTypeId: json["payment_type_id"],
      purchaseId: json["purchase_id"],
      saleId: json["sale_id"],
      invoiceNumber: json["invoiceNumber"],
      refInvoiceNumber: json["invoice_number"],
      totalDue: json["totalDue"],
      dueAmountAfterPay: json["dueAmountAfterPay"],
      payDueAmount: json["payDueAmount"],
      paymentDate: json["paymentDate"] == null ? null : DateTime.parse(json["paymentDate"]),
      isLast: json["is_last"] == true,
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      party: json["party"] == null ? null : Party.fromJson(json["party"]),
      paymentType: json["payment_type"] == null ? null : BusinessPaymentMethod.fromJson(json["payment_type"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "party_id": partyId,
      "payment_type_id": paymentTypeId,
      "invoiceNumber": refInvoiceNumber,
      "paymentDate": paymentDate?.toIso8601String(),
      "payDueAmount": payDueAmount,
    };
  }
}

typedef DueCollectionList = PaginatedListModel<DueCollection>;

typedef DueReport = DueModel;
typedef DueReportList = PaginatedListModel<DueReport>;

typedef DueCollectionReport = DueCollection;
typedef DueCollectionReportList = PaginatedListModel<DueCollectionReport>;
