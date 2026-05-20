import '../repository.dart';

class IngredientRepository extends BaseRepository {
  IngredientRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Ingredients-----------------------//
  Future<IngredientList> getIngredients({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.ingredients(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return IngredientList.fromJson(
        _response.data,
        (ingredient) => Ingredient.fromJson(ingredient),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get ingredients.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Ingredients-----------------------//

  //-----------------------Manage Ingredient-----------------------//
  Future<Either<String, Ingredient>> manageIngredient(Ingredient data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.ingredients(data.id),
        data: _formData,
      );

      gEventListener.fire<IngredientApiEvent>(IngredientApiEvent.modified);

      return Either.success(Ingredient.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Ingredient-----------------------//

  //--------------------Delete Ingredient--------------------//
  Future<Either<String, String>> deleteIngredient(int id) async {
    try {
      final _response = await dioClient.delete(DAPIEndpoints.ingredients(id));

      gEventListener.fire<IngredientApiEvent>(IngredientApiEvent.modified);
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
  //--------------------Delete Ingredient--------------------//
}

final ingredientRepoProvider = Provider.autoDispose<IngredientRepository>(
  IngredientRepository.new,
);

enum IngredientApiEvent { modified }
