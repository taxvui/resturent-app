part of 'hrm_model.dart';

class LeaveModel {
  final int? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? leaveDuration;
  final String? month;
  final String? status;
  final String? description;
  final EmployeeModel? employee;
  final LeaveTypeModel? leaveType;
  final DepartmentModel? department;

  const LeaveModel({
    this.id,
    this.startDate,
    this.endDate,
    this.leaveDuration,
    this.month,
    this.status,
    this.description,
    this.employee,
    this.leaveType,
    this.department,
  });

  LeaveModel copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? leaveDuration,
    String? month,
    String? status,
    String? description,
    EmployeeModel? employee,
    LeaveTypeModel? leaveType,
    DepartmentModel? department,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      leaveDuration: leaveDuration ?? this.leaveDuration,
      month: month ?? this.month,
      status: status ?? this.status,
      description: description ?? this.description,
      employee: employee ?? this.employee,
      leaveType: leaveType ?? this.leaveType,
      department: department ?? this.department,
    );
  }

  factory LeaveModel.event(int id) {
    return LeaveModel(id: id);
  }

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      startDate: (json['start_date'] as String?)?.parseDate,
      endDate: (json['end_date'] as String?)?.parseDate,
      leaveDuration: json['leave_duration'],
      month: json['month'],
      status: json['status'],
      description: json['description'],
      employee: json['employee'] != null ? EmployeeModel.fromJson(json['employee']) : null,
      leaveType: json['leave_type'] != null ? LeaveTypeModel.fromJson(json['leave_type']) : null,
      department: json['department'] != null ? DepartmentModel.fromJson(json['department']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employee_id": employee?.id,
      "leave_type_id": leaveType?.id,
      "start_date": startDate?.dbFormat,
      "end_date": endDate?.dbFormat,
      "leave_duration": leaveDuration,
      "month": month,
      "description": description,
      "status": status,
    };
  }

  @override
  bool operator ==(Object other) => other is LeaveModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef LeaveListModel = model.PaginatedListModel<LeaveModel>;
