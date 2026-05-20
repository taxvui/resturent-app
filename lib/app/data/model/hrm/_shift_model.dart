part of 'hrm_model.dart';

class ShiftModel {
  final int? id;
  final String? name;
  final String? breakStatus;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? startBreakTime;
  final DateTime? endBreakTime;
  final String? breakTime;
  final bool status;
  bool get hasBreak => breakStatus == 'yes';

  const ShiftModel({
    this.id,
    this.name,
    this.breakStatus,
    this.startTime,
    this.endTime,
    this.startBreakTime,
    this.endBreakTime,
    this.breakTime,
    this.status = false,
  });

  ShiftModel copyWith({
    int? id,
    String? name,
    String? breakStatus,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? startBreakTime,
    DateTime? endBreakTime,
    String? breakTime,
    bool? status,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breakStatus: breakStatus ?? this.breakStatus,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startBreakTime: startBreakTime ?? this.startBreakTime,
      endBreakTime: endBreakTime ?? this.endBreakTime,
      breakTime: breakTime ?? this.breakTime,
      status: status ?? this.status,
    );
  }

  factory ShiftModel.event(int id) {
    return ShiftModel(id: id);
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      name: json['name'],
      breakStatus: json['break_status'],
      startTime: (json['start_time'] as String?)?.parseDate,
      endTime: (json['end_time'] as String?)?.parseDate,
      startBreakTime: (json['start_break_time'] as String?)?.parseDate,
      endBreakTime: (json['end_break_time'] as String?)?.parseDate,
      breakTime: json['break_time'],
      status: json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final _hasBreak = hasBreak;
    return {
      'id': id,
      'name': name,
      'break_status': breakStatus,
      'start_time': startTime?.timeFormat,
      'end_time': endTime?.timeFormat,
      'start_break_time': _hasBreak ? startBreakTime?.timeFormat : null,
      'end_break_time': _hasBreak ? endBreakTime?.timeFormat : null,
      'break_time': breakTime,
      'status': status ? 1 : 0,
    };
  }

  @override
  bool operator ==(Object other) => other is ShiftModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef ShiftListModel = model.PaginatedListModel<ShiftModel>;
