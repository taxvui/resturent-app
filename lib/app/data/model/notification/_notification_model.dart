import '../model.dart' as model;

class NotificationModel {
  final String? id;
  final String? type;
  final int? refId;
  final String? title;
  final String? message;
  final DateTime? createdAt;
  final DateTime? readAt;

  NotificationModel({
    this.id,
    this.type,
    this.refId,
    this.title,
    this.message,
    this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      refId: json['notifiable_id'],
      title: json['data']?['message'], // TODO: Fix this later
      // message: json['data']?['message'], // TODO: Fix this later
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at']),
      readAt: json['read_at'] == null ? null : DateTime.tryParse(json['read_at']),
    );
  }
}

typedef NotificationListModel<T extends NotificationModel> = model.PaginatedListModel<T>;
