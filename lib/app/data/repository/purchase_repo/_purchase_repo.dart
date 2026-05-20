import '../repository.dart';

class PurchaseRepository extends BaseRepository {
  PurchaseRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Purchase List-----------------------//
  Future<PurchaseList> getPurchaseList({
    int page = 1,
    String? search,
    String? paymentStatus,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.purchase(),
        queryParameters: {
          "page": page,
          "payment_status": paymentStatus,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PurchaseList.fromJson(
        _response.data,
        (purchase) => Purchase.fromJson(purchase),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get purchase list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Purchase List-----------------------//

  //-----------------------Get Purchase Details-----------------------//
  Future<PurchaseDetailsModel> getPurchaseDetails(int id) async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.purchase(id));

      return PurchaseDetailsModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get purchase details';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Purchase Details-----------------------//

  //-----------------------Manage Purchase-----------------------//
  Future<Either<String, PurchaseDetailsModel>> managePurchase(
    Purchase data,
  ) async {
    final _formData = data.toJson();
    if (data.id != null) {
      _formData['_method'] = 'put';
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.purchase(data.id),
        data: _formData,
      );

      gEventListener.fire<PurchaseApiEvent>(PurchaseApiEvent.modified);

      return Either.success(PurchaseDetailsModel.fromJson(_response.data));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ??
            e.message ??
            'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Purchase-----------------------//

  //--------------------Delete Purchase--------------------//
  Future<Either<String, String>> deletePurchase(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.purchase(id),
      );

      gEventListener.fire<PurchaseApiEvent>(PurchaseApiEvent.modified);
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
  //--------------------Delete Purchase--------------------//

  //--------------------Purchase Report List--------------------//
  Future<PurchaseReportList> getPurchaseReportList({
    int page = 1,
    String? search,
    String? paymentStatus,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.purchaseReport,
        queryParameters: {
          "page": page,
          "payment_status": paymentStatus,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PurchaseReportList.fromJson(
        _response.data,
        (purchase) => PurchaseReport.fromJson(purchase),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get purchase list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Purchase Report List--------------------//
}

final purchaseRepoProvider = Provider.autoDispose<PurchaseRepository>(
  PurchaseRepository.new,
);

enum PurchaseApiEvent { modified }
