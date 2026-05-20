part of 'hrm_model.dart';

class AttendanceModel {
  final int? id;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final DateTime? date;
  final String? duration;
  final String? month;
  final String? note;
  final EmployeeModel? employee;
  final ShiftModel? shift;

  const AttendanceModel({
    this.id,
    this.timeIn,
    this.timeOut,
    this.date,
    this.duration,
    this.month,
    this.note,
    this.employee,
    this.shift,
  });

  AttendanceModel copyWith({
    int? id,
    DateTime? timeIn,
    DateTime? timeOut,
    DateTime? date,
    String? duration,
    String? month,
    String? note,
    EmployeeModel? employee,
    ShiftModel? shift,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      month: month ?? this.month,
      note: note ?? this.note,
      employee: employee ?? this.employee,
      shift: shift ?? this.shift,
    );
  }

  factory AttendanceModel.event(int id) {
    return AttendanceModel(id: id);
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      timeIn: (json['time_in'] as String?)?.parseDate,
      timeOut: (json['time_out'] as String?)?.parseDate,
      date: (json['date'] as String?)?.parseDate,
      duration: json['duration'],
      month: json['month'],
      note: json['note'],
      employee: json['employee'] != null ? EmployeeModel.fromJson(json['employee']) : null,
      shift: json['shift'] != null ? ShiftModel.fromJson(json['shift']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time_in': timeIn?.timeFormat,
      'time_out': timeOut?.timeFormat,
      'date': date?.dbFormat,
      'duration': duration,
      'month': month,
      'note': note,
      'employee_id': employee?.id,
      'shift_id': shift?.id,
    };
  }

  @override
  bool operator ==(Object other) => other is AttendanceModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef AttendanceListModel = model.PaginatedListModel<AttendanceModel>;
