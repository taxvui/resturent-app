part of 'hrm_repo.dart';

class LeaveRepository extends BaseRepository {
  LeaveRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Leave List-----------------------//
  Future<LeaveListModel> getLeaveList({
    int page = 1,
    String? search,
    int? employeeId,
    String? month,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.leaves(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "employee_id": ?employeeId,
          if (month?.isNotEmpty == true) "month": month,
          if (noPaging) "no_paginate": 1,
        },
      );

      return LeaveListModel.fromJson(
        _response.data,
        (leave) => LeaveModel.fromJson(leave),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get leave list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Leave List-----------------------//

  //-----------------------Manage Leave-----------------------//
  Future<LeaveModel> manageLeave(LeaveModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.leaves(data.id),
        data: _formData,
      );

      final _data = LeaveModel.fromJson(_response.data['data']);

      gEventListener.fire<LeaveModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Leave-----------------------//

  //--------------------Delete Leave--------------------//
  Future<String> deleteLeave(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.leaves(id),
      );

      gEventListener.fire<LeaveModel>(LeaveModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Leave--------------------//

  //-----------------------Get Leave Report List-----------------------//
  Future<LeaveListModel> getLeaveReportList({
    int page = 1,
    String? search,
    int? employeeId,
    String? month,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.reports.leaves,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "employee_id": ?employeeId,
          if (month?.isNotEmpty == true) "month": month,
          if (noPaging) "no_paginate": 1,
        },
      );

      return LeaveListModel.fromJson(
        _response.data,
        (leave) => LeaveModel.fromJson(leave),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get leave list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get Leave Report List-----------------------//
}

final leaveRepoProvider = Provider.autoDispose<LeaveRepository>(
  LeaveRepository.new,
);
