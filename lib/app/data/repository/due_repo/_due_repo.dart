import '../repository.dart';

class DueRepository extends BaseRepository {
  DueRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Due List-----------------------//
  Future<DueList> getDueList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dueList(),
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          "status": status,
        }.removeNullValue,
      );

      return DueList.fromJson(
        _response.data,
        (due) => DueModel.fromJson(due),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get due list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Due List-----------------------//

  //-----------------------Get Due Collection List-----------------------//
  Future<DueCollectionList> getDueCollectionList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dueCollectionList(),
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          "status": status,
        }.removeNullValue,
      );

      return DueCollectionList.fromJson(
        _response.data,
        (due) => DueCollection.fromJson(due),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get due collection list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Due Collection List-----------------------//

  //-----------------------Manage Due Collection-----------------------//
  Future<Either<String, DueCollectionDetailsModel>> manageDueCollection(
    DueCollection data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.dueCollectionList(data.id),
        data: _formData,
      );
      final _collectionData = DueCollectionDetailsModel.fromJson(_response.data);

      gEventListener.fire<DueAE>(DueModifiedAE());
      gEventListener.fire<PartyAE>(PartyModifiedAE());
      if (_collectionData.data?.saleId != null) {
        gEventListener.fire<SaleAE>(SaleModifiedAE());
      }
      if (_collectionData.data?.purchaseId != null) {
        gEventListener.fire<PurchaseApiEvent>(PurchaseApiEvent.modified);
      }

      return Either.success(_collectionData);
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Due Collection-----------------------//

  //-----------------------Get Due Report-----------------------//
  Future<DueReportList> getDueReport({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dueReport,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "from_date": fromDate,
          "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return DueReportList.fromJson(
        _response.data,
        (stock) => DueReport.fromJson(stock),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item stock report';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Due Report-----------------------//

  //-----------------------Get Due Collection Report-----------------------//
  Future<DueCollectionReportList> getDueCollectionReport({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dueCollectionReport,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return DueCollectionReportList.fromJson(
        _response.data,
        (due) => DueCollectionReport.fromJson(due),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get due collection report list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Due Collection Report-----------------------//
}

final dueRepoProvider = Provider.autoDispose<DueRepository>(
  DueRepository.new,
);

//---------------------------Api Events---------------------------//
abstract class DueAE extends BaseApiEvent {
  const DueAE();
}

class DueModifiedAE extends DueAE {
  const DueModifiedAE();
}
//---------------------------Api Events---------------------------//
