part of '_sale_model.dart';

class QuotationDetailsModel extends BaseDetailsModel<Quotation> {
  QuotationDetailsModel({
    super.message,
    super.data,
  });

  factory QuotationDetailsModel.fromJson(Map<String, dynamic> json) {
    return QuotationDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : Quotation.fromJson(json["data"]),
    );
  }
}

class Quotation extends Sale {
  Quotation({
    super.id,
    super.tableId,
    super.partyId,
    super.userId,
    super.addressId,
    super.taxId,
    super.isKOT,
    super.staffId,
    super.couponId,
    super.paymentTypeId,
    super.salesType,
    super.invoiceNumber,
    super.party,
    super.user,
    super.deliveryAddress,
    super.tax,
    super.coupon,
    super.discountAmount,
    super.discountPercentage,
    super.discountType,
    super.couponAmount,
    super.couponPercentage,
    super.taxAmount,
    super.totalAmount,
    super.paidAmount,
    super.dueAmount,
    super.meta,
    super.details,
    super.paymentMethod,
    DateTime? quotationDate,
    this.quotationStatus,
  }) : quotationDate = quotationDate ?? DateTime.now();

  DateTime? quotationDate;
  String? quotationStatus;

  @override
  DateTime? get saleDate => quotationDate;

  @override
  Quotation copyWith({
    int? id,
    int? quotationId,
    int? businessId,
    int? partyId,
    int? userId,
    int? taxId,
    int? staffId,
    int? couponId,
    int? addressId,
    int? paymentTypeId,
    num? discountAmount,
    num? discountPercentage,
    num? couponAmount,
    num? couponPercentage,
    String? discountType,
    num? taxAmount,
    num? taxPercentage,
    num? dueAmount,
    num? paidAmount,
    num? totalAmount,
    num? lossProfit,
    String? invoiceNumber,
    String? salesType,
    DateTime? saleDate,
    String? status,
    SaleMeta? meta,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaxModel? tax,
    Party? party,
    User? user,
    CouponModel? coupon,
    BusinessPaymentMethod? paymentMethod,
    List<SaleItem>? details,
    bool? isKOT,
    int? tableId,
    DeliveryAddress? deliveryAddress,
    PTable? kotTable,
    DateTime? quotationDate,
    String? quotationStatus,
  }) {
    return Quotation(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      taxId: taxId ?? this.taxId,
      isKOT: isKOT ?? this.isKOT,
      staffId: staffId ?? this.staffId,
      couponId: couponId ?? this.couponId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      salesType: salesType ?? this.salesType,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      party: party ?? this.party,
      user: user ?? this.user,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      tax: tax ?? this.tax,
      coupon: coupon ?? this.coupon,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountType: discountType ?? this.discountType,
      couponAmount: couponAmount ?? this.couponAmount,
      couponPercentage: couponPercentage ?? this.couponPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      meta: meta ?? this.meta,
      details: details ?? this.details,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      quotationDate: quotationDate ?? this.quotationDate,
      quotationStatus: quotationStatus ?? this.quotationStatus,
    );
  }

  factory Quotation.fromSale(Sale sale) {
    return Quotation(
      id: sale.id,
      tableId: sale.tableId,
      partyId: sale.partyId,
      userId: sale.userId,
      addressId: sale.addressId,
      taxId: sale.taxId,
      isKOT: sale.isKOT,
      staffId: sale.staffId,
      couponId: sale.couponId,
      paymentTypeId: sale.paymentTypeId,
      invoiceNumber: sale.invoiceNumber,
      party: sale.party,
      user: sale.user,
      deliveryAddress: sale.deliveryAddress,
      tax: sale.tax,
      coupon: sale.coupon,
      discountAmount: sale.discountAmount,
      discountPercentage: sale.discountPercentage,
      discountType: sale.discountType,
      couponAmount: sale.couponAmount,
      couponPercentage: sale.couponPercentage,
      taxAmount: sale.taxAmount,
      totalAmount: sale.totalAmount,
      paidAmount: sale.paidAmount,
      dueAmount: sale.dueAmount,
      meta: sale.meta,
      details: sale.details,
      paymentMethod: sale.paymentMethod,
    );
  }

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'],
      tableId: json['table_id'],
      partyId: json['party_id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      taxId: json['tax_id'],
      staffId: json['staff_id'],
      couponId: json['coupon_id'],
      paymentTypeId: json['payment_type_id'],
      invoiceNumber: json['invoiceNumber'],
      party: json['party'] != null ? Party.fromJson(json['party']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      deliveryAddress: json['delivery_address'] != null ? DeliveryAddress.fromJson(json['delivery_address']) : null,
      tax: json['tax'] != null ? TaxModel.fromJson(json['tax']) : null,
      coupon: json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null,
      discountAmount: json['discountAmount'],
      discountPercentage: json['discountPercentage'],
      discountType: json['discount_type'],
      couponAmount: json['coupon_amount'],
      couponPercentage: json['coupon_percentage'],
      taxAmount: json['tax_amount'],
      totalAmount: json['totalAmount'],
      paidAmount: json['paidAmount'],
      dueAmount: json['dueAmount'],
      meta: json['meta'] != null ? SaleMeta.fromJson(json['meta']) : null,
      details: json["details"] == null ? [] : List<SaleItem>.from(json["details"]!.map((x) => SaleItem.fromJson(x))),
      paymentMethod: json['payment_type'] == null ? null : BusinessPaymentMethod.fromJson(json['payment_type']),
      quotationDate: json['quotationDate'] == null ? null : DateTime.parse(json['quotationDate']),
      quotationStatus: json['status'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "party_id": partyId,
      "coupon_id": couponId,
      "payment_type_id": paymentTypeId,
      "quotationDate": quotationDate?.toIso8601String(),
      "discountAmount": discountAmount,
      "discountPercentage": discountPercentage,
      "discount_type": discountType,
      "coupon_amount": couponAmount,
      "coupon_percentage": couponPercentage,
      "tax_amount": taxAmount,
      "tax_id": taxId,
      "totalAmount": totalAmount,
      "dueAmount": dueAmount,
      "paidAmount": paidAmount,
      "products": [...?details?.map((item) => item.toJson())],
      "meta": meta?.toJson(),
    };
  }
}

typedef QuotationList = PaginatedListModel<Quotation>;
typedef QuotationReport = Quotation;
typedef QuotationReportList = PaginatedListModel<Quotation>;
