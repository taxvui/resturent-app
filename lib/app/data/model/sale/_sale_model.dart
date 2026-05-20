import '../../../core/core.dart' as core;
import '../model.dart';

part '_kot_order_model.dart';
part '_quotation_model.dart';

class SaleDetailsModel extends BaseDetailsModel<Sale> {
  SaleDetailsModel({
    super.message,
    super.data,
  });

  factory SaleDetailsModel.fromJson(Map<String, dynamic> json) {
    return SaleDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : Sale.fromJson(json["data"]),
    );
  }
}

class Sale {
  int? id;
  int? quotationId;
  int? businessId;
  int? partyId;
  int? userId;
  int? taxId;
  int? staffId;
  int? couponId;
  int? addressId;
  int? paymentTypeId;
  num? discountAmount;
  num? discountPercentage;
  String? discountType;
  num? couponAmount;
  num? couponPercentage;
  num? taxAmount;
  num? taxPercentage;
  num? dueAmount;
  num? paidAmount;
  num? totalAmount;
  num? lossProfit;
  String? invoiceNumber;
  String? salesType;
  DateTime? saleDate;
  String? status;
  SaleMeta? meta;
  DateTime? createdAt;
  DateTime? updatedAt;
  TaxModel? tax;
  Party? party;
  User? user;
  CouponModel? coupon;
  BusinessPaymentMethod? paymentMethod;
  List<SaleItem>? details;
  DeliveryAddress? deliveryAddress;
  PTable? kotTable;

  bool isKOT;
  int? tableId;

  bool get hasVat => taxPercentage != null && taxAmount != null;
  bool get hasDue => dueAmount != null && dueAmount! > 0;

  num get subtotalAmount {
    return (details ?? []).fold(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );
  }

  bool get isPaymentPending => status == 'pending';

  Sale({
    this.id,
    this.quotationId,
    this.businessId,
    this.partyId,
    this.userId,
    this.taxId,
    this.staffId,
    this.couponId,
    this.addressId,
    this.paymentTypeId,
    this.discountAmount,
    this.discountPercentage,
    this.couponAmount,
    this.couponPercentage,
    this.discountType,
    this.taxAmount,
    this.taxPercentage,
    this.dueAmount,
    this.paidAmount,
    this.totalAmount,
    this.lossProfit,
    this.invoiceNumber,
    this.salesType,
    this.saleDate,
    this.status,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.tax,
    this.party,
    this.coupon,
    this.user,
    this.paymentMethod,
    this.details,
    this.deliveryAddress,
    this.isKOT = false,
    this.tableId,
    this.kotTable,
  });

  Sale copyWith({
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
  }) {
    return Sale(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      businessId: businessId ?? this.businessId,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      taxId: taxId ?? this.taxId,
      staffId: staffId ?? this.staffId,
      // couponId: couponId ?? this.couponId,
      couponId: couponId,
      addressId: addressId ?? this.addressId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      couponAmount: couponAmount ?? this.couponAmount,
      couponPercentage: couponPercentage ?? this.couponPercentage,
      discountType: discountType ?? this.discountType,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      dueAmount: dueAmount ?? this.dueAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      lossProfit: lossProfit ?? this.lossProfit,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      salesType: salesType ?? this.salesType,
      saleDate: saleDate ?? this.saleDate,
      status: status ?? this.status,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tax: tax ?? this.tax,
      party: party ?? this.party,
      user: user ?? this.user,
      coupon: coupon ?? this.coupon,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      details: details ?? this.details,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isKOT: isKOT ?? this.isKOT,
      tableId: tableId ?? this.tableId,
      kotTable: kotTable ?? this.kotTable,
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json["id"],
      quotationId: json["quotation_id"],
      businessId: json["business_id"],
      partyId: json["party_id"],
      userId: json["user_id"],
      taxId: json["tax_id"],
      staffId: json["staff_id"],
      couponId: json["coupon_id"],
      addressId: json["address_id"],
      paymentTypeId: json["payment_type_id"],
      discountAmount: json["discountAmount"],
      discountPercentage: json["discountPercentage"],
      discountType: json["discount_type"],
      couponAmount: json["coupon_amount"],
      couponPercentage: json["coupon_percentage"],
      taxAmount: json["tax_amount"],
      taxPercentage: json["tax_percentage"],
      dueAmount: json["dueAmount"],
      paidAmount: json["paidAmount"],
      totalAmount: json["totalAmount"],
      lossProfit: json["lossProfit"],
      invoiceNumber: json["invoiceNumber"],
      salesType: json["sales_type"],
      saleDate: json["saleDate"] == null ? null : DateTime.parse(json["saleDate"]),
      status: json["status"],
      meta: json["meta"] == null ? null : SaleMeta.fromJson(json["meta"]),
      createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      tax: json["tax"] == null ? null : TaxModel.fromJson(json["tax"]),
      party: json["party"] == null ? null : Party.fromJson(json["party"]),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      paymentMethod: json["payment_type"] == null ? null : BusinessPaymentMethod.fromJson(json["payment_type"]),
      coupon: json["coupon"] == null ? null : CouponModel.fromJson(json["coupon"]),
      deliveryAddress: json['delivery_address'] == null ? null : DeliveryAddress.fromJson(json['delivery_address']),
      details: json["details"] == null ? [] : List<SaleItem>.from(json["details"]!.map((x) => SaleItem.fromJson(x))),
      tableId: json["table_id"],
      kotTable: json["table"] == null ? null : PTable.fromJson(json["table"]),
    );
  }

