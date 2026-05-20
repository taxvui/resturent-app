part of '_sale_model.dart';

class KOTOrder extends Sale {
  KOTOrder({
    super.id,
    super.invoiceNumber,
    this.kotInvoiceNumber,
    this.itemCount = 0,
    super.kotTable,
    super.saleDate,
    super.party,
    this.orderStatus = core.KotOrderStatus.pending,
    List<KOTOrderItem>? details,
    this.cancelReason,
    this.cancelNotes,
    this.isOnlineOrder = false,
  }) : _details = details;

  final int itemCount;
  final String? kotInvoiceNumber;
  final core.KotOrderStatus orderStatus;
  final List<KOTOrderItem>? _details;
  final bool isOnlineOrder;

  @override
  List<KOTOrderItem>? get details => _details;
  final String? cancelReason;
  final String? cancelNotes;

  factory KOTOrder.fromJson(Map<String, dynamic> json) {
    return KOTOrder(
      id: json['id'],
      invoiceNumber: json['bill_no'],
      kotInvoiceNumber: json['kot_number'],
      itemCount: json['total_item'],
      kotTable: json['table'] != null ? PTable.fromJson(json['table']) : null,
      saleDate: json['sale']?['saleDate'] != null ? DateTime.parse(json['sale']?['saleDate']) : null,
      party: json['sale']?['party'] != null ? Party.fromJson(json['sale']?['party']) : null,
      orderStatus: core.KotOrderStatus.fromString(json['status']),
      details: json['details'] != null
          ? List<KOTOrderItem>.from(json['details']!.map((x) => KOTOrderItem.fromJson(x)))
          : null,
      cancelReason: json['cancel_reason']?['reason'],
      cancelNotes: json['notes'],
      isOnlineOrder: json['business_gateway_id'] != null,
    );
  }
}

class KOTOrderItem extends SaleItem {
  KOTOrderItem({
    super.id,
    super.quantities,
    super.product,
    this.status = core.KotItemStatus.pending,
    super.saleItemOptions,
    super.variations,
  });

  final core.KotItemStatus status;

  factory KOTOrderItem.fromJson(Map<String, dynamic> json) {
    return KOTOrderItem(
      id: json['id'],
      quantities: json['quantities'],
      product: json['product'] != null ? PItem.fromJson(json['product']) : null,
      status: core.KotItemStatus.fromString(json['cooking_status']),
      saleItemOptions: json["detail_options"] == null
          ? []
          : List<SaleItemOption>.from(json["detail_options"]!.map((x) => SaleItemOption.fromJson(x))),
      variations: json["variations"] == null
          ? []
          : List<PItemVariation>.from(json['variations'].map((x) => PItemVariation.fromJson(x))),
    );
  }
}

typedef KotOrderStatusData = ({int pendingCount, int preparingCount, int readyCount, int cancelledCount});

class KOTOrderList extends PaginatedListModel<KOTOrder> {
  KOTOrderList({
    super.message,
    super.data,
    this.statusCount = (pendingCount: 0, preparingCount: 0, readyCount: 0, cancelledCount: 0),
  });

  final KotOrderStatusData statusCount;

  factory KOTOrderList.fromJson(Map<String, dynamic> json) {
    return KOTOrderList(
      message: json["message"],
      data: json["data"] == null ? null : PaginatedData<KOTOrder>.fromJson(json["data"], (x) => KOTOrder.fromJson(x)),
      statusCount: (
        pendingCount: json['status_count']?['pending'] ?? 0,
        preparingCount: json['status_count']?['preparing'] ?? 0,
        readyCount: json['status_count']?['ready'] ?? 0,
        cancelledCount: json['status_count']?['cancelled'] ?? 0,
      ),
    );
  }
}

class OrderCancelReasonModel {
  final int? id;
  final String? type;
  final String? reason;

  OrderCancelReasonModel({
    this.id,
    this.type,
    this.reason,
  });

  factory OrderCancelReasonModel.fromJson(Map<String, dynamic> json) {
    return OrderCancelReasonModel(
      id: json['id'],
      type: json['type'],
      reason: json['reason'],
    );
  }
}
