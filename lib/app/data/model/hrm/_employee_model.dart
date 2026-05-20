part of 'hrm_model.dart';

class EmployeeModel {
  final int? id;
  final core.DynamicFileType? image;
  final String? name;
  final DesignationModel? designation;
  final DepartmentModel? department;
  final String? email;
  final String? phone;
  final String? country;
  final num? salary;
  final String? gender;
  final ShiftModel? shift;
  final DateTime? dateOfBirth;
  final DateTime? joiningDate;
  final String? status;

  const EmployeeModel({
    this.id,
    this.image,
    this.name,
    this.designation,
    this.department,
    this.email,
    this.phone,
    this.country,
    this.salary,
    this.gender,
    this.shift,
    this.dateOfBirth,
    this.joiningDate,
    this.status,
  });

  EmployeeModel copyWith({
    int? id,
    core.DynamicFileType? image,
    String? name,
    DesignationModel? designation,
    DepartmentModel? department,
    String? email,
    String? phone,
    String? country,
    num? salary,
    String? gender,
    ShiftModel? shift,
    DateTime? dateOfBirth,
    DateTime? joiningDate,
    String? status,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      image: image ?? this.image,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      salary: salary ?? this.salary,
      gender: gender ?? this.gender,
      shift: shift ?? this.shift,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joiningDate: joiningDate ?? this.joiningDate,
      status: status ?? this.status,
    );
  }

  factory EmployeeModel.event(int id) {
    return EmployeeModel(id: id);
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      image: json['image'] != null ? core.DynamicFileType(remote: json['image']) : null,
      name: json['name'],
      designation: json['designation'] != null ? DesignationModel.fromJson(json['designation']) : null,
      department: json['department'] != null ? DepartmentModel.fromJson(json['department']) : null,
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      salary: json['amount'],
      gender: json['gender'],
      shift: json['shift'] != null ? ShiftModel.fromJson(json['shift']) : null,
      dateOfBirth: (json['birth_date'] as String?)?.parseDate,
      joiningDate: (json['join_date'] as String?)?.parseDate,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "image": image?.local,
      "name": name,
      "designation_id": designation?.id,
      "department_id": department?.id,
      "shift_id": shift?.id,
      "amount": salary,
      "phone": phone,
      "email": email,
      "gender": gender,
      "country": country,
      "birth_date": dateOfBirth?.dbFormat,
      "join_date": joiningDate?.dbFormat,
      "status": status,
    };
  }

  @override
  bool operator ==(Object other) => other is EmployeeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef EmployeeListModel = model.PaginatedListModel<EmployeeModel>;