  factory Sale.fromQuotation(
    Quotation data, {
    bool isKOT = false,
  }) {
    return Sale(
      quotationId: data.id,
      isKOT: isKOT,
      partyId: data.partyId,
      addressId: data.addressId,
      couponId: data.couponId,
      taxId: data.taxId,
      paymentTypeId: data.paymentTypeId,
      salesType: data.salesType,
      saleDate: data.quotationDate,
      discountAmount: data.discountAmount,
      discountPercentage: data.discountPercentage,
      discountType: data.discountType,
      couponAmount: data.couponAmount,
      couponPercentage: data.couponPercentage,
      taxAmount: data.taxAmount,
      totalAmount: data.totalAmount,
      paidAmount: data.paidAmount,
      dueAmount: data.dueAmount,
      details: data.details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "is_kot": isKOT ? 1 : 0,
      "quotation_id": quotationId,
      "party_id": partyId,
      "table_id": salesType == 'dine_in' && isKOT ? tableId : null,
      "staff_id": staffId,
      "coupon_id": couponId,
      "address_id": addressId,
      "sales_type": salesType,
      "saleDate": DateTime.now().toIso8601String(),
      "discountAmount": discountAmount,
      "discountPercentage": discountPercentage,
      "discount_type": discountType,
      "coupon_percentage": couponPercentage,
      "coupon_amount": couponAmount,
      "dueAmount": dueAmount,
      "totalAmount": totalAmount,
      "paidAmount": paidAmount,
      "tax_amount": taxAmount,
      "tax_id": taxId,
      "payment_type_id": paymentTypeId,
      "meta": meta?.toJson(),
      "products": [...?details?.map((item) => item.toJson())],
    };
  }

  Map<String, dynamic> toJsonForPayment() {
    return {
      "totalAmount": totalAmount,
      "paidAmount": paidAmount,
      "discountAmount": discountAmount,
      "discountPercentage": discountPercentage,
      "discount_type": discountType,
      "coupon_percentage": couponPercentage,
      "coupon_amount": couponAmount,
      "tax_id": taxId,
      "tax_amount": taxAmount,
      "payment_type_id": paymentTypeId,
      "coupon_id": couponId,
      "meta[payment_method]": meta?.paymentType,
      "meta[tip]": meta?.tip,
      "meta[delivery_charge]": meta?.deliveryCharge,
    };
  }
}

class SaleItem {
  int? id;
  int? saleId;
  int? productId;
  num? price;
  int? quantities;
  PItem? product;
  List<PItemVariation> variations;
  String? instructions;
  List<SaleItemOption>? saleItemOptions;

  num get currentPrice {
    if (variations.isNotEmpty) {
      return variations.fold<num>(0, (p, eV) => p + (eV.price ?? 0));
    }

    return product?.salesPrice ?? 0;
  }

