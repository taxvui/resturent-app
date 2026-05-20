import '../model.dart';
import '../../../core/core.dart' as core;
// ignore: library_prefixes
import '../../../services/thermal_print/_thermal_print_service.dart' as tUtil;

part '_auth_model.dart';
part '_permission_model.dart';
part '_subscription_plan_model.dart';
part '_printer_settings_model.dart';

class UserModel {
  String? message;
  User? data;

  UserModel({
    this.message,
    this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    message: json["message"],
    data: json["data"] == null ? null : User.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class User extends Equatable {
  final int? id;
  final int? businessId;
  final DynamicFileType? image;
  final String? email;
  final String? name;
  final UserRole? role;
  final String? phone;
  final String? lang;
  final String? status;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Business? business;
  final Currency? businessCurrency;
  final PermissionModules? permissions;

  final DynamicFileType? invoiceLogo;
  final String? invoiceNoteLabel;
  final String? invoiceNote;
  final String? gratitudeMessage;
  final ThermalPrinterPaperSize? invoiceSize;
  final String? developByLabel;
  final String? developBy;
  final String? developByLink;

  const User({
    this.id,
    this.businessId,
    this.image,
    this.email,
    this.name,
    this.role,
    this.phone,
    this.lang,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.business,
    this.businessCurrency,
    this.permissions,
    this.invoiceLogo,
    this.invoiceNoteLabel,
    this.invoiceNote,
    this.gratitudeMessage,
    this.invoiceSize,
    this.developByLabel,
    this.developBy,
    this.developByLink,
  });
  DynamicFileType? get profileImage {
    return isShopOwner ? business?.image : image;
  }

  bool get isPlanExpired {
    final _now = DateTime.now();
    final _realNow = DateTime(_now.year, _now.month, _now.day);

    if (business?.willExpire != null) {
      return _realNow.isAfter(business!.willExpire!);
    }

    return true;
  }

  bool get isShopOwner {
    return permissions == null && (role?.isShopOwner == true);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      businessId: json["business_id"],
      image: json["image"] == null ? null : DynamicFileType(remote: json["image"]),
      email: json["email"],
      name: json["name"],
      role: json["role"] == null ? null : UserRole.fromString(json["role"]),
      phone: json["phone"],
      lang: json["lang"],
      status: json["status"],
      emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
      createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      business: json["business"] == null ? null : Business.fromJson(json["business"]),
      permissions: json["visibility"] == null ? null : PermissionModules.fromJson(json["visibility"]),
      businessCurrency: json["business_currency"] == null ? null : Currency.fromJson(json["business_currency"]),
      invoiceLogo: json["invoice_logo"] == null ? null : DynamicFileType(remote: json["invoice_logo"]),
      invoiceNoteLabel: json["invoice_note_level"],
      invoiceNote: json["invoice_note"],
      gratitudeMessage: json["gratitude_message"],
      invoiceSize: ThermalPrinterPaperSize.fromString(json["invoice_size"]),
      developByLabel: json["develop_by_level"],
      developBy: json["develop_by"],
      developByLink: json["develop_by_link"],
    );
  }

  User copyWith({
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
  }) {
    return User(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      image: image ?? this.image,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      lang: lang ?? this.lang,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      business: business ?? this.business,
      businessCurrency: businessCurrency ?? this.businessCurrency,
      permissions: permissions ?? this.permissions,
      invoiceLogo: invoiceLogo ?? this.invoiceLogo,
      invoiceNoteLabel: invoiceNoteLabel ?? this.invoiceNoteLabel,
      invoiceNote: invoiceNote ?? this.invoiceNote,
      gratitudeMessage: gratitudeMessage ?? this.gratitudeMessage,
      invoiceSize: invoiceSize ?? this.invoiceSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "companyName": business?.companyName,
      (isShopOwner ? "pictureUrl" : "image"): profileImage?.local,
      "business_category_id": business?.businessCategoryId,
      "address": business?.address,
      "shopOpeningBalance": business?.shopOpeningBalance,
      "phoneNumber": business?.phoneNumber,
      "vat_name": business?.vatName,
      "vat_no": business?.vatNo,
      "invoice_logo": invoiceLogo?.local,
      "invoice_note_level": invoiceNoteLabel,
      "invoice_note": invoiceNote,
      "gratitude_message": gratitudeMessage,
      "invoice_size": invoiceSize?.stringValue,
    };
  }

  @override
  List<Object?> get props => [id, email, businessId, permissions?.toJson().toString()];
}

class Business {
  int? id;
  int? planSubscribeId;
  int? businessCategoryId;
  String? companyName;
  DateTime? willExpire;
  String? address;
  String? phoneNumber;
  DynamicFileType? image;
  DateTime? subscriptionDate;
  num? remainingShopBalance;
  num? shopOpeningBalance;
  String? vatName;
  String? vatNo;
  DateTime? createdAt;
  DateTime? updatedAt;
  BusinessCategory? category;
  EnrolledPlan? enrolledPlan;
  TaxModel? tax;

  Business({
    this.id,
    this.planSubscribeId,
    this.businessCategoryId,
    this.companyName,
    this.willExpire,
    this.address,
    this.phoneNumber,
    this.image,
    this.subscriptionDate,
    this.remainingShopBalance,
    this.shopOpeningBalance,
    this.vatName,
    this.vatNo,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.enrolledPlan,
    this.tax,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json["id"],
      planSubscribeId: json["plan_subscribe_id"],
      businessCategoryId: json["business_category_id"],
      companyName: json["companyName"],
      willExpire: json["will_expire"] == null ? null : DateTime.parse(json["will_expire"]),
      address: json["address"],
      phoneNumber: json["phoneNumber"],
      image: json["pictureUrl"] == null ? null : DynamicFileType(remote: json["pictureUrl"]),
      subscriptionDate: json["subscriptionDate"] == null ? null : DateTime.parse(json["subscriptionDate"]),
      remainingShopBalance: json["remainingShopBalance"],
      shopOpeningBalance: json["shopOpeningBalance"],
      vatName: json["vat_name"],
      vatNo: json["vat_no"],
      createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      category: json["category"] == null ? null : BusinessCategory.fromJson(json["category"]),
      enrolledPlan: json["enrolled_plan"] == null ? null : EnrolledPlan.fromJson(json["enrolled_plan"]),
      tax: json["tax"] == null ? null : TaxModel.fromJson(json["tax"]),
    );
  }

  Business copyWith({
    int? id,
    int? planSubscribeId,
    int? businessCategoryId,
    String? companyName,
    DateTime? willExpire,
    String? address,
    String? phoneNumber,
    DynamicFileType? image,
    DateTime? subscriptionDate,
    num? remainingShopBalance,
    num? shopOpeningBalance,
    String? vatName,
    String? vatNo,
    DateTime? createdAt,
    DateTime? updatedAt,
    BusinessCategory? category,
    EnrolledPlan? enrolledPlan,
    TaxModel? tax,
  }) {
    return Business(
      id: id ?? this.id,
      planSubscribeId: planSubscribeId ?? this.planSubscribeId,
      businessCategoryId: businessCategoryId ?? this.businessCategoryId,
      companyName: companyName ?? this.companyName,
      willExpire: willExpire ?? this.willExpire,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      subscriptionDate: subscriptionDate ?? this.subscriptionDate,
      remainingShopBalance: remainingShopBalance ?? this.remainingShopBalance,
      shopOpeningBalance: shopOpeningBalance ?? this.shopOpeningBalance,
      vatName: vatName ?? this.vatName,
      vatNo: vatNo ?? this.vatNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      enrolledPlan: enrolledPlan ?? this.enrolledPlan,
      tax: tax ?? this.tax,
    );
  }
}

class EnrolledPlan {
  int? id;
  int? planId;
  int? businessId;
  int? price;
  int? duration;
  Plan? plan;

  EnrolledPlan({
    this.id,
    this.planId,
    this.businessId,
    this.price,
    this.duration,
    this.plan,
  });

  factory EnrolledPlan.fromJson(Map<String, dynamic> json) => EnrolledPlan(
    id: json["id"],
    planId: json["plan_id"],
    businessId: json["business_id"],
    price: json["price"],
    duration: json["duration"],
    plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
  );
}

class BusinessCategoryModel {
  List<BusinessCategory>? data;
  String? message;

  BusinessCategoryModel({
    this.data,
    this.message,
  });

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
      data: json["data"] == null
          ? []
          : List<BusinessCategory>.from(
              json["data"]!.map((x) => BusinessCategory.fromJson(x)),
            ),
      message: json["message"],
    );
  }
}

class BusinessCategory {
  int? id;
  String? name;
  String? description;
  int? status;

  BusinessCategory({
    this.id,
    this.name,
    this.description,
    this.status,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      status: json["status"],
    );
  }
}

extension UserExt on User {
  ({core.DynamicFileType? image, String? title, String? subtitle})? get currentUser {
    return switch (role) {
      core.UserRole.shopOwner => (
        image: image,
        title: business?.companyName,
        subtitle: business?.enrolledPlan?.plan?.subscriptionName,
      ),
      core.UserRole.staff || core.UserRole.chef || core.UserRole.kitchen => (
        image: image,
        title: name,
        subtitle: role?.name,
      ),
      _ => null,
    };
  }
}
