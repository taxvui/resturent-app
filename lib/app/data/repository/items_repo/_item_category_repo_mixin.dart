part of '_items_repo.dart';

mixin ItemCategoryRepoMixin on BaseRepository {
  //-----------------------Get Item Categories-----------------------//
  Future<ItemCategoryList> getItemCategories({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.itemCategories(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ItemCategoryList.fromJson(
        _response.data,
        (item) => ItemCategory.fromJson(item),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item categories';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Categories-----------------------//

  //-----------------------Manage Item Category-----------------------//
  Future<Either<String, ItemCategory>> manageItemCategory(
    ItemCategory data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.itemCategories(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.category);

      return Either.success(ItemCategory.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item Category-----------------------//

  //--------------------Delete Category--------------------//
  Future<Either<String, String>> deleteCategory(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.itemCategories(id),
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.category);
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

  //--------------------Delete Category--------------------//
}

final itemCategoryDropdownProvider = FutureProvider<ItemCategoryList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.category) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemCategories(noPaging: true),
    );
  },
);
