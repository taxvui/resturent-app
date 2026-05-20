part of '_items_repo.dart';

mixin ItemModifierGroupRepoMixin on BaseRepository {
  //-----------------------Get Item Modifier Group-----------------------//
  Future<ModifierGroupList> getItemModifierGroups({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.modifierGroups(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ModifierGroupList.fromJson(
        _response.data,
        (modifier) => ItemModifierGroup.fromJson(modifier),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get modifier groups.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Modifier Group-----------------------//

  //-----------------------Manage Item Modifier Group-----------------------//
  Future<Either<String, ItemModifierGroup>> manageItemModifierGroup(
    ItemModifierGroup data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.modifierGroups(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.modifierGroup);

      return Either.success(ItemModifierGroup.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item Modifier Group-----------------------//

  //--------------------Delete Modifier Group--------------------//
  Future<Either<String, String>> deleteModifierGroup(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.modifierGroups(id),
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.modifierGroup);
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

  //--------------------Delete Modifier Group--------------------//
}

final itemModifierGroupDropdownProvider = FutureProvider<ModifierGroupList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.modifierGroup) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemModifierGroups(noPaging: true),
    );
  },
);
