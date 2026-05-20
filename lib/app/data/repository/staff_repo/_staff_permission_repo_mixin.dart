part of '_staff_repo.dart';

mixin StaffPermissionRepoMixin on BaseRepository {
  //-----------------------Get Permitted Staff-----------------------//
  Future<PermittedStaffList> getPermittedStaff({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.rolePermissions(),
        queryParameters: {
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PermittedStaffList.fromJson(
        _response.data,
        (ps) => PermittedStaff.fromJson(ps),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get role permission list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Permitted Staff-----------------------//

  //-----------------------Manage Permitted Staff-----------------------//
  Future<Either<String, PermittedStaffDetails>> managePermittedStaff(
    PermittedStaff data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.rolePermissions(data.id),
        data: _formData,
      );

      gEventListener.fire<StaffPermissionAE>(StaffPermissionModifiedAE());

      return Either.success(PermittedStaffDetails.fromJson(_response.data));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Permitted Staff-----------------------//

  //--------------------Delete Permitted Staff--------------------//
  Future<Either<String, String>> deletePermittedStaff(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.rolePermissions(id),
      );

      gEventListener.fire<StaffPermissionAE>(StaffPermissionDeletedAE(id));
      return Either.success(
        _response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? 'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }
  //--------------------Delete Permitted Staff--------------------//
}

//---------------------------Api Events---------------------------//
abstract class StaffPermissionAE extends BaseApiEvent {
  const StaffPermissionAE();
}

class StaffPermissionModifiedAE extends StaffPermissionAE {
  const StaffPermissionModifiedAE();
}

class StaffPermissionDeletedAE extends StaffPermissionAE {
  final int id;
  const StaffPermissionDeletedAE(this.id);
}
//---------------------------Api Events---------------------------//
