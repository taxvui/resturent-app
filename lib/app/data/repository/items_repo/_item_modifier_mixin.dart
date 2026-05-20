part of '_items_repo.dart';

mixin ItemModifierRepoMixin on BaseRepository {
  //-----------------------Get Item Modifier-----------------------//
  Future<ItemModifierList> getItemModifers({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.itemModifier(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ItemModifierList.fromJson(
        _response.data,
        (modifier) => ItemModifier.fromJson(modifier),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item modifiers.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Modifier-----------------------//

  //-----------------------Manage Item Modifier-----------------------//
  Future<Either<String, ItemModifier>> manageItemModifier(
    ItemModifier data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.itemModifier(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.modifier);

      return Either.success(ItemModifier.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item Modifier-----------------------//

  //--------------------Delete Item Modifier--------------------//
  Future<Either<String, String>> deleteItemModifier(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.itemModifier(id),
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.modifier);
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

  //--------------------Delete Item Modifier--------------------//
}

final itemModifierDropdownProvider = FutureProvider<ItemModifierList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.modifier) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemModifers(noPaging: true),
    );
  },
);
