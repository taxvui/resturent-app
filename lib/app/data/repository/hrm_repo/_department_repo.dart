part of 'hrm_repo.dart';

class DepartmentRepository extends BaseRepository {
  DepartmentRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Department List-----------------------//
  Future<DepartmentListModel> getDepartmentList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.departments(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return DepartmentListModel.fromJson(
        _response.data,
        (department) => DepartmentModel.fromJson(department),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get department list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Department List-----------------------//

  //-----------------------Manage Department-----------------------//
  Future<DepartmentModel> manageDepartment(DepartmentModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.departments(data.id),
        data: _formData,
      );

      final _data = DepartmentModel.fromJson(_response.data['data']);

      gEventListener.fire<DepartmentModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Department-----------------------//

  //--------------------Delete Department--------------------//
  Future<String> deleteDepartment(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.departments(id),
      );

      gEventListener.fire<DepartmentModel>(DepartmentModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Department--------------------//
}

final departmentRepoProvider = Provider.autoDispose<DepartmentRepository>(
  DepartmentRepository.new,
);

final departmentDropdownProvider = FutureProvider<DepartmentListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<DepartmentModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(departmentRepoProvider).getDepartmentList(noPaging: true));
  },
);
