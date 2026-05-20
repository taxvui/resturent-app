part of 'hrm_model.dart';

class HolidayModel {
  final int? id;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  const HolidayModel({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.description,
  });

  HolidayModel copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  }) {
    return HolidayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }

  factory HolidayModel.event(int id) {
    return HolidayModel(id: id);
  }

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'],
      name: json['name'],
      startDate: (json['start_date'] as String?)?.parseDate,
      endDate: (json['end_date'] as String?)?.parseDate,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate?.dbFormat,
      'end_date': endDate?.dbFormat,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) => other is HolidayModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef HolidayListModel = model.PaginatedListModel<HolidayModel>;
