import '../model.dart';

class Income {
  int? id;
  num? amount;
  int? incomeCategoryId;
  int? userId;
  int? businessId;
  String? incomeFor;
  int? paymentTypeId;
  String? referenceNo;
  String? note;
  DateTime? incomeDate;
  IncomeCategory? category;

  Income({
    this.id,
    this.amount,
    this.incomeCategoryId,
    this.userId,
    this.businessId,
    this.incomeFor,
    this.paymentTypeId,
    this.referenceNo,
    this.note,
    this.incomeDate,
    this.category,
  });

  Income copyWith({
    int? id,
    num? amount,
    int? incomeCategoryId,
    int? userId,
    int? businessId,
    String? incomeFor,
    int? paymentTypeId,
    String? referenceNo,
    String? note,
    DateTime? incomeDate,
    IncomeCategory? category,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      incomeCategoryId: incomeCategoryId ?? this.incomeCategoryId,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      incomeFor: incomeFor ?? this.incomeFor,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      referenceNo: referenceNo ?? this.referenceNo,
      note: note ?? this.note,
      incomeDate: incomeDate ?? this.incomeDate,
      category: category ?? this.category,
    );
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json["id"],
      amount: json["amount"],
      incomeCategoryId: json["income_category_id"],
      userId: json["user_id"],
      businessId: json["business_id"],
      incomeFor: json["incomeFor"],
      paymentTypeId: json["payment_type_id"],
      referenceNo: json["referenceNo"],
      note: json["note"],
      incomeDate: json["incomeDate"] == null
          ? null
          : DateTime.parse(json["incomeDate"]),
      category: json["category"] == null
          ? null
          : IncomeCategory.fromJson(json["category"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "income_category_id": incomeCategoryId,
      "incomeFor": incomeFor,
      "payment_type_id": paymentTypeId,
      "incomeDate": DateTime.now(),
      "note": note,
    };
  }
}

class IncomeCategory extends Equatable {
  final int? id;
  final String? categoryName;
  final int? businessId;
  final bool? status;

  const IncomeCategory({
    this.id,
    this.categoryName,
    this.businessId,
    this.status,
  });

  IncomeCategory copyWith({
    int? id,
    String? categoryName,
    int? businessId,
    bool? status,
  }) {
    return IncomeCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      businessId: businessId ?? this.businessId,
      status: status ?? this.status,
    );
  }

  factory IncomeCategory.fromJson(Map<String, dynamic> json) {
    return IncomeCategory(
      id: json["id"],
      categoryName: json["categoryName"],
      businessId: json["business_id"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "categoryName": categoryName,
      "status": true,
    };
  }

  @override
  List<Object?> get props => [id];
}

typedef IncomeList = PaginatedListModel<Income>;
typedef IncomeCategoryList = PaginatedListModel<IncomeCategory>;

typedef IncomeReport = Income;
typedef IncomeReportList = PaginatedListModel<IncomeReport>;
