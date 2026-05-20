part of '_sale_repo.dart';

mixin KOTOrderRepoMixin on BaseRepository {
  //-----------------------Get KOT Order List-----------------------//
  Future<KOTOrderList> getKOTOrderList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    String? status,
    int? kitchenId,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.kotOrder.list,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "status": status,
          "search": search,
          "kitchen_id": kitchenId,
        }.removeNullValue,
      );

      return KOTOrderList.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get kitchen orders list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get KOT Order List-----------------------//

  //-----------------------Manage KOT Order Status-----------------------//
  Future<String> manageKOTOrderStatus(
    int id,
    String status, {
    int? cancelReasonId,
    String? notes,
  }) async {
    try {
      final _data = {
        "status": status,
        "cancel_reason_id": cancelReasonId,
        "notes": notes,
        "_method": "put",
      }.removeNullValue;

      final _response = await dioClient.post(
        DAPIEndpoints.kotOrder.orderStaus(id),
        data: _data,
      );

      gEventListener.fire<KOTOrderAE>(KOTOrderModifiedAE());
      return _response.data?['message'] ?? 'Updated order status successfully';
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to update order status';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage KOT Order Status-----------------------//

  //-----------------------Manage KOT Order Status-----------------------//
  Future<String> manageKOTItemStatus(int id, String status) async {
    try {
      final _response = await dioClient.post(
        DAPIEndpoints.kotOrder.itemStatus(id),
        data: {"cooking_status": status, "_method": "put"},
      );

      gEventListener.fire<KOTOrderAE>(KOTOrderItemModified(id));

      return _response.data?['message'] ?? 'Updated item status successfully';
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to update item status';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage KOT Order Status-----------------------//

  //-----------------------Get Order Cancel Reason List-----------------------//
  Future<List<OrderCancelReasonModel>> getOrderCancelReasonList() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.kotOrder.orderCancelReasons,
      );

      return List<OrderCancelReasonModel>.from([
        ...?(_response.data?['data']?.map((x) => OrderCancelReasonModel.fromJson(x))),
      ]);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get kitchen orders list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Order Cancel Reason List-----------------------//

  //-----------------------Get KOT Order Report List-----------------------//
  Future<KOTOrderList> getKOTOrderReportList({
    int page = 1,
    String? fromDate,
    String? toDate,
    String? status,
    String? search,
    String? foodItemType,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.kotOrder.reports,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "status": status,
          "search": search,
          "food_type": foodItemType,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return KOTOrderList.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get kitchen orders report list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get KOT Order Report List-----------------------//
}

final orderCancelReasonListProvider = FutureProvider<List<OrderCancelReasonModel>>(
  (ref) => Future.microtask(ref.read(saleRepoProvider).getOrderCancelReasonList),
);

//---------------------------Api Events---------------------------//
abstract class KOTOrderAE extends BaseApiEvent {
  const KOTOrderAE();
}

class KOTOrderModifiedAE extends KOTOrderAE {
  const KOTOrderModifiedAE();
}

class KOTOrderItemModified extends KOTOrderAE {
  final int id;
  const KOTOrderItemModified(this.id);
}

//---------------------------Api Events---------------------------//
