part of 'hrm_repo.dart';

class AttendanceRepository extends BaseRepository {
  AttendanceRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Attendance List-----------------------//
  Future<AttendanceListModel> getAttendanceList({
    int page = 1,
    String? search,
    int? employeeId,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.attendances(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "employee_id": ?employeeId,
          if (fromDate?.isNotEmpty == true) "from_date": fromDate,
          if (toDate?.isNotEmpty == true) "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        },
      );

      return AttendanceListModel.fromJson(
        _response.data,
        (attendance) => AttendanceModel.fromJson(attendance),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get attendance list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Attendance List-----------------------//

  //-----------------------Manage Attendance-----------------------//
  Future<AttendanceModel> manageAttendance(AttendanceModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.attendances(data.id),
        data: _formData,
      );

      final _data = AttendanceModel.fromJson(_response.data['data']);

      gEventListener.fire<AttendanceModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Attendance-----------------------//

  //--------------------Delete Attendance--------------------//
  Future<String> deleteAttendance(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.attendances(id),
      );

      gEventListener.fire<AttendanceModel>(AttendanceModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Attendance--------------------//

  //-----------------------Get Attendance Report List-----------------------//
  Future<AttendanceListModel> getAttendanceReportList({
    int page = 1,
    int? employeeId,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.reports.attendances,
        queryParameters: {
          "page": page,
          "employee_id": ?employeeId,
          if (fromDate?.isNotEmpty == true) "from_date": fromDate,
          if (toDate?.isNotEmpty == true) "to_date": toDate,
          if (noPaging) "no_paginate": 1,
        },
      );

      return AttendanceListModel.fromJson(
        _response.data,
        (attendance) => AttendanceModel.fromJson(attendance),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get attendance list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get Attendance Report List-----------------------//
}

final attendanceRepoProvider = Provider.autoDispose<AttendanceRepository>(
  AttendanceRepository.new,
);
