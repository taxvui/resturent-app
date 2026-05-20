// Common Used Package Export
export 'package:equatable/equatable.dart';
export '../../core/core.dart'
    show DynamicFileType, TableStatus, ThermalPrinterPaperSize, StringFormatterExtension, DateHelperExtension, UserRole;

export 'user/_user_model.dart';
export 'items/_items_model.dart';
export 'ingredient/_ingredient_model.dart';
export 'party/_party_model.dart';
export 'paginate_list/_paginate_list_model.dart';
export 'tax/_tax_model.dart';
export 'income/_income_model.dart';
export 'expense/_expense_model.dart';
export 'table/_table_model.dart';
export 'common/common_model.dart';
export 'sale/_sale_model.dart';
export 'purchase/_purchase_model.dart';
export 'business_payment_method/_business_payment_method_model.dart';
export 'due/_due_model.dart';
export 'staff/_staff_model.dart';
export 'coupon/_coupon_model.dart';
export 'notification/_notification_model.dart';
export 'hrm/hrm_model.dart';
export 'kitchen/_kitchen_model.dart';

abstract class BaseDetailsModel<T> {
  String? message;
  T? data;

  BaseDetailsModel({
    this.message,
    this.data,
  });
}
