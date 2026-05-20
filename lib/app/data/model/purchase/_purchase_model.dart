import '../model.dart';

class PurchaseDetailsModel extends BaseDetailsModel<Purchase> {
  PurchaseDetailsModel({
    super.message,
    super.data,
  });

  factory PurchaseDetailsModel.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : Purchase.fromJson(json["data"]),
    );
  }
}

class Purchase {
  int? id;
  int? partyId;
  int? businessId;
  int? userId;
  int? paymentTypeId;
  num? discountAmount;
  num? discountPercentage;
  num? taxAmount;
  num? taxPercentage;
  num? dueAmount;
  num? paidAmount;
  num? totalAmount;
  String? invoiceNumber;
  DateTime? purchaseDate;
  BusinessPaymentMethod? paymentMethod;
  User? user;
  Party? party;
  List<PurchaseItem>? details;

  bool get isPaid => paidAmount == totalAmount && dueAmount == 0;
  bool get isPartial {
    return (paidAmount ?? 0) < (totalAmount ?? 0) && (dueAmount ?? 0) > 0;
  }

  Purchase({
    this.id,
    this.partyId,
    this.businessId,
    this.userId,
    this.paymentTypeId,
    this.discountAmount,
    this.discountPercentage,
    this.taxAmount,
    this.taxPercentage,
    this.dueAmount,
    this.paidAmount,
    this.totalAmount,
    this.invoiceNumber,
    this.purchaseDate,
    this.paymentMethod,
    this.user,
    this.party,
    this.details,
  });

  Purchase copyWith({
    int? id,
    int? partyId,
    int? businessId,
    int? userId,
    int? paymentTypeId,
    num? discountAmount,
    num? discountPercentage,
    num? taxAmount,
    num? taxPercentage,
    num? dueAmount,
    num? paidAmount,
    num? totalAmount,
    String? invoiceNumber,
    DateTime? purchaseDate,
    BusinessPaymentMethod? paymentMethod,
    User? user,
    Party? party,
    List<PurchaseItem>? details,
  }) {
    return Purchase(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      paymentTypeId: paymentTypeId ?? this.paymentTypeId,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      dueAmount: dueAmount ?? this.dueAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      user: user ?? this.user,
      party: party ?? this.party,
      details: details ?? this.details,
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json["id"],
      partyId: json["party_id"],
      businessId: json["business_id"],
      userId: json["user_id"],
      paymentTypeId: json["payment_type_id"],
      discountAmount: json["discountAmount"],
      discountPercentage: json["discountPercentage"],
      taxAmount: json["tax_amount"],
      taxPercentage: json["tax_percentage"],
      dueAmount: json["dueAmount"],
      paidAmount: json["paidAmount"],
      totalAmount: json["totalAmount"],
      invoiceNumber: json["invoiceNumber"],
      purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
      paymentMethod: json["payment_type"] == null ? null : BusinessPaymentMethod.fromJson(json["payment_type"]),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      party: json["party"] == null ? null : Party.fromJson(json["party"]),
      details:
          json["details"] == null ? [] : List<PurchaseItem>.from(json["details"]!.map((x) => PurchaseItem.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "party_id": partyId,
      "purchaseDate": purchaseDate?.toIso8601String(),
      "discountAmount": discountAmount,
      "discountPercentage": discountPercentage,
      "payment_type_id": paymentTypeId,
      "tax_amount": taxAmount,
      "tax_percentage": taxPercentage,
      "totalAmount": totalAmount,
      "dueAmount": dueAmount,
      "paidAmount": paidAmount,
      "ingredients": [...?details?.map((item) => item.toJson())]
    };
  }
}

class PurchaseItem {
  int? id;
  int? purchaseId;
  int? ingredientId;
  int? unitId;
  num? unitPrice;
  int? quantities;
  Ingredient? ingredient;
  ItemUnit? unit;

  PurchaseItem({
    this.id,
    this.purchaseId,
    this.ingredientId,
    this.unitId,
    this.unitPrice,
    this.quantities,
    this.ingredient,
    this.unit,
  });

  PurchaseItem copyWith({
    int? id,
    int? purchaseId,
    int? ingredientId,
    int? unitId,
    num? unitPrice,
    int? quantities,
    Ingredient? ingredient,
    ItemUnit? unit,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      ingredientId: ingredientId ?? this.ingredientId,
      unitId: unitId ?? this.unitId,
      unitPrice: unitPrice ?? this.unitPrice,
      quantities: quantities ?? this.quantities,
      ingredient: ingredient ?? this.ingredient,
      unit: unit ?? this.unit,
    );
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json["id"],
      purchaseId: json["purchase_id"],
      ingredientId: json["ingredient_id"],
      unitId: json["unit_id"],
      unitPrice: json["unit_price"],
      quantities: json["quantities"],
      ingredient: json["ingredient"] == null ? null : Ingredient.fromJson(json["ingredient"]),
      unit: json["unit"] == null ? null : ItemUnit.fromJson(json["unit"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ingredient_id": ingredientId,
      "unit_id": unitId,
      "unit_price": unitPrice,
      "quantities": quantities,
    };
  }
}

typedef PurchaseList = PaginatedListModel<Purchase>;

typedef PurchaseReport = Purchase;
typedef PurchaseReportList = PaginatedListModel<PurchaseReport>;
