part of '_items_repo.dart';

mixin ItemUnitRepoMixin on BaseRepository {
  //-----------------------Get Item Units-----------------------//
  Future<ItemUnitList> getItemUnits({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.itemUnits(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ItemUnitList.fromJson(
        _response.data,
        (item) => ItemUnit.fromJson(item),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item Units';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Units-----------------------//

  //-----------------------Manage Item Unit-----------------------//
  Future<Either<String, ItemUnit>> manageItemUnit(
    ItemUnit data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.itemUnits(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.unit);

      return Either.success(ItemUnit.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item Unit-----------------------//

  //--------------------Delete Unit--------------------//
  Future<Either<String, String>> deleteUnit(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.itemUnits(id),
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.unit);
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

  //--------------------Delete Unit--------------------//
}

final itemUnitDropdownProvider = FutureProvider<ItemUnitList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.unit) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemUnits(noPaging: true),
    );
  },
);
