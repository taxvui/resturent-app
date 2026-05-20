import '../repository.dart';

part '_notification_repo_mixin.dart';

abstract class UserRepositoryBase extends AsyncNotifier<User?> {
  late final HTTPDioClient httpClient;
  late final Dio dioClient;
}

class UserRepository extends UserRepositoryBase with NotificaitonRepoMixin {
  @override
  FutureOr<User?> build() async {
    httpClient = ref.watch(httpDioClientProvider);
    dioClient = httpClient.restClient;
    return await getUser().then((value) => value.right);
  }

  //--------------------------------Get User--------------------------------//
  Future<Either<String, User?>> getUser() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.userBusiness(),
        options: DioOptions(headers: httpClient.getAuthHeader),
      );
      if (_response.statusCode == HttpStatus.ok) {
        final _model = UserModel.fromJson(_response.data);

        state = AsyncValue.data(_model.data);

        return Either.success(_model.data);
      }
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again!',
      );
    }

    return Either.failure("Something went wrong, please try again!");
  }
  //--------------------------------Get User--------------------------------//

  //--------------------------------Sign In--------------------------------//
  Future<Either<String?, SignInModel?>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.signin,
        data: {
          "email": email,
          "password": password,
          "fcm_token": PushNotificationService.I.fcmToken,
        },
      );
      if (_response.statusCode == HttpStatus.ok) {
        final _data = SignInModel.fromJson(_response.data);
        if (_data.data?.token != null) {
          await httpClient.setToken(_data.data!.token!, true);
        }
        await update((_) async => await getUser().then((value) => value.right));

        GlobalEventManager.I.fire<UserAuthEvent>(UserAuthEvent.signedIn);

        return Either.success(_data);
      } else if (_response.statusCode == HttpStatus.created) {
        return Either.failure(HttpStatus.created.toString());
      }
    } on DioException catch (e) {
      return Either.failure(e.response?.data['message']);
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //--------------------------------Sign In--------------------------------//

  //--------------------------------Sign Out--------------------------------//
  Future<Either<String?, String?>> signOut() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.signout,
        options: DioOptions(headers: httpClient.getAuthHeader),
      );
      if (_response.statusCode == HttpStatus.ok) {
        state = const AsyncValue.data(null);
        await httpClient.prefs.remove(DAppSPrefsKeys.authToken);
        GlobalEventManager.I.fire<UserAuthEvent>(UserAuthEvent.signedOut);
        return Either.success(_response.data?['message'] ?? '');
      }
    } on DioException catch (e) {
      return Either.failure(e.response?.data['message'] ?? '');
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //--------------------------------Sign Out--------------------------------//

  //--------------------------------Sign Up--------------------------------//
  Future<Either<String?, String?>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.signup,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "fcm_token": PushNotificationService.I.fcmToken,
        },
      );
      if (_response.statusCode == HttpStatus.ok) {
        return Either.success('Signed up successfully');
      }
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again!',
      );
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //--------------------------------Sign Up--------------------------------//

  //--------------------------------Submit OTP--------------------------------//
  Future<Either<String?, OtpSubmitModel?>> submitOtp({
    required String email,
    required String otp,

    /// If [saveToken] `null`, Does nothing. if `true` then overrides with saving to prefs. if `false` just overrides
    bool? saveToken,
  }) async {
    if (saveToken == true) {
      await httpClient.prefs.remove(DAppSPrefsKeys.authToken);
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.submitotp,
        data: {"email": email, "otp": otp},
      );

      if (_response.statusCode == HttpStatus.ok) {
        final _data = OtpSubmitModel.fromJson(_response.data);
        if (saveToken != null && _data.token != null) {
          await httpClient.setToken(_data.token!, saveToken == true);
        }

        return Either.success(_data);
      }
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data?['error'] ?? 'Something went wrong, please try again!',
      );
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //--------------------------------Submit OTP--------------------------------//

  //--------------------------------Re-Submit OTP--------------------------------//
  Future<Either<String?, String?>> resubmitOtp({
    required String email,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.resendotp,
        data: {
          "email": email,
        },
      );
      if (_response.statusCode == HttpStatus.ok) {
        return Either.success('OTP sent successfully');
      }
    } on DioException catch (e) {
      return Either.failure(e.response?.data?['message'] ?? 'Something went wrong');
    }
    return Either.failure('Something went wrong, please try again!');
  }

  //--------------------------------Re-Submit OTP--------------------------------//

  //------------------------Send OTP For Reset Password------------------------//
  Future<Either<String?, String?>> getResetPasswordOtp({
    required String email,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.resetPassOtp,
        data: {"email": email},
        options: DioOptions(contentType: DioHeaders.jsonContentType),
      );
      if (_response.statusCode == HttpStatus.ok) {
        return Either.success('Otp send successfully');
      }
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again!',
      );
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //------------------------Send OTP For Reset Password------------------------//

  //------------------------Reset Password------------------------//
  Future<Either<String?, String?>> changePassword({
    required String password,
    required String confirmPass,
    required String email,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.resetPassword,
        data: {
          "password": password,
          "password_confirmation": confirmPass,
          "email": email,
        },
        options: DioOptions(headers: httpClient.getAuthHeader),
      );
      if (_response.statusCode == HttpStatus.ok) {
        return Either.success(_response.data?['message']);
      }
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again!',
      );
    }
    return Either.failure('Something went wrong, please try again!');
  }
  //------------------------Reset Password------------------------//

  //------------------------Update Profile------------------------//
  Future<User> updateProfile(User data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.businessId != null) {
      _formData.fields.add(MapEntry('_method', 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.userBusiness(data.businessId),
        options: DioOptions(
          contentType: DioHeaders.multipartFormDataContentType,
          headers: httpClient.getAuthHeader,
        ),
        data: _formData,
      );

      final _user = User.fromJson(_response.data['business']);
      state = AsyncValue.data(_user);
      GlobalEventManager.I.fire<UserAuthEvent>(UserAuthEvent.profileUpdate);
      return _user;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception(e);
    }
  }
  //------------------------Update Profile------------------------//

  //------------------------Get Business Categories------------------------//
  Future<BusinessCategoryModel> getBusinessCategories() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.businessCategories(),
        options: DioOptions(headers: httpClient.getAuthHeader),
      );

      if (_response.statusCode == HttpStatus.ok) {
        final _model = BusinessCategoryModel.fromJson(_response.data);
        return _model;
      }

      throw Exception(
        'Failed to get business categories, please try again.\nstatusCode:${_response.statusCode}',
      );
    } on DioException catch (err) {
      throw Exception(
        err.response?.data['message'] ?? 'Failed to business categories.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //------------------------Get Business Categories------------------------//

  //------------------------Get Subscription Plans------------------------//
  Future<SubscriptionPlanModel> getSubscriptionPlans() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.subscriptionPlans,
        options: DioOptions(headers: httpClient.getAuthHeader),
      );

      if (_response.statusCode == HttpStatus.ok) {
        final _model = SubscriptionPlanModel.fromJson(_response.data);
        return _model;
      }

      throw Exception(
        'Failed to get subscription plans, please try again.\nstatusCode:${_response.statusCode}',
      );
    } on DioException catch (err) {
      throw Exception(
        err.response?.data['message'] ?? 'Failed to get subscription plans.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //------------------------Get Subscription Plans------------------------//

  //------------------------Get Subscription Plans------------------------//
  Future<String?> getNextInvoice(String invoiceType) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.nextInvoice,
        options: DioOptions(headers: httpClient.getAuthHeader),
        queryParameters: {'platform': invoiceType},
      );

      return _response.data?['data'];
    } on DioException catch (err) {
      throw Exception(
        err.response?.data['message'] ?? 'Failed to get next invoice.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //------------------------Get Subscription Plans------------------------//
}

enum UserAuthEvent { signedIn, signedOut, profileUpdate }

final userRepositoryProvider = AsyncNotifierProvider<UserRepository, User?>(
  UserRepository.new,
);

final businessCategoriesProvider = FutureProvider<BusinessCategoryModel>(
  (ref) => Future.microtask(
    () => ref.read(userRepositoryProvider.notifier).getBusinessCategories(),
  ),
);

final subscriptionPlansProvider = FutureProvider<SubscriptionPlanModel>(
  (ref) => Future.microtask(
    () => ref.read(userRepositoryProvider.notifier).getSubscriptionPlans(),
  ),
);

class PrinterSettingsNotifier extends Notifier<PrinterSetttingsModel> {
  late final _prefs = ref.read(sharedPrefsProvider);
  @override
  PrinterSetttingsModel build() {
    try {
      final _jsonString = _prefs.getString(DAppSPrefsKeys.printerSettings);
      if (_jsonString == null) {
        throw Exception('Invalid json string');
      }

      return PrinterSetttingsModel.fromJson(jsonDecode(_jsonString));
    } catch (e) {
      return PrinterSetttingsModel.fromJson({});
    }
  }

  Future<PrinterSetttingsModel> saveSettings(PrinterSetttingsModel data) async {
    try {
      final _jsonData = jsonEncode(data.toJson());
      await _prefs.setString(DAppSPrefsKeys.printerSettings, _jsonData);

      return state = data;
    } catch (e) {
      throw Exception('Error saving printer settings locally: $e');
    }
  }
}

final printerSettingsProvider = NotifierProvider<PrinterSettingsNotifier, PrinterSetttingsModel>(
  PrinterSettingsNotifier.new,
);
