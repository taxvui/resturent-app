part of '_sale_repo.dart';

mixin QuotationRepoMixin on BaseRepository {
  //-----------------------Get Quotation List-----------------------//
  Future<QuotationList> getQuotationList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.quotation(),
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return QuotationList.fromJson(
        _response.data,
        (quotation) => Quotation.fromJson(quotation),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get quotation list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Quotation List-----------------------//

  //-----------------------Get Quotation Details-----------------------//
  Future<QuotationDetailsModel> getQuotationDetails(int id) async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.quotation(id));

      return QuotationDetailsModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get quotation details';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Quotation Details-----------------------//

  //-----------------------Manage Quotation-----------------------//
  Future<Either<String, QuotationDetailsModel>> manageQuotation(
    Quotation data,
  ) async {
    final _formData = data.toJson();
    if (data.id != null) {
      _formData['_method'] = 'put';
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.quotation(data.id),
        data: _formData,
      );

      gEventListener.fire<QuotationAE>(QuotationModifiedAE());

      return Either.success(QuotationDetailsModel.fromJson(_response.data));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Quotation-----------------------//

  //--------------------Delete Quotation--------------------//
  Future<Either<String, String>> deleteQuotation(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.quotation(id),
      );

      final _quotationData = QuotationDetailsModel.fromJson(_response.data);
      gEventListener.fire<QuotationAE>(QuotationDeletedAE(id));
      return Either.success(_quotationData.message ?? 'Deleted successfully');
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Quotation--------------------//

  //--------------------Quotation Report List--------------------//
  Future<QuotationReportList> getQuotationReportList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.quotationReport,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return QuotationReportList.fromJson(
        _response.data,
        (quotation) => Quotation.fromJson(quotation),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to quotation report list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Quotation Report List--------------------//
}

//---------------------------Api Events---------------------------//
abstract class QuotationAE extends BaseApiEvent {
  const QuotationAE();
}

class QuotationModifiedAE extends QuotationAE {
  const QuotationModifiedAE();
}

class QuotationDeletedAE extends QuotationAE {
  final int id;
  const QuotationDeletedAE(this.id);
}
//---------------------------Api Events---------------------------//
