part of '_expense_repo.dart';

mixin ExpenseCategoryRepoMixin on BaseRepository {
  //-----------------------Get Expense Categories-----------------------//
  Future<ExpenseCategoryList> getExpenseCategories({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.expenseCategories(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ExpenseCategoryList.fromJson(
        _response.data,
        (category) => ExpenseCategory.fromJson(category),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get expense categories';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Expense Categories-----------------------//

  //-----------------------Manage Expense Category-----------------------//
  Future<Either<String, ExpenseCategory>> manageExpenseCategory(
    ExpenseCategory data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.expenseCategories(data.id),
        data: _formData,
      );

      gEventListener.fire<ExpenseApiEvent>(ExpenseApiEvent.category);

      return Either.success(ExpenseCategory.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Expense Category-----------------------//

  //--------------------Delete Category--------------------//
  Future<Either<String, String>> deleteCategory(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.expenseCategories(id),
      );

      gEventListener.fire<ExpenseApiEvent>(ExpenseApiEvent.category);
      return Either.success(
        _response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data?['message'] ?? 'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Category--------------------//
}

final expenseCategoryDropdownProvider = FutureProvider<ExpenseCategoryList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ExpenseApiEvent>().listen((event) {
      if (event == ExpenseApiEvent.category) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(expenseRepoProvider).getExpenseCategories(noPaging: true),
    );
  },
);
