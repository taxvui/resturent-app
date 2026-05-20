import '../repository.dart';

part '_item_menu_repo_mixin.dart';
part '_item_category_repo_mixin.dart';
part '_item_unit_repo_mixin.dart';
part '_item_modifier_group_repo_mixin.dart';
part '_item_modifier_mixin.dart';

class ItemsRepository extends _ItemRepositoryMixer {
  ItemsRepository(super.ref);

  //-----------------------Get Item List-----------------------//
  Future<PItemList> getItemList({
    int page = 1,
    String? search,
    int? categoryId,
    int? menuId,
    String? sortBy,
    String? foodType,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.items(),
        queryParameters: {
          "page": page,
          "search": search,
          "category_id": categoryId,
          "menu_id": menuId,
          "sort_by": sortBy,
          "food_type": foodType,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PItemList.fromJson(_response.data, (item) => PItem.fromJson(item));
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item List-----------------------//

  //-----------------------Get Item Details-----------------------//
  Future<ItemDetailsModel> getItemDetails(int id) async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.items(id));

      return ItemDetailsModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item details';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Item Details-----------------------//

  //-----------------------Manage Item-----------------------//
  Future<Either<String, PItem>> manageItem(PItem data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.items(data.id),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.item);

      return Either.success(PItem.fromJson(_response.data?['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Item-----------------------//

  //-----------------------Manage Stock-----------------------//
  /*
  Future<Either<String, PItem>> manageStock(AdjustStockModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.adjustStock(data.id!),
        data: _formData,
      );

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.item);

      return Either.success(PItem.fromJson(_response.data?['data']));
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
  */
  //-----------------------Manage Stock-----------------------//

  //--------------------Delete Item--------------------//
  Future<Either<String, String>> deleteItem(int id) async {
    try {
      final _response = await dioClient.delete(DAPIEndpoints.items(id));

      gEventListener.fire<ItemsApiEvent>(ItemsApiEvent.item);
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
  //--------------------Delete Item--------------------//

  //-----------------------Get Item Stock List-----------------------//
  /*
  Future<PaginatedStockListModel> getStockItemList({
    int page = 1,
    String? search,
    int? categoryId,
    String? sortBy,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.stocks(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "category_id": categoryId,
          "sort_by": sortBy,
        },
      );

      return PaginatedStockListModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  */
  //-----------------------Get Item Stock List-----------------------//

  //-----------------------Get Item Stock Report-----------------------//
  /*
  Future<PStockReportList> getStockItemReport({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.stockReport,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "from_date": fromDate,
          "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PStockReportList.fromJson(
        _response.data,
        (stock) => PStockReport.fromJson(stock),
      );
    } on DioException catch (e) {
      final _message =
          e.response?.data['message'] ?? 'Failed to get item stock report';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  */
  //-----------------------Get Item Stock Report-----------------------//
}

final itemsRepoProvider = Provider.autoDispose<ItemsRepository>(
  (ref) => ItemsRepository(ref),
);

enum ItemsApiEvent { item, category, menu, unit, modifierGroup, modifier }

abstract class _ItemRepositoryMixer extends BaseRepository
    with
        ItemCategoryRepoMixin,
        ItemMenuRepoMixin,
        ItemUnitRepoMixin,
        ItemModifierGroupRepoMixin,
        ItemModifierRepoMixin {
  _ItemRepositoryMixer(super.ref) : super(putAuthHeader: true);
}

final itemsDropdownProvider = FutureProvider<PItemList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((_) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemList(noPaging: true),
    );
  },
);

final itemDetailsProvider = FutureProvider.family<ItemDetailsModel, int>(
  (ref, id) {
    final _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((_) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(itemsRepoProvider).getItemDetails(id),
    );
  },
);
