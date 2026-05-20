import '../repository.dart';

part '_income_category_repo_mixin.dart';

class IncomeRepository extends BaseRepository with IncomeCategoryRepoMixin {
  IncomeRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Income List-----------------------//
  Future<IncomeList> getIncomeList({
    int page = 1,
    int? categoryId,
    String? query,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.incomes(),
        queryParameters: {
          "income_category_id": categoryId,
          "search": query,
        }.removeNullValue,
      );

      return IncomeList.fromJson(
        _response.data,
        (income) => Income.fromJson(income),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get Income list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Income List-----------------------//

  //-----------------------Manage Income-----------------------//
  Future<Either<String, Income>> manageIncome(
    Income data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.incomes(data.id),
        data: _formData,
      );

      gEventListener.fire<IncomeApiEvent>(IncomeApiEvent.income);

      return Either.success(Income.fromJson(_response.data['data']));
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
  //-----------------------Manage Income-----------------------//

  //--------------------Delete Income--------------------//
  Future<Either<String, String>> deleteIncome(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.incomes(id),
      );

      gEventListener.fire<IncomeApiEvent>(IncomeApiEvent.income);
      return Either.success(
        _response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ??
            e.message ??
            'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Income--------------------//

  //-----------------------Get Income Report-----------------------//
  Future<IncomeReportList> getIncomeReport({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.incomeReport,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "from_date": fromDate,
          "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return IncomeReportList.fromJson(
        _response.data,
        (income) => IncomeReport.fromJson(income),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get income report list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Income Report-----------------------//
}

final incomeRepoProvider = Provider.autoDispose<IncomeRepository>(
  (ref) => IncomeRepository(ref),
);

enum IncomeApiEvent { income, category }
