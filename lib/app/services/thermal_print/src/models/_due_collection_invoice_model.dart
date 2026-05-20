part of 'models.dart';

class DueCollectionThermalInvoiceData extends ThermalPrintInvoiceData {
  DueCollectionThermalInvoiceData._({
    required super.user,
    required super.party,
    required super.invoiceNumber,
    required super.parentInvoiceNumber,
    required super.invoiceDate,
    required super.invoiceTime,
    required super.totalDue,
    required super.paidAmount,
    required super.remainingDueAmount,
    required super.paymentMethod,
    required super.isPurchaseDue,
  });

  factory DueCollectionThermalInvoiceData.fromDueCollect(DueCollection data) {
    return DueCollectionThermalInvoiceData._(
      invoiceDate: data.paymentDate?.getFormatedString(pattern: "dd/MM/yyyy"),
      invoiceTime: data.paymentDate?.getFormatedString(pattern: "hh:mm a"),
      invoiceNumber: data.invoiceNumber,
      parentInvoiceNumber: data.refInvoiceNumber,
      party: data.party,
      totalDue: data.totalDue,
      paidAmount: data.payDueAmount,
      remainingDueAmount: data.dueAmountAfterPay,
      paymentMethod: data.paymentType?.name,
      user: data.user,
      isPurchaseDue: data.saleId == null,
    );
  }

  @override
  DueCollectionThermalInvoiceData copyWith({
    User? user,
    Party? party,
    String? invoiceNumber,
    String? parentInvoiceNumber,
    String? invoiceDate,
    String? invoiceTime,
    String? billTo,
    TaxModel? vat,
    PTable? table,
    List<ThermalInvoiceItemData>? items,
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
    String? paymentMethod,
    bool? isSale,
    bool? isPurchaseDue,
    OrderTypeEnum? orderType,
    CouponData? coupon,
  }) {
    return DueCollectionThermalInvoiceData._(
      user: user ?? this.user,
      party: party ?? this.party,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      parentInvoiceNumber: parentInvoiceNumber ?? this.parentInvoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      totalDue: totalDue ?? this.totalDue,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingDueAmount: remainingDueAmount ?? this.remainingDueAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPurchaseDue: isPurchaseDue ?? this.isPurchaseDue,
    );
  }
}
