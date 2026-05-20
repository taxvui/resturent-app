import '../model.dart';

part '_transaction_model.dart';

class PartyDetailsModel extends BaseDetailsModel<Party> {
  PartyDetailsModel({
    super.message,
    super.data,
  });

  factory PartyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PartyDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : Party.fromJson(json["data"]),
    );
  }
}

class Party extends Equatable {
  final int? id;
  final String? name;
  final int? businessId;
  final String? email;
  final String? type;
  final String? phone;
  final num? due;
  final num? openingBalance;
  final String? address;
  final DynamicFileType? image;
  final int? status;
  final String? notes;
  final List<DeliveryAddress>? deliveryAddresses;

  const Party({
    this.id,
    this.name,
    this.businessId,
    this.email,
    this.type,
    this.phone,
    this.due,
    this.openingBalance,
    this.address,
    this.image,
    this.status,
    this.notes,
    this.deliveryAddresses,
  });

  Party copyWith({
    int? id,
    String? name,
    int? businessId,
    String? email,
    String? type,
    String? phone,
    num? due,
    num? openingBalance,
    String? address,
    DynamicFileType? image,
    int? status,
    String? notes,
    List<DeliveryAddress>? deliveryAddresses,
  }) {
    return Party(
      id: id ?? this.id,
      name: name ?? this.name,
      businessId: businessId ?? this.businessId,
      email: email ?? this.email,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      due: due ?? this.due,
      openingBalance: openingBalance ?? this.openingBalance,
      address: address ?? this.address,
      image: image ?? this.image,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
    );
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json["id"],
      name: json["name"],
      businessId: json["business_id"],
      email: json["email"],
      type: json["type"],
      phone: json["phone"],
      due: json["due"],
      openingBalance: json["opening_balance"],
      address: json["address"],
      image: json["image"] == null ? null : DynamicFileType(remote: json["image"]),
      status: json["status"],
      notes: json["notes"],
      deliveryAddresses: json["delivery_addresses"] == null
          ? null
          : List<DeliveryAddress>.from(
              json["delivery_addresses"].map((x) => DeliveryAddress.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "type": type,
      "image": image?.local,
      "email": email,
      "address": address,
      "opening_balance": openingBalance,
      "notes": notes,
      if (deliveryAddresses != null)
        for (int i = 0; i < deliveryAddresses!.length; i++) ...{
          "address_id[$i]": deliveryAddresses![i].id,
          "delivery_name[$i]": deliveryAddresses![i].name,
          "delivery_phone[$i]": deliveryAddresses![i].phone,
          "delivery_address[$i]": deliveryAddresses![i].address,
        },
    };
  }

  @override
  List<Object?> get props => [id, email];
}

class DeliveryAddress {
  int? id;
  int? partyId;
  String? name;
  String? phone;
  String? address;

  DeliveryAddress({
    this.id,
    this.partyId,
    this.name,
    this.phone,
    this.address,
  });

  DeliveryAddress copyWith({
    int? id,
    int? partyId,
    String? name,
    String? phone,
    String? address,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json["id"],
      partyId: json["party_id"],
      name: json["name"],
      phone: json["phone"],
      address: json["address"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "party_id": partyId,
      "name": name,
      "phone": phone,
      "address": address,
    };
  }
}

typedef PartyList = PaginatedListModel<Party>;

class PartyLedger {
  int? id;
  num? paidAmount;
  num? totalAmount;
  num? dueAmount;
  String? invoiceNumber;
  String? salesType;
  DateTime? saleDate;
  int? paymentTypeId;
  BusinessPaymentMethod? paymentType;
  DateTime? purchaseDate;

  PartyLedger({
    this.id,
    this.paidAmount,
    this.totalAmount,
    this.invoiceNumber,
    this.salesType,
    this.saleDate,
    this.paymentTypeId,
    this.paymentType,
    this.dueAmount,
    this.purchaseDate,
  });

  factory PartyLedger.fromJson(Map<String, dynamic> json) {
    return PartyLedger(
      id: json["id"],
      paidAmount: json["paidAmount"],
      totalAmount: json["totalAmount"],
      invoiceNumber: json["invoiceNumber"],
      salesType: json["sales_type"],
      saleDate: json["saleDate"] == null ? null : DateTime.parse(json["saleDate"]),
      paymentTypeId: json["payment_type_id"],
      paymentType: json["payment_type"] == null ? null : BusinessPaymentMethod.fromJson(json["payment_type"]),
      dueAmount: json["dueAmount"],
      purchaseDate: json["purchaseDate"] == null ? null : DateTime.parse(json["purchaseDate"]),
    );
  }
}

class PaginatedPartyLedgerListModel extends PaginatedListModel<PartyLedger> {
  PaginatedPartyLedgerListModel({super.message, super.data, this.amount});
  final num? amount;

  factory PaginatedPartyLedgerListModel.fromJson(Map<String, dynamic> json) {
    return PaginatedPartyLedgerListModel(
      message: json["message"],
      amount: json["total_purchase"] ?? json["total_sale"],
      data: json["data"] == null
          ? null
          : PaginatedData<PartyLedger>.fromJson(
              json["data"],
              (x) => PartyLedger.fromJson(x),
            ),
    );
  }
}
