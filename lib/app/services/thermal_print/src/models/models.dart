import '../../../../data/model/model.dart';
import '../../../../pages/user/orders/components/components.dart' show OrderTypeEnum;

part '_sale_purchase_invoice_model.dart';
part '_due_collection_invoice_model.dart';

class ThermalPrintInvoiceData {
  final User? user;
  final Party? party;

  // Invoice Identifiers
  final String? invoiceNumber;
  final String? parentInvoiceNumber;

  // Date & Time
  final String? invoiceDate;
  final String? invoiceTime;

  // Parties & Billing
  final String? billTo;

  // Tax & Table
  final TaxModel? vat;
  final PTable? table;

  // Items
  final List<ThermalInvoiceItemData>? items;

  // Amounts
  final num? subtotal;
  final num? discountPercent;
  final num? discountAmount;
  final num? vatPercent;
  final num? vatAmount;
  final num? totalAmount;
  final num? totalDue;
  final num? paidAmount;
  final num? dueAmount;
  final num? remainingDueAmount;
  final num? tipAmount;
  final num? deliveryCharge;

  // Payment & Order
  final String? paymentMethod;
  final bool isSale;
  final bool isPurchaseDue;
  final OrderTypeEnum? orderType;
  final CouponData? coupon;

  const ThermalPrintInvoiceData({
    this.user,
    this.party,
    this.invoiceNumber,
    this.parentInvoiceNumber,
    this.invoiceDate,
    this.invoiceTime,
    this.billTo,
    this.vat,
    this.table,
    this.items,
    this.subtotal,
    this.discountPercent,
    this.discountAmount,
    this.vatPercent,
    this.vatAmount,
    this.totalAmount,
    this.totalDue,
    this.paidAmount,
    this.dueAmount,
    this.remainingDueAmount,
    this.tipAmount,
    this.deliveryCharge,
    this.paymentMethod,
    this.isSale = false,
    this.isPurchaseDue = false,
    this.orderType,
    this.coupon,
  });

  ThermalPrintInvoiceData copyWith({
    User? user,
    Party? party,

    // Invoice Identifiers
    String? invoiceNumber,
    String? parentInvoiceNumber,

    // Date & Time
    String? invoiceDate,
    String? invoiceTime,

    // Parties & Billing
    String? billTo,

    // Tax & Table
    TaxModel? vat,
    PTable? table,

    // Items
    List<ThermalInvoiceItemData>? items,

    // Amounts
    num? subtotal,
    num? discountPercent,
    num? discountAmount,
    num? vatPercent,
    num? vatAmount,
    num? totalAmount,
    num? totalDue,
    num? paidAmount,
    num? dueAmount,
    num? remainingDueAmount,
    num? tipAmount,
    num? deliveryCharge,

    // Payment & Order
    String? paymentMethod,
    bool? isSale,
    bool? isPurchaseDue,
    OrderTypeEnum? orderType,
    CouponData? coupon,
  }) {
    return ThermalPrintInvoiceData(
      user: user ?? this.user,
      party: party ?? this.party,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      parentInvoiceNumber: parentInvoiceNumber ?? this.parentInvoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      billTo: billTo ?? this.billTo,
      vat: vat ?? this.vat,
      table: table ?? this.table,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      vatPercent: vatPercent ?? this.vatPercent,
      vatAmount: vatAmount ?? this.vatAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      totalDue: totalDue ?? this.totalDue,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      remainingDueAmount: remainingDueAmount ?? this.remainingDueAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSale: isSale ?? this.isSale,
      isPurchaseDue: isPurchaseDue ?? this.isPurchaseDue,
      orderType: orderType ?? this.orderType,
      coupon: coupon ?? this.coupon,
    );
  }
}

typedef CouponData = ({String? code, num discountPercent, num discountAmount});

class ThermalInvoiceItemData {
  final String? name;
  final num unitPrice;
  final int quantity;
  final List<({String name, num price})> options;

  const ThermalInvoiceItemData({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.options = const [],
  });
  num get total {
    final _optionsSum = options.fold<num>(
      0,
      (p, eV) => p + eV.price,
    );

    return (unitPrice + _optionsSum) * quantity;
  }
}
