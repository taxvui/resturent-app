import '../model.dart';

class PTableDetailsModel extends BaseDetailsModel<PTable> {
  PTableDetailsModel({
    super.message,
    super.data,
  });

  factory PTableDetailsModel.fromJson(Map<String, dynamic> json) {
    return PTableDetailsModel(
      message: json["message"],
      data: json["data"] == null ? null : PTable.fromJson(json["data"]),
    );
  }
}

class PTable extends Equatable {
  final int? id;
  final int? businessId;
  final int? areaId;
  final String? name;
  final int? capacity;
  final int? activeStatus;
  final int? isBooked;

  TableStatus get status {
    if (isBooked == 1) {
      return TableStatus.hold;
    }
    return TableStatus.empty;
  }

  const PTable({
    this.id,
    this.businessId,
    this.areaId,
    this.name,
    this.capacity,
    this.activeStatus,
    this.isBooked,
  });

  PTable copyWith({
    int? id,
    int? businessId,
    int? areaId,
    String? name,
    int? capacity,
    int? activeStatus,
    int? isBooked,
  }) {
    return PTable(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      activeStatus: activeStatus ?? this.activeStatus,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  factory PTable.fromJson(Map<String, dynamic> json) {
    return PTable(
      id: json["id"],
      businessId: json["business_id"],
      areaId: json["area_id"],
      name: json["name"],
      capacity: json["capacity"],
      activeStatus: json["status"],
      isBooked: json["is_booked"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "capacity": capacity,
      "area_id": areaId,
      "status": activeStatus,
    };
  }

  @override
  List<Object?> get props => [id];
}

typedef TableList = PaginatedListModel<PTable>;

class AreaModel {
  final int? id;
  final int? businessId;
  final String? name;
  final int? totalTable;

  AreaModel({
    this.id,
    this.businessId,
    this.name,
    this.totalTable,
  });

  AreaModel copyWith({String? name}) {
    return AreaModel(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      totalTable: totalTable,
    );
  }

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json["id"],
      businessId: json["business_id"],
      name: json["name"],
      totalTable: json["total_table"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name};
  }
}

typedef AreaList = PaginatedListModel<AreaModel>;
