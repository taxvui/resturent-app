import '../model.dart';

class StaffModel {
  int? id;
  int? businessId;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? designation;

  StaffModel({
    this.id,
    this.businessId,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.designation,
  });

  StaffModel copyWith({
    int? id,
    int? businessId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? designation,
  }) {
    return StaffModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      designation: designation ?? this.designation,
    );
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json["id"],
      businessId: json["business_id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      address: json["address"],
      designation: json["designation"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "designation": designation,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is StaffModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

typedef StaffList = PaginatedListModel<StaffModel>;

class PermittedStaffDetails extends BaseDetailsModel<PermittedStaff> {
  PermittedStaffDetails({super.message, super.data});

  factory PermittedStaffDetails.fromJson(Map<String, dynamic> json) {
    return PermittedStaffDetails(
      message: json["message"],
      data: json["data"] == null ? null : PermittedStaff.fromJson(json["data"]),
    );
  }
}

class PermittedStaff extends User {
  const PermittedStaff({
    super.id,
    super.businessId,
    this.staffId,
    super.email,
    super.name,
    super.role,
    super.phone,
    super.permissions,
    this.staff,
    this.password,
  });

  final int? staffId;
  final StaffModel? staff;
  final String? password;

  factory PermittedStaff.fromJson(Map<String, dynamic> json) {
    final _user = User.fromJson(json);

    return PermittedStaff(
      id: _user.id,
      businessId: _user.businessId,
      email: _user.email,
      name: _user.name,
      role: _user.role,
      phone: _user.phone,
      permissions: _user.permissions,
      staffId: json["staff_id"],
      staff: json["staff"] == null ? null : StaffModel.fromJson(json["staff"]),
    );
  }

  @override
  PermittedStaff copyWith({
    int? id,
    int? businessId,
    DynamicFileType? image,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? lang,
    String? status,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Business? business,
    Currency? businessCurrency,
    PermissionModules? permissions,
    DynamicFileType? invoiceLogo,
    String? invoiceNoteLabel,
    String? invoiceNote,
    String? gratitudeMessage,
    ThermalPrinterPaperSize? invoiceSize,
    int? staffId,
    StaffModel? staff,
    String? password,
  }) {
    return PermittedStaff(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      staffId: staffId ?? this.staffId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      staff: staff ?? this.staff,
      password: password ?? this.password,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final _cleanedPermissions = permissions?.toJson()?..removeWhere((key, value) => value == null);

    return {
      "staff_id": staffId,
      "email": email,
      if (password != null && password?.isNotEmpty == true) "password": password,
      "visibility": _cleanedPermissions,
    };
  }

  @override
  List<Object?> get props => [...super.props, staffId];
}

typedef PermittedStaffList = PaginatedListModel<PermittedStaff>;
