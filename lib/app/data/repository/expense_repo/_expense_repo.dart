import '../repository.dart';

part '_expense_category_repo_mixin.dart';

class ExpenseRepository extends BaseRepository with ExpenseCategoryRepoMixin {
  ExpenseRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Expense List-----------------------//
  Future<ExpenseList> getExpenseList({
    int page = 1,
    int? categoryId,
    String? query,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.expenses(),
        queryParameters: {
          "expense_category_id": categoryId,
          "search": query,
        }.removeNullValue,
      );

      return ExpenseList.fromJson(
        _response.data,
        (expense) => Expense.fromJson(expense),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get expense list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Expense List-----------------------//

  //-----------------------Manage Expense-----------------------//
  Future<Either<String, Expense>> manageExpense(
    Expense data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.expenses(data.id),
        data: _formData,
      );

      gEventListener.fire<ExpenseApiEvent>(ExpenseApiEvent.expense);

      return Either.success(Expense.fromJson(_response.data['data']));
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
  //-----------------------Manage Expense-----------------------//

  //--------------------Delete Expense--------------------//
  Future<Either<String, String>> deleteExpense(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.expenses(id),
      );

      gEventListener.fire<ExpenseApiEvent>(ExpenseApiEvent.expense);
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
  //--------------------Delete Expense--------------------//

  //-----------------------Get Expense Report-----------------------//
  Future<ExpenseReportList> getExpenseReport({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.expenseReport,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "from_date": fromDate,
          "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return ExpenseReportList.fromJson(
        _response.data,
        (expense) => ExpenseReport.fromJson(expense),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get expense report list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Expense Report-----------------------//
}

final expenseRepoProvider = Provider.autoDispose<ExpenseRepository>(
  (ref) => ExpenseRepository(ref),
);

enum ExpenseApiEvent { expense, category }
