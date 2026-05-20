class SummerNoteModel {
  String? message;
  Data? data;

  SummerNoteModel({
    this.message,
    this.data,
  });

  SummerNoteModel copyWith({
    String? message,
    Data? data,
  }) =>
      SummerNoteModel(
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory SummerNoteModel.fromJson(Map<String, dynamic> json) =>
      SummerNoteModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? id;
  String? key;
  Value? value;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.key,
    this.value,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Data copyWith({
    int? id,
    String? key,
    Value? value,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Data(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        key: json["key"],
        value: json["value"] == null ? null : Value.fromJson(json["value"]),
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value?.toJson(),
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Value {
  String? description;

  Value({
    this.description,
  });

  Value copyWith({
    String? description,
  }) =>
      Value(
        description: description ?? this.description,
      );

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
      };
}
