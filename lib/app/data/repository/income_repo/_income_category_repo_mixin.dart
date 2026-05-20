part of '_income_repo.dart';

mixin IncomeCategoryRepoMixin on BaseRepository {
  //-----------------------Get Income Categories-----------------------//
  Future<IncomeCategoryList> getIncomeCategories({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.incomeCategories(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return IncomeCategoryList.fromJson(
        _response.data,
        (category) => IncomeCategory.fromJson(category),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get income categories';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Income Categories-----------------------//

  //-----------------------Manage Income Category-----------------------//
  Future<Either<String, IncomeCategory>> manageIncomeCategory(
    IncomeCategory data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.incomeCategories(data.id),
        data: _formData,
      );

      gEventListener.fire<IncomeApiEvent>(IncomeApiEvent.category);

      return Either.success(IncomeCategory.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Income Category-----------------------//

  //--------------------Delete Category--------------------//
  Future<Either<String, String>> deleteCategory(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.incomeCategories(id),
      );

      gEventListener.fire<IncomeApiEvent>(IncomeApiEvent.category);
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

final incomeCategoryDropdownProvider = FutureProvider<IncomeCategoryList>(
  (ref) {
    final _apiEvnetSub = GlobalEventManager.I.on<IncomeApiEvent>().listen((event) {
      if (event == IncomeApiEvent.category) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEvnetSub.cancel);

    return Future.microtask(
      () => ref.read(incomeRepoProvider).getIncomeCategories(noPaging: true),
    );
  },
);
