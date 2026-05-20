import '../model.dart';

class Expense {
  int? id;
  num? amount;
  int? expenseCategoryId;
  int? userId;
  int? businessId;
  String? expanseFor;
  int? paymentTypeId;
  String? referenceNo;
  String? note;
  DateTime? expenseDate;
  ExpenseCategory? category;

  Expense({
    this.id,
    this.amount,
    this.expenseCategoryId,
    this.userId,
    this.businessId,
    this.expanseFor,
    this.paymentTypeId,
    this.referenceNo,
    this.note,
    this.expenseDate,
    this.category,
  });

  Expense copyWith({
    int? id,
    num? amount,
    int? expenseCategoryId,
    int? userId,
    int? businessId,
    String? expanseFor,
    int? paymentTypeId,
    String? referenceNo,
    String? note,
    DateTime? expenseDate,
    ExpenseCategory? category,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      expanseFor: expanseFor ?? this.expanseFor,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      referenceNo: referenceNo ?? this.referenceNo,
      note: note ?? this.note,
      expenseDate: expenseDate ?? this.expenseDate,
      category: category ?? this.category,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["id"],
      amount: json["amount"],
      expenseCategoryId: json["expense_category_id"],
      userId: json["user_id"],
      businessId: json["business_id"],
      expanseFor: json["expanseFor"],
      paymentTypeId: json["payment_type_id"],
      referenceNo: json["referenceNo"],
      note: json["note"],
      expenseDate: json["expenseDate"] == null
          ? null
          : DateTime.parse(json["expenseDate"]),
      category: json["category"] == null
          ? null
          : ExpenseCategory.fromJson(json["category"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "expense_category_id": expenseCategoryId,
      "expanseFor": expanseFor,
      "payment_type_id": paymentTypeId,
      // "referenceNo":
      "expenseDate": DateTime.now(),
      "note": note,
    };
  }
}

class ExpenseCategory extends Equatable {
  final int? id;
  final String? categoryName;
  final int? businessId;
  final bool? status;

  const ExpenseCategory({
    this.id,
    this.categoryName,
    this.businessId,
    this.status,
  });

  ExpenseCategory copyWith({
    int? id,
    String? categoryName,
    int? businessId,
    bool? status,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      businessId: businessId ?? this.businessId,
      status: status ?? this.status,
    );
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
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

typedef ExpenseList = PaginatedListModel<Expense>;
typedef ExpenseCategoryList = PaginatedListModel<ExpenseCategory>;

typedef ExpenseReport = Expense;
typedef ExpenseReportList = PaginatedListModel<ExpenseReport>;
