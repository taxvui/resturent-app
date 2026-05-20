part of '_user_model.dart';

class SignInModel {
  String? message;
  SignInData? data;

  SignInModel({
    this.message,
    this.data,
  });

  factory SignInModel.fromJson(Map<String, dynamic> json) => SignInModel(
        message: json["message"],
        data: json["data"] == null ? null : SignInData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class SignInData {
  String? message;
  bool? isSetup;
  String? token;

  SignInData({
    this.message,
    this.isSetup,
    this.token,
  });

  factory SignInData.fromJson(Map<String, dynamic> json) {
    return SignInData(
      message: json["message"],
      isSetup: json["is_setup"],
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "is_setup": isSetup,
      "token": token,
    };
  }
}

class OtpSubmitModel {
  String? message;
  bool? isSetup;
  String? token;

  OtpSubmitModel({
    this.message,
    this.isSetup,
    this.token,
  });

  factory OtpSubmitModel.fromJson(Map<String, dynamic> json) {
    return OtpSubmitModel(
      message: json["message"],
      isSetup: json["is_setup"],
      token: json["token"],
    );
  }
}
