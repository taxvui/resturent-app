part of '_table_repo.dart';

mixin AreasRepoMixin on BaseRepository {
  //-----------------------Get Areas-----------------------//
  Future<AreaList> getAreas({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.areas(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return AreaList.fromJson(
        _response.data,
        (area) => AreaModel.fromJson(area),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get table areas';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Areas-----------------------//

  //-----------------------Manage Area-----------------------//
  Future<AreaModel> manageArea(
    AreaModel data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.areas(data.id),
        data: _formData,
      );

      gEventListener.fire<AreaModifiedAE>(AreaModifiedAE());
      return AreaModel.fromJson(_response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Area-----------------------//

  //--------------------Delete Area--------------------//
  Future<String> deleteArea(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.areas(id),
      );

      gEventListener.fire<AreaDeletedAE>(AreaDeletedAE(id));
      return _response.data?['message'] ?? 'Deleted successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Something went wrong, please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Area--------------------//
}

final areasDropdownProvider = FutureProvider<AreaList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<AreaAE>().listen((_) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(() => ref.read(tableRepoProvider).getAreas(noPaging: true));
  },
);

//---------------------------Api Events---------------------------//
abstract class AreaAE extends BaseApiEvent {
  const AreaAE();
}

class AreaModifiedAE extends AreaAE {
  const AreaModifiedAE();
}

class AreaDeletedAE extends AreaAE {
  final int id;
  const AreaDeletedAE(this.id);
}

//---------------------------Api Events---------------------------//
