import '../repository.dart';

part '_areas_repo_mixin.dart';

class TableRepository extends BaseRepository with AreasRepoMixin {
  TableRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Table List-----------------------//
  Future<TableList> getTables({
    int page = 1,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.tables(),
        queryParameters: {
          "page": page,
          if (search?.isNotEmpty == true) "search": search,
          if (noPaging) "no_paginate": 1,
        },
      );

      return TableList.fromJson(
        _response.data,
        (table) => PTable.fromJson(table),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get table list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Table List-----------------------//

  //-----------------------Manage Table-----------------------//
  Future<PTableDetailsModel> manageTable(
    PTable data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.tables(data.id),
        data: _formData,
      );

      gEventListener.fire<TableAE>(TableModifiedAE());

      return PTableDetailsModel.fromJson(_response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Something went wrong please try again');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Table-----------------------//

  //--------------------Delete Table--------------------//
  Future<Either<String, String>> deleteTable(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.tables(id),
      );

      gEventListener.fire<TableAE>(TableDeletedAE(id));
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

  //--------------------Delete Table--------------------//
}

final tableRepoProvider = Provider.autoDispose<TableRepository>(
  TableRepository.new,
);

final tableDropdownProvider = FutureProvider<TableList>((ref) {
  final _apiEventSub = GlobalEventManager.I.on<TableAE>().listen((event) {
    ref.invalidateSelf();
  });

  ref.onDispose(_apiEventSub.cancel);

  return Future.microtask(
    () => ref.read(tableRepoProvider).getTables(noPaging: true),
  );
});

//---------------------------Api Events---------------------------//
abstract class TableAE extends BaseApiEvent {
  const TableAE();
}

class TableModifiedAE extends TableAE {
  const TableModifiedAE();
}

class TableDeletedAE extends TableAE {
  final int id;
  const TableDeletedAE(this.id);
}

//---------------------------Api Events---------------------------//
