part of 'hrm_model.dart';

class LeaveTypeModel {
  final int? id;
  final String? name;
  final bool status;
  final String? description;

  const LeaveTypeModel({
    this.id,
    this.name,
    this.status = false,
    this.description,
  });

  LeaveTypeModel copyWith({
    int? id,
    String? name,
    bool? status,
    String? description,
  }) {
    return LeaveTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  factory LeaveTypeModel.event(int id) {
    return LeaveTypeModel(id: id);
  }

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] == 1,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "status": status ? 1 : 0,
    };
  }

  @override
  bool operator ==(Object other) => other is LeaveTypeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef LeaveTypeListModel = model.PaginatedListModel<LeaveTypeModel>;
