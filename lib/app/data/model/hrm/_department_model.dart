part of 'hrm_model.dart';

class DepartmentModel {
  final int? id;
  final String? name;
  final bool status;
  final String? description;

  const DepartmentModel({
    this.id,
    this.name,
    this.status = false,
    this.description,
  });

  DepartmentModel copyWith({
    int? id,
    String? name,
    bool? status,
    String? description,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] == 1,
      description: json['description'],
    );
  }

  factory DepartmentModel.event(int id) {
    return DepartmentModel(id: id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status ? 1 : 0,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) => other is DepartmentModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef DepartmentListModel = model.PaginatedListModel<DepartmentModel>;
