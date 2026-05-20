part of '_user_model.dart';

class PermissionModules {
  Permission? dashboard;
  Permission? parties;
  Permission? quotations;
  Permission? purchases;
  Permission? dueCollection;
  Permission? ingreditents;
  Permission? units;
  Permission? tables;
  Permission? areas;
  Permission? products;
  Permission? categories;
  Permission? menus;
  Permission? modifierGroups;
  Permission? itemModifiers;
  Permission? moneyIn;
  Permission? moneyOut;
  Permission? transactions;
  Permission? income;
  Permission? incomeCategory;
  Permission? expense;
  Permission? expenseCategory;
  Permission? coupon;
  Permission? vat;
  Permission? sales;
  Permission? kot;
  Permission? printingOption;
  Permission? currency;
  Permission? paymentMethod;
  Permission? salesReport;
  Permission? salesQuotationReport;
  Permission? purchaseReport;
  Permission? dueReport;
  Permission? dueCollectionReport;
  Permission? transactionReport;
  Permission? incomeReport;
  Permission? expenseReport;
  Permission? kotReport;
  Permission? department;
  Permission? designation;
  Permission? shift;
  Permission? employee;
  Permission? leaveType;
  Permission? leave;
  Permission? holiday;
  Permission? attendance;
  Permission? payroll;
  Permission? attendanceReport;
  Permission? payrollReport;
  Permission? leaveReport;

  PermissionModules({
    this.dashboard,
    this.parties,
    this.quotations,
    this.purchases,
    this.dueCollection,
    this.ingreditents,
    this.units,
    this.tables,
    this.areas,
    this.products,
    this.categories,
    this.menus,
    this.modifierGroups,
    this.itemModifiers,
    this.moneyIn,
    this.moneyOut,
    this.transactions,
    this.income,
    this.incomeCategory,
    this.expense,
    this.expenseCategory,
    this.coupon,
    this.vat,
    this.sales,
    this.kot,
    this.printingOption,
    this.currency,
    this.paymentMethod,
    this.salesReport,
    this.salesQuotationReport,
    this.purchaseReport,
    this.dueReport,
    this.dueCollectionReport,
    this.transactionReport,
    this.incomeReport,
    this.expenseReport,
    this.kotReport,
    this.department,
    this.designation,
    this.shift,
    this.employee,
    this.leaveType,
    this.leave,
    this.holiday,
    this.attendance,
    this.payroll,
    this.attendanceReport,
    this.payrollReport,
    this.leaveReport,
  });

  PermissionModules copyWith({
    Permission? dashboard,
    Permission? parties,
    Permission? quotations,
    Permission? purchases,
    Permission? dueCollection,
    Permission? ingreditents,
    Permission? units,
    Permission? tables,
    Permission? areas,
    Permission? products,
    Permission? categories,
    Permission? menus,
    Permission? modifierGroups,
    Permission? itemModifiers,
    Permission? moneyIn,
    Permission? moneyOut,
    Permission? transactions,
    Permission? income,
    Permission? incomeCategory,
    Permission? expense,
    Permission? expenseCategory,
    Permission? coupon,
    Permission? vat,
    Permission? sales,
    Permission? kot,
    Permission? printingOption,
    Permission? currency,
    Permission? paymentMethod,
    Permission? salesReport,
    Permission? salesQuotationReport,
    Permission? purchaseReport,
    Permission? dueReport,
    Permission? dueCollectionReport,
    Permission? transactionReport,
    Permission? incomeReport,
    Permission? expenseReport,
    Permission? kotReport,
    Permission? department,
    Permission? designation,
    Permission? shift,
    Permission? employee,
    Permission? leaveType,
    Permission? leave,
    Permission? holiday,
    Permission? attendance,
    Permission? payroll,
    Permission? attendanceReport,
    Permission? payrollReport,
    Permission? leaveReport,
  }) {
    return PermissionModules(
      dashboard: dashboard ?? this.dashboard,
      parties: parties ?? this.parties,
      quotations: quotations ?? this.quotations,
      purchases: purchases ?? this.purchases,
      dueCollection: dueCollection ?? this.dueCollection,
      ingreditents: ingreditents ?? this.ingreditents,
      units: units ?? this.units,
      tables: tables ?? this.tables,
      areas: areas ?? this.areas,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      menus: menus ?? this.menus,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      itemModifiers: itemModifiers ?? this.itemModifiers,
      moneyIn: moneyIn ?? this.moneyIn,
      moneyOut: moneyOut ?? this.moneyOut,
      transactions: transactions ?? this.transactions,
      income: income ?? this.income,
      incomeCategory: incomeCategory ?? this.incomeCategory,
      expense: expense ?? this.expense,
      expenseCategory: expenseCategory ?? this.expenseCategory,
      coupon: coupon ?? this.coupon,
      vat: vat ?? this.vat,
      sales: sales ?? this.sales,
      kot: kot ?? this.kot,
      printingOption: printingOption ?? this.printingOption,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      salesReport: salesReport ?? this.salesReport,
      salesQuotationReport: salesQuotationReport ?? this.salesQuotationReport,
      purchaseReport: purchaseReport ?? this.purchaseReport,
      dueReport: dueReport ?? this.dueReport,
      dueCollectionReport: dueCollectionReport ?? this.dueCollectionReport,
      transactionReport: transactionReport ?? this.transactionReport,
      incomeReport: incomeReport ?? this.incomeReport,
      expenseReport: expenseReport ?? this.expenseReport,
      kotReport: kotReport ?? this.kotReport,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      shift: shift ?? this.shift,
      employee: employee ?? this.employee,
      leaveType: leaveType ?? this.leaveType,
      leave: leave ?? this.leave,
      holiday: holiday ?? this.holiday,
      attendance: attendance ?? this.attendance,
      payroll: payroll ?? this.payroll,
      attendanceReport: attendanceReport ?? this.attendanceReport,
      payrollReport: payrollReport ?? this.payrollReport,
      leaveReport: leaveReport ?? this.leaveReport,
    );
  }

