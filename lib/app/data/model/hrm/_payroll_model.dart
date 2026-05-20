part of 'hrm_model.dart';

class PayrollModel {
  final int? id;
  final String? month;
  final String? puid;
  final DateTime? date;
  final num? amount;
  final String? paymentYear;
  final String? note;
  final EmployeeModel? employee;
  final model.BusinessPaymentMethod? paymentType;

  const PayrollModel({
    this.id,
    this.month,
    this.puid,
    this.date,
    this.amount,
    this.paymentYear,
    this.note,
    this.employee,
    this.paymentType,
  });

  PayrollModel copyWith({
    int? id,
    String? month,
    String? puid,
    DateTime? date,
    num? amount,
    String? paymentYear,
    String? note,
    EmployeeModel? employee,
    model.BusinessPaymentMethod? paymentType,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      month: month ?? this.month,
      puid: puid ?? this.puid,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      paymentYear: paymentYear ?? this.paymentYear,
      note: note ?? this.note,
      employee: employee ?? this.employee,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  factory PayrollModel.event(int id) {
    return PayrollModel(id: id);
  }

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'],
      month: json['month'],
      puid: json['puid'],
      date: (json['date'] as String?)?.parseDate,
      amount: json['amount'],
      paymentYear: json['payment_year'],
      note: json['note'],
      employee: json['employee'] != null ? EmployeeModel.fromJson(json['employee']) : null,
      paymentType: json['payment_type'] != null ? model.BusinessPaymentMethod.fromJson(json['payment_type']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employee_id": employee?.id,
      "payment_type_id": paymentType?.id,
      "month": month,
      "date": date?.dbFormat,
      "payment_year": paymentYear,
      "note": note,
    };
  }

  @override
  bool operator ==(Object other) => other is PayrollModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef PayrollListModel = model.PaginatedListModel<PayrollModel>;
