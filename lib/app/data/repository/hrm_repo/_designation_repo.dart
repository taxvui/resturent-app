part of 'hrm_repo.dart';

class DesignationRepository extends BaseRepository {
  DesignationRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Designation List-----------------------//
  Future<DesignationListModel> getDesignationList({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.hrm.designations(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return DesignationListModel.fromJson(
        _response.data,
        (designation) => DesignationModel.fromJson(designation),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get designation list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Designation List-----------------------//

  //-----------------------Manage Designation-----------------------//
  Future<DesignationModel> manageDesignation(DesignationModel data) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.hrm.designations(data.id),
        data: _formData,
      );

      final _data = DesignationModel.fromJson(_response.data['data']);

      gEventListener.fire<DesignationModel>(_data);
      return _data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Designation-----------------------//

  //--------------------Delete Designation--------------------//
  Future<String> deleteDesignation(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.hrm.designations(id),
      );

      gEventListener.fire<DesignationModel>(DesignationModel.event(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Designation--------------------//
}

final designationRepoProvider = Provider.autoDispose<DesignationRepository>(
  DesignationRepository.new,
);

final designationDropdownProvider = FutureProvider<DesignationListModel>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<DesignationModel>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(designationRepoProvider).getDesignationList(noPaging: true));
  },
);
