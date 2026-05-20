class SummerNoteModel2 {
  String? message;
  SummerNoteData? data;

  SummerNoteModel2({
    this.message,
    this.data,
  });

  factory SummerNoteModel2.fromJson(Map<String, dynamic> json) =>
      SummerNoteModel2(
        message: json["message"],
        data:
            json["data"] == null ? null : SummerNoteData.fromJson(json["data"]),
      );
}

class SummerNoteData {
  int? id;
  String? key;
  Value? value;
  int? status;

  SummerNoteData({
    this.id,
    this.key,
    this.value,
    this.status,
  });

  factory SummerNoteData.fromJson(Map<String, dynamic> json) => SummerNoteData(
        id: json["id"],
        key: json["key"],
        value: json["value"] == null ? null : Value.fromJson(json["value"]),
        status: json["status"],
      );
}

class Value {
  String? title;
  String? descriptionOne;
  String? descriptionTwo;

  Value({
    this.title,
    this.descriptionOne,
    this.descriptionTwo,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        title: json["privacy_title"] ?? json["term_title"],
        descriptionOne: json["description_one"],
        descriptionTwo: json["description_two"],
      );
}
