part of 'hrm_repo.dart';

class EmployeeRepository extends BaseRepository {
  EmployeeRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Employee List-----------------------//
  Future<EmployeeListModel> getEmployeeList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.employees(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return EmployeeListModel.fromJson(
        _response.data,
        (employee) => EmployeeModel.fromJson(employee),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get employee list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Employee List-----------------------//

  //-----------------------Manage Employee-----------------------//
  Future<EmployeeModel> manageEmployee(EmployeeModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.employees(data.id),
        data: _formData,
      );

      final _data = EmployeeModel.fromJson(_response.data['data']);

      gEventListener.fire<EmployeeModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Employee-----------------------//

  //--------------------Delete Employee--------------------//
  Future<String> deleteEmployee(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.employees(id),
      );

      gEventListener.fire<EmployeeModel>(EmployeeModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Employee--------------------//
}

final employeeRepoProvider = Provider.autoDispose<EmployeeRepository>(
  EmployeeRepository.new,
);

final employeeDropdownProvider = FutureProvider<EmployeeListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<EmployeeModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(employeeRepoProvider).getEmployeeList(noPaging: true));
  },
);
