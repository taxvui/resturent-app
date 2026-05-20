class PaginatedListModel<T> {
  String? message;
  PaginatedData<T>? data;

  PaginatedListModel({this.message, this.data});

  factory PaginatedListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedListModel<T>(
      message: json["message"],
      data: json["data"] == null
          ? null
          : PaginatedData<T>.fromJson(json["data"], fromJsonT),
    );
  }
}

class PaginatedData<T> {
  int? currentPage;
  int? lastPage;
  List<T>? data;
  int? perPage;
  int? total;

  PaginatedData({
    this.currentPage,
    this.lastPage,
    this.data,
    this.perPage,
    this.total,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedData<T>(
      currentPage: json["current_page"],
      lastPage: json["last_page"],
      data: json["data"] == null
          ? []
          : List<T>.from(json["data"].map((x) => fromJsonT(x))),
      perPage: json["per_page"],
      total: json["total"],
    );
  }
}

class NonPaginatedListModel<T> {
  String? message;
  List<T>? data;

  NonPaginatedListModel({
    this.message,
    this.data,
  });

  factory NonPaginatedListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return NonPaginatedListModel(
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<T>.from(json["data"]!.map((x) => fromJsonT(x))),
    );
  }
}
