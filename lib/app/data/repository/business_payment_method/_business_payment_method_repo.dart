import '../repository.dart';

class BusinessPaymentMethodRepo extends BaseRepository {
  BusinessPaymentMethodRepo(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Business Payment Methods-----------------------//
  Future<BusinessPaymentMethodList> getBusinessPaymentMethod({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.businessPaymentMethods(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return BusinessPaymentMethodList.fromJson(
        _response.data,
        (method) => BusinessPaymentMethod.fromJson(method),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get payment methods.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Business Payment Methods-----------------------//

  //----------------------Manage Business Payment Method----------------------//
  Future<Either<String, BusinessPaymentMethod>> manageBusinessPaymentMethod(
    BusinessPaymentMethod data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.businessPaymentMethods(data.id),
        data: _formData,
      );

      gEventListener.fire<BusinessPaymentMethodAE>(
        BusinessPaymentMethodModifiedAE(),
      );

      return Either.success(
        BusinessPaymentMethod.fromJson(_response.data['data']),
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //----------------------Manage Business Payment Method----------------------//

  //--------------------Delete Business Payment Method--------------------//
  Future<Either<String, String>> deleteBusinessPaymentMethod(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.businessPaymentMethods(id),
      );

      gEventListener.fire<BusinessPaymentMethodAE>(
        BusinessPaymentMethodDeletedAE(id),
      );
      return Either.success(
        _response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Business Payment Method--------------------//
}

final businessPaymentMethodRepoProvider = Provider.autoDispose<BusinessPaymentMethodRepo>(
  BusinessPaymentMethodRepo.new,
);

final businessPaymentMethodDropdownProvider = FutureProvider<BusinessPaymentMethodList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<BusinessPaymentMethodAE>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(businessPaymentMethodRepoProvider).getBusinessPaymentMethod(noPaging: true),
    );
  },
);

//---------------------------Api Events---------------------------//
abstract class BusinessPaymentMethodAE extends BaseApiEvent {
  const BusinessPaymentMethodAE();
}

class BusinessPaymentMethodModifiedAE extends BusinessPaymentMethodAE {
  const BusinessPaymentMethodModifiedAE();
}

class BusinessPaymentMethodDeletedAE extends BusinessPaymentMethodAE {
  final int id;
  const BusinessPaymentMethodDeletedAE(this.id);
}

//---------------------------Api Events---------------------------//
