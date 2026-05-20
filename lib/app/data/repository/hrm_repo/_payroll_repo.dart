part of 'hrm_repo.dart';

class PayrollRepository extends BaseRepository {
  PayrollRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Payroll List-----------------------//
  Future<PayrollListModel> getPayrollList({
    int page = 1,
    String? search,
    int? employeeId,
    String? month,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.payrolls(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "employee_id": ?employeeId,
          if (month?.isNotEmpty == true) "month": month,
          if (noPaging) "no_paginate": 1,
        },
      );

      return PayrollListModel.fromJson(
        _response.data,
        (payroll) => PayrollModel.fromJson(payroll),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get payroll list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Payroll List-----------------------//

  //-----------------------Manage Payroll-----------------------//
  Future<PayrollModel> managePayroll(PayrollModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.payrolls(data.id),
        data: _formData,
      );

      final _data = PayrollModel.fromJson(_response.data['data']);

      gEventListener.fire<PayrollModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Payroll-----------------------//

  //--------------------Delete Payroll--------------------//
  Future<String> deletePayroll(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.payrolls(id),
      );

      gEventListener.fire<PayrollModel>(PayrollModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Payroll--------------------//

  //-----------------------Get Payroll Report List-----------------------//
  Future<PayrollListModel> getPayrollReportList({
    int page = 1,
    String? search,
    int? employeeId,
    String? month,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.reports.payrolls,
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          "employee_id": ?employeeId,
          if (month?.isNotEmpty == true) "month": month,
          if (noPaging) "no_paginate": 1,
        },
      );

      return PayrollListModel.fromJson(
        _response.data,
        (payroll) => PayrollModel.fromJson(payroll),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get payroll list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get Payroll Report List-----------------------//
}

final payrollRepoProvider = Provider.autoDispose<PayrollRepository>(
  PayrollRepository.new,
);
