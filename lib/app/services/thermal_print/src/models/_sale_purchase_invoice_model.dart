part of 'models.dart';

class SalePurchaseThermalInvoiceData extends ThermalPrintInvoiceData {
  bool get hasVat => vatPercent != null && vatAmount != null;
  bool get hasDiscount {
    return discountAmount != null && discountPercent != null && discountAmount! > 0 && discountPercent! > 0;
  }

  bool get hasDue => dueAmount != null && dueAmount! > 0;
  bool get hasTip => tipAmount != null && tipAmount! > 0;
  bool get hasDeliveryCharge => deliveryCharge != null && deliveryCharge! > 0;

  String? get dateTime {
    final parts = [invoiceDate, invoiceTime].where((s) => s != null && s.isNotEmpty);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  SalePurchaseThermalInvoiceData._({
    required super.user,
    required super.invoiceNumber,
    required super.invoiceDate,
    required super.invoiceTime,
    required super.billTo,
    required super.party,
    required super.vat,
    required super.items,
    required super.table,
    required super.subtotal,
    required super.discountPercent,
    required super.discountAmount,
    super.vatPercent,
    super.vatAmount,
    required super.totalAmount,
    required super.paidAmount,
    super.dueAmount,
    required super.paymentMethod,
    super.isSale = true,
    super.orderType,
    super.coupon,
    super.tipAmount,
    super.deliveryCharge,
  });

  factory SalePurchaseThermalInvoiceData.fromSale(Sale sale) {
    final _items = [
      ...?sale.details?.map((saleItem) {
        return ThermalInvoiceItemData(
          name: saleItem.product?.productName ?? "N/A",
          unitPrice: saleItem.currentPrice,
          quantity: saleItem.quantities ?? 0,
          options: [
            ...?saleItem.saleItemOptions?.map((option) {
              return (
                name: option.modifierGroupOption?.name ?? "N/A",
                price: option.modifierGroupOption?.price ?? 0,
              );
            })
          ],
        );
      })
    ];

    final _subtotalAmount = _items.fold<num>(0, (previousValue, element) {
      return previousValue + element.total;
    });

    return SalePurchaseThermalInvoiceData._(
      user: sale.user,
      invoiceNumber: sale.invoiceNumber ?? "N/A",
      invoiceDate: sale.saleDate?.getFormatedString(pattern: _dateFormat) ?? "N/A",
      invoiceTime: sale.saleDate?.getFormatedString(pattern: _timeFormat) ?? "N/A",
      billTo: sale.paymentMethod?.name != null ? "${sale.paymentMethod?.name} Sale" : "N/A",
      party: sale.party,
      vat: sale.tax,
      items: _items,
      table: sale.kotTable,
      subtotal: _subtotalAmount,
      discountAmount: sale.discountAmount ?? 0,
      discountPercent: sale.discountPercentage ?? 0,
      vatAmount: sale.taxAmount,
      vatPercent: sale.tax?.rate,
      totalAmount: sale.totalAmount ?? 0,
      paidAmount: sale.paidAmount ?? 0,
      dueAmount: sale.dueAmount,
      paymentMethod: sale.paymentMethod?.name ?? "N/A",
      orderType: OrderTypeEnum.maybeFromString(sale.salesType),
      coupon: sale.coupon == null
          ? null
          : (
              code: sale.coupon?.name,
              discountAmount: sale.couponAmount ?? 0,
              discountPercent: sale.couponPercentage ?? 0,
            ),
      tipAmount: sale.meta?.tip,
      deliveryCharge: sale.meta?.deliveryCharge,
    );
  }

  factory SalePurchaseThermalInvoiceData.fromPurchase(Purchase purchase) {
    final _items = [
      ...?purchase.details?.map((purchaseItem) {
        return ThermalInvoiceItemData(
          name: purchaseItem.ingredient?.name,
          unitPrice: purchaseItem.unitPrice ?? 0,
          quantity: purchaseItem.quantities ?? 0,
        );
      })
    ];
    final _subtotalAmount = _items.fold<num>(0, (previousValue, element) {
      return previousValue + (element.unitPrice * element.quantity);
    });

    return SalePurchaseThermalInvoiceData._(
      user: purchase.user,
      invoiceNumber: purchase.invoiceNumber ?? "N/A",
      invoiceDate: purchase.purchaseDate?.getFormatedString(pattern: _dateFormat) ?? "N/A",
      invoiceTime: purchase.purchaseDate?.getFormatedString(pattern: _timeFormat) ?? "N/A",
      billTo: purchase.paymentMethod?.name != null ? "${purchase.paymentMethod?.name} Purchase" : "N/A",
      party: purchase.party,
      vat: TaxModel(rate: purchase.taxPercentage),
      items: _items,
      table: null,
      subtotal: _subtotalAmount,
      discountPercent: purchase.discountPercentage,
      discountAmount: purchase.discountAmount,
      vatAmount: purchase.taxAmount,
      vatPercent: purchase.taxPercentage,
      totalAmount: purchase.totalAmount,
      paidAmount: purchase.paidAmount,
      dueAmount: purchase.dueAmount,
      paymentMethod: purchase.paymentMethod?.name ?? "N/A",
      isSale: false,
    );
  }

  @override
  SalePurchaseThermalInvoiceData copyWith({
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
    return SalePurchaseThermalInvoiceData._(
      user: user ?? this.user,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      billTo: billTo ?? this.billTo,
      party: party ?? this.party,
      vat: vat ?? this.vat,
      items: items ?? this.items,
      table: table ?? this.table,
      subtotal: subtotal ?? this.subtotal,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      vatPercent: vatPercent ?? this.vatPercent,
      vatAmount: vatAmount ?? this.vatAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSale: isSale ?? this.isSale,
      orderType: orderType ?? this.orderType,
      coupon: coupon ?? this.coupon,
      tipAmount: tipAmount ?? this.tipAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
    );
  }

  static const _dateFormat = "dd/MM/yyyy";
  static const _timeFormat = "hh:mm a";
}