  factory PermissionModules.fromJson(Map<String, dynamic> json) {
    return PermissionModules(
      dashboard: json["dashboard"] == null ? null : Permission.fromJson(json["dashboard"]),
      parties: json["parties"] == null ? null : Permission.fromJson(json["parties"]),
      quotations: json["quotations"] == null ? null : Permission.fromJson(json["quotations"]),
      purchases: json["purchases"] == null ? null : Permission.fromJson(json["purchases"]),
      dueCollection: json["dueCollection"] == null ? null : Permission.fromJson(json["dueCollection"]),
      ingreditents: json["ingreditents"] == null ? null : Permission.fromJson(json["ingreditents"]),
      units: json["units"] == null ? null : Permission.fromJson(json["units"]),
      tables: json["tables"] == null ? null : Permission.fromJson(json["tables"]),
      areas: json["areas"] == null ? null : Permission.fromJson(json["areas"]),
      products: json["products"] == null ? null : Permission.fromJson(json["products"]),
      categories: json["categories"] == null ? null : Permission.fromJson(json["categories"]),
      menus: json["menus"] == null ? null : Permission.fromJson(json["menus"]),
      modifierGroups: json["modifierGroups"] == null ? null : Permission.fromJson(json["modifierGroups"]),
      itemModifiers: json["itemModifiers"] == null ? null : Permission.fromJson(json["itemModifiers"]),
      moneyIn: json["moneyIn"] == null ? null : Permission.fromJson(json["moneyIn"]),
      moneyOut: json["moneyOut"] == null ? null : Permission.fromJson(json["moneyOut"]),
      transactions: json["transactions"] == null ? null : Permission.fromJson(json["transactions"]),
      income: json["income"] == null ? null : Permission.fromJson(json["income"]),
      incomeCategory: json["incomeCategory"] == null ? null : Permission.fromJson(json["incomeCategory"]),
      expense: json["expense"] == null ? null : Permission.fromJson(json["expense"]),
      expenseCategory: json["expenseCategory"] == null ? null : Permission.fromJson(json["expenseCategory"]),
      coupon: json["coupon"] == null ? null : Permission.fromJson(json["coupon"]),
      vat: json["vat"] == null ? null : Permission.fromJson(json["vat"]),
      sales: json["sales"] == null ? null : Permission.fromJson(json["sales"]),
      kot: json["kot"] == null ? null : Permission.fromJson(json["kot"]),
      printingOption: json["printingOption"] == null ? null : Permission.fromJson(json["printingOption"]),
      currency: json["currency"] == null ? null : Permission.fromJson(json["currency"]),
      paymentMethod: json["paymentMethod"] == null ? null : Permission.fromJson(json["paymentMethod"]),
      salesReport: json["salesReport"] == null ? null : Permission.fromJson(json["salesReport"]),
      salesQuotationReport: json["salesQuotationReport"] == null
          ? null
          : Permission.fromJson(json["salesQuotationReport"]),
      purchaseReport: json["purchaseReport"] == null ? null : Permission.fromJson(json["purchaseReport"]),
      dueReport: json["dueReport"] == null ? null : Permission.fromJson(json["dueReport"]),
      dueCollectionReport: json["dueCollectionReport"] == null
          ? null
          : Permission.fromJson(json["dueCollectionReport"]),
      transactionReport: json["transactionReport"] == null ? null : Permission.fromJson(json["transactionReport"]),
      incomeReport: json["incomeReport"] == null ? null : Permission.fromJson(json["incomeReport"]),
      expenseReport: json["expenseReport"] == null ? null : Permission.fromJson(json["expenseReport"]),
      kotReport: json["kotReport"] == null ? null : Permission.fromJson(json["kotReport"]),
      department: json["department"] == null ? null : Permission.fromJson(json["department"]),
      designation: json["designation"] == null ? null : Permission.fromJson(json["designation"]),
      shift: json["shift"] == null ? null : Permission.fromJson(json["shift"]),
      employee: json["employee"] == null ? null : Permission.fromJson(json["employee"]),
      leaveType: json["leaveType"] == null ? null : Permission.fromJson(json["leaveType"]),
      leave: json["leave"] == null ? null : Permission.fromJson(json["leave"]),
      holiday: json["holiday"] == null ? null : Permission.fromJson(json["holiday"]),
      attendance: json["attendance"] == null ? null : Permission.fromJson(json["attendance"]),
      payroll: json["payroll"] == null ? null : Permission.fromJson(json["payroll"]),
      attendanceReport: json["attendanceReport"] == null ? null : Permission.fromJson(json["attendanceReport"]),
      payrollReport: json["payrollReport"] == null ? null : Permission.fromJson(json["payrollReport"]),
      leaveReport: json["leaveReport"] == null ? null : Permission.fromJson(json["leaveReport"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "dashboard": dashboard?.toJson(),
      "parties": parties?.toJson(),
      "quotations": quotations?.toJson(),
      "purchases": purchases?.toJson(),
      "dueCollection": dueCollection?.toJson(),
      "ingreditents": ingreditents?.toJson(),
      "units": units?.toJson(),
      "tables": tables?.toJson(),
      "areas": areas?.toJson(),
      "products": products?.toJson(),
      "categories": categories?.toJson(),
      "menus": menus?.toJson(),
      "modifierGroups": modifierGroups?.toJson(),
      "itemModifiers": itemModifiers?.toJson(),
      "moneyIn": moneyIn?.toJson(),
      "moneyOut": moneyOut?.toJson(),
      "transactions": transactions?.toJson(),
      "income": income?.toJson(),
      "incomeCategory": incomeCategory?.toJson(),
      "expense": expense?.toJson(),
      "expenseCategory": expenseCategory?.toJson(),
      "coupon": coupon?.toJson(),
      "vat": vat?.toJson(),
      "sales": sales?.toJson(),
      "kot": kot?.toJson(),
      "printingOption": printingOption?.toJson(),
      "currency": currency?.toJson(),
      "paymentMethod": paymentMethod?.toJson(),
      "salesReport": salesReport?.toJson(),
      "salesQuotationReport": salesQuotationReport?.toJson(),
      "purchaseReport": purchaseReport?.toJson(),
      "dueReport": dueReport?.toJson(),
      "dueCollectionReport": dueCollectionReport?.toJson(),
      "transactionReport": transactionReport?.toJson(),
      "incomeReport": incomeReport?.toJson(),
      "expenseReport": expenseReport?.toJson(),
      "kotReport": kotReport?.toJson(),
      "department": department?.toJson(),
      "designation": designation?.toJson(),
      "shift": shift?.toJson(),
      "employee": employee?.toJson(),
      "leaveType": leaveType?.toJson(),
      "leave": leave?.toJson(),
      "holiday": holiday?.toJson(),
      "attendance": attendance?.toJson(),
      "payroll": payroll?.toJson(),
      "attendanceReport": attendanceReport?.toJson(),
      "payrollReport": payrollReport?.toJson(),
      "leaveReport": leaveReport?.toJson(),
    };
  }

  Map<String, Permission?> get modules {
    return {
      ...toJson().map((key, value) {
        return MapEntry(
          key,
          value == null ? null : Permission.fromJson(value),
        );
      }),
    };
  }
}

class Permission {
  final bool? view;
  final bool? create;
  final bool? update;
  final bool? delete;
  final bool? viewAllData;

  const Permission({
    this.view,
    this.create,
    this.update,
    this.delete,
    this.viewAllData,
  });

  Permission copyWith({
    bool? view,
    bool? create,
    bool? update,
    bool? delete,
    bool? viewAllData,
  }) {
    return Permission(
      view: view ?? this.view,
      create: create ?? this.create,
      update: update ?? this.update,
      delete: delete ?? this.delete,
      viewAllData: viewAllData ?? this.viewAllData,
    );
  }

  static bool? _parseJsonBool(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) return null;
    final v = json[key];
    if (v == null) return null;

    if (v is String) {
      if (v == '1') return true;
      if (v == '0') return false;
      final lower = v.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }

    if (v is bool) return v;

    if (v is num) {
      if (v == 1) return true;
      if (v == 0) return false;
    }

    return null;
  }

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      view: _parseJsonBool(json, 'view'),
      create: _parseJsonBool(json, 'create'),
      update: _parseJsonBool(json, 'update'),
      delete: _parseJsonBool(json, 'delete'),
      viewAllData: _parseJsonBool(json, 'view-all-data'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (view != null) 'view': (view! ? '1' : '0'),
      if (create != null) 'create': (create! ? '1' : '0'),
      if (update != null) 'update': (update! ? '1' : '0'),
      if (delete != null) 'delete': (delete! ? '1' : '0'),
      if (viewAllData != null) 'view-all-data': (viewAllData! ? '1' : '0'),
    };
  }
}
