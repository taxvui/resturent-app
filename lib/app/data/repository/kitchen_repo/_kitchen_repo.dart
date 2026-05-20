import '../repository.dart';

class KitchenRepository extends BaseRepository {
  KitchenRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Kitchen List-----------------------//
  Future<KitchenListModel> getKitchenList({
    int page = 1,
    String? search,
    int? kitchenId,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.kitchen.kitchens(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "kitchen_id": ?kitchenId,
          if (noPaging) "no_paginate": 1,
        },
      );

      return KitchenListModel.fromJson(
        _response.data,
        (kitchen) => KitchenModel.fromJson(kitchen),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get kitchen list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Kitchen List-----------------------//

  //-----------------------Manage Kitchen-----------------------//
  Future<KitchenModel> manageKitchen(KitchenModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.kitchen.kitchens(data.id),
        data: _formData,
      );

      final _data = KitchenModel.fromJson(_response.data['data']);
      gEventListener.fire<KitchenModel>(_data);

      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Kitchen-----------------------//

  //-----------------------Manage Kitchen Items-----------------------//
  Future<KitchenModel> manageKitchenItems(KitchenModel data) async {
    try {
      final _formData = await Future.microtask(data.toKitchenItems().getTypedData);

      final _response = await dioClient.post(
        DAPIEndpoints.kitchen.assignItems(data.id!),
        data: _formData,
      );

      final _data = KitchenModel.fromJson(_response.data['data']);
      gEventListener.fire<KitchenModel>(_data);

      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Kitchen Items-----------------------//

  //-----------------------Manage Kitchen Status-----------------------//
  Future<String> manageKitchenStatus({
    required int id,
    required int status,
  }) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.kitchen.status(id),
        data: {"status": status},
      );

      gEventListener.fire<KitchenModel>(KitchenModel.event(id));

      return _response.data?["message"] ?? "Status updated successfully.";
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Kitchen Status-----------------------//

  //--------------------Delete Kitchen Item--------------------//
  Future<String> deleteKitchenItem(int kitchenId, int itemId) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.kitchen.deleteItem(kitchenId),
        data: {'product_id': itemId},
      );

      gEventListener.fire<KitchenModel>(KitchenModel.event(kitchenId));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Kitchen Item--------------------//

  //--------------------Delete Kitchen--------------------//
  Future<String> deleteKitchen(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.kitchen.kitchens(id),
      );

      gEventListener.fire<KitchenModel>(KitchenModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Kitchen--------------------//

  //--------------------Get Unassigned Product--------------------//
  Future<List<PItem>> getUnassignedProduct() async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.kitchen.unassignedProduct);

      return List<PItem>.from(_response.data['data'].map((x) => PItem.fromJson(x)));
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Get Unassigned Product--------------------//
}

final kitchenRepoProvider = Provider.autoDispose<KitchenRepository>(
  KitchenRepository.new,
);

final kitchenDropdownProvider = FutureProvider<KitchenListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<KitchenModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(kitchenRepoProvider).getKitchenList(noPaging: true));
  },
);

final unassignedProductsProvider = FutureProvider.autoDispose<List<PItem>>(
  (ref) => Future.microtask(ref.read(kitchenRepoProvider).getUnassignedProduct),
);