  SaleItem({
    this.id,
    this.saleId,
    this.productId,
    this.price,
    this.quantities,
    this.product,
    this.variations = const [],
    this.instructions,
    this.saleItemOptions,
  });

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    num? price,
    int? quantities,
    PItem? product,
    List<PItemVariation>? variations,
    String? instructions,
    List<SaleItemOption>? saleItemOptions,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      quantities: quantities ?? this.quantities,
      product: product ?? this.product,
      variations: variations ?? this.variations,
      instructions: instructions ?? this.instructions,
      saleItemOptions: saleItemOptions ?? this.saleItemOptions,
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json["id"],
      saleId: json["sale_id"],
      productId: json["product_id"],
      price: json["price"],
      quantities: json["quantities"],
      product: json["product"] == null ? null : PItem.fromJson(json["product"]),
      variations: json["variations"] == null
          ? []
          : List<PItemVariation>.from(json['variations'].map((x) => PItemVariation.fromJson(x))),
      instructions: json["instructions"],
      saleItemOptions: json["detail_options"] == null
          ? []
          : List<SaleItemOption>.from(json["detail_options"]!.map((x) => SaleItemOption.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantities": quantities,
      "sales_price": price,
      "instructions": instructions,
      "variations": variations.map((e) => e.id).toList(),
      "detail_options": saleItemOptions?.map((option) => option.toJson()).toList(),
    };
  }
}

class SaleItemOption {
  int? id;
  int? saleDetailId;
  int? optionId;
  int? modifierId;
  String? name;
  ModifierOption? modifierGroupOption;

  SaleItemOption({
    this.id,
    this.saleDetailId,
    this.optionId,
    this.modifierId,
    this.name,
    this.modifierGroupOption,
  });

  SaleItemOption copyWith({
    int? id,
    int? saleDetailId,
    int? optionId,
    int? modifierId,
    String? name,
    ModifierOption? modifierGroupOption,
  }) {
    return SaleItemOption(
      id: id ?? this.id,
      saleDetailId: saleDetailId ?? this.saleDetailId,
      optionId: optionId ?? this.optionId,
      modifierId: modifierId ?? this.modifierId,
      name: name ?? this.name,
      modifierGroupOption: modifierGroupOption ?? this.modifierGroupOption,
    );
  }

  factory SaleItemOption.fromJson(Map<String, dynamic> json) {
    return SaleItemOption(
      id: json["id"],
      saleDetailId: json["sale_detail_id"],
      optionId: json["option_id"],
      modifierId: json["modifier_id"],
      name: json["modifier_group_option"]?["modifier_group"]?["name"],
      modifierGroupOption: json["modifier_group_option"] == null
          ? null
          : ModifierOption.fromJson(json["modifier_group_option"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "modifier_id": modifierId,
      "option_id": optionId,
    };
  }
}

class SaleMeta {
  String? notes;
  String? customerPhone;
  String? address;
  num? deliveryCharge;
  num? tip;
  String? paymentType;

  SaleMeta({
    this.notes,
    this.customerPhone,
    this.address,
    this.deliveryCharge,
    this.tip,
    this.paymentType,
  });

  SaleMeta copyWith({
    String? notes,
    String? customerPhone,
    String? address,
    num? deliveryCharge,
    num? tip,
    String? paymentType,
  }) {
    return SaleMeta(
      notes: notes ?? this.notes,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      tip: tip ?? this.tip,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  factory SaleMeta.fromJson(Map<String, dynamic> json) {
    return SaleMeta(
      notes: json["notes"],
      customerPhone: json["customer_phone"],
      address: json["address"],
      deliveryCharge: json["delivery_charge"],
      tip: json["tip"],
      paymentType: json["payment_method"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "notes": notes,
      "customer_phone": customerPhone,
      "address": address,
      "delivery_charge": deliveryCharge,
      "tip": tip,
      "payment_method": paymentType,
    };
  }
}

typedef SaleList = PaginatedListModel<Sale>;

typedef SaleReport = Sale;
typedef SaleReportList = PaginatedListModel<SaleReport>;
