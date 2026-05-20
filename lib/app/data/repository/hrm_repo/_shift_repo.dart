part of 'hrm_repo.dart';

class ShiftRepository extends BaseRepository {
  ShiftRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Shift List-----------------------//
  Future<ShiftListModel> getShiftList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.shifts(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return ShiftListModel.fromJson(
        _response.data,
        (shift) => ShiftModel.fromJson(shift),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get shift list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Shift List-----------------------//

  //-----------------------Manage Shift-----------------------//
  Future<ShiftModel> manageShift(ShiftModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.shifts(data.id),
        data: _formData,
      );

      final _data = ShiftModel.fromJson(_response.data['data']);

      gEventListener.fire<ShiftModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Shift-----------------------//

  //--------------------Delete Shift--------------------//
  Future<String> deleteShift(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.shifts(id),
      );

      gEventListener.fire<ShiftModel>(ShiftModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Shift--------------------//
}

final shiftRepoProvider = Provider.autoDispose<ShiftRepository>(
  ShiftRepository.new,
);

final shiftDropdownProvider = FutureProvider<ShiftListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<ShiftModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(shiftRepoProvider).getShiftList(noPaging: true));
  },
);
