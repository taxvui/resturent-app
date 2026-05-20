import '../repository.dart';

class CouponRepository extends BaseRepository {
  CouponRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Coupon List-----------------------//
  Future<CouponList> getCoupons({
    int page = 1,
    String? status,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.coupons(),
        queryParameters: {
          "page": page,
          "status": status,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return CouponList.fromJson(
        _response.data,
        (coupon) => CouponModel.fromJson(coupon),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get coupon list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Coupon List-----------------------//

  //-----------------------Manage Coupon-----------------------//
  Future<Either<String, CouponModel>> manageCoupon(
    CouponModel data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.coupons(data.id),
        data: _formData,
      );

      gEventListener.fire<CouponAE>(CouponModifiedAE());

      return Either.success(CouponModel.fromJson(_response.data?['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Coupon-----------------------//

  //--------------------Delete Coupon--------------------//
  Future<Either<String, String>> deleteCoupon(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.coupons(id),
      );

      gEventListener.fire<CouponAE>(CouponDeletedAE(id));
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
  //--------------------Delete Coupon--------------------//
}

final couponRepoProvider = Provider.autoDispose<CouponRepository>(
  CouponRepository.new,
);

//---------------------------Api Events---------------------------//
abstract class CouponAE extends BaseApiEvent {
  const CouponAE();
}

class CouponModifiedAE extends CouponAE {
  const CouponModifiedAE();
}

class CouponDeletedAE extends CouponAE {
  final int id;
  const CouponDeletedAE(this.id);
}
//---------------------------Api Events---------------------------//
