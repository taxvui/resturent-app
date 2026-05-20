part of 'hrm_model.dart';

class DesignationModel {
  final int? id;
  final String? name;
  final bool status;
  final String? description;

  const DesignationModel({
    this.id,
    this.name,
    this.status = false,
    this.description,
  });

  DesignationModel copyWith({
    int? id,
    String? name,
    bool? status,
    String? description,
  }) {
    return DesignationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  factory DesignationModel.event(int id) {
    return DesignationModel(id: id);
  }

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'],
      name: json['name'],
      status: json['status'] == 1,
      description: json['description'],
    );
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
  bool operator ==(Object other) => other is DesignationModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef DesignationListModel = model.PaginatedListModel<DesignationModel>;
