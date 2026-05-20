part of 'hrm_repo.dart';

class LeaveTypeRepository extends BaseRepository {
  LeaveTypeRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Leave Type List-----------------------//
  Future<LeaveTypeListModel> getLeaveTypeList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.leaveTypes(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return LeaveTypeListModel.fromJson(
        _response.data,
        (leaveType) => LeaveTypeModel.fromJson(leaveType),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get leave type list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Leave Type List-----------------------//

  //-----------------------Manage Leave Type-----------------------//
  Future<LeaveTypeModel> manageLeaveType(LeaveTypeModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.leaveTypes(data.id),
        data: _formData,
      );

      final _data = LeaveTypeModel.fromJson(_response.data['data']);

      gEventListener.fire<LeaveTypeModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Leave Type-----------------------//

  //--------------------Delete Leave Type--------------------//
  Future<String> deleteLeaveType(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.leaveTypes(id),
      );

      gEventListener.fire<LeaveTypeModel>(LeaveTypeModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Leave Type--------------------//
}

final leaveTypeRepoProvider = Provider.autoDispose<LeaveTypeRepository>(
  LeaveTypeRepository.new,
);

final leaveTypeDropdownProvider = FutureProvider<LeaveTypeListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<LeaveTypeModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(leaveTypeRepoProvider).getLeaveTypeList(noPaging: true));
  },
);
