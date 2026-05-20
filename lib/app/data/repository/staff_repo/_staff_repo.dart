import '../repository.dart';

part '_staff_permission_repo_mixin.dart';

class StaffDesignationRepository extends BaseRepository with StaffPermissionRepoMixin {
  StaffDesignationRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Staff List-----------------------//
  Future<StaffList> getStaffList({
    int page = 1,
    String? designation,
    String? query,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.staffs(),
        queryParameters: {
          "designation": designation,
          "search": query,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return StaffList.fromJson(
        _response.data,
        (staff) => StaffModel.fromJson(staff),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get Staff list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Staff List-----------------------//

  //-----------------------Manage Staff-----------------------//
  Future<Either<String, StaffModel>> manageStaff(
    StaffModel data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.staffs(data.id),
        data: _formData,
      );

      gEventListener.fire<StaffAE>(StaffModifiedAE());
      return Either.success(StaffModel.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Staff-----------------------//

  //--------------------Delete Staff--------------------//
  Future<Either<String, String>> deleteStaff(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.staffs(id),
      );

      gEventListener.fire<StaffAE>(StaffDeletedAE(id));
      return Either.success(
        _response.data?['message'] ?? 'Deleted successfully',
      );
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong, please try again',
      );
    } catch (e) {
      return Either.failure('An unexpected error occurred: $e');
    }
  }

  //--------------------Delete Staff--------------------//
}

final staffDesignationRepoProvider = Provider.autoDispose(
  StaffDesignationRepository.new,
);

final allStaffDropdownProvider = FutureProvider<StaffList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<StaffAE>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(staffDesignationRepoProvider).getStaffList(noPaging: true),
    );
  },
);

final waiterDropdownProvider = FutureProvider<StaffList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<StaffAE>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(staffDesignationRepoProvider).getStaffList(noPaging: true, designation: 'waiter'),
    );
  },
);

//---------------------------Api Events---------------------------//
abstract class StaffAE extends BaseApiEvent {
  const StaffAE();
}

class StaffModifiedAE extends StaffAE {
  const StaffModifiedAE();
}

class StaffDeletedAE extends StaffAE {
  final int id;
  const StaffDeletedAE(this.id);
}

//---------------------------Api Events---------------------------//
