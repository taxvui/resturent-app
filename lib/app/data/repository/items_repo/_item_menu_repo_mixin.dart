part of '_items_repo.dart';

mixin ItemMenuRepoMixin on BaseRepository {
  //-----------------------Get Item Menus-----------------------//
  Future<ItemMenuList> getItemMenus({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.itemMenus(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ItemMenuList.fromJson(
        _response.data,
        (item) => ItemMenu.fromJson(item),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item menus';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Menus-----------------------//

  //-----------------------Manage Item Menu-----------------------//
  Future<Either<String, ItemMenu>> manageItemMenu(
    ItemMenu data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.itemMenus(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.menu);

      return Either.success(ItemMenu.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item Menu-----------------------//

  //--------------------Delete Menu--------------------//
  Future<Either<String, String>> deleteMenu(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.itemMenus(id),
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.menu);
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

  //--------------------Delete Menu--------------------//
}

final itemMenuDropdownProvider = FutureProvider<ItemMenuList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.menu) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemMenus(noPaging: true),
    );
  },
);
