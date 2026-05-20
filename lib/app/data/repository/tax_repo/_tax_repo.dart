import '../repository.dart';

class TaxRepository extends BaseRepository {
  TaxRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Tax List-----------------------//
  Future<TaxModelResponse> getTaxesList({
    TaxType? type,
    bool? isActive,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.taxes(),
        queryParameters: {
          "type": type?.name,
          if (isActive != null) "status": isActive ? "active" : "inactive",
        }.removeNullValue,
      );

      return TaxModelResponse.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get taxes';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Tax List-----------------------//

  //-----------------------Manage Tax-----------------------//
  Future<Either<String, TaxModel>> manageTax(
    TaxModel data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.taxes(data.id),
        data: _formData,
      );

      gEventListener.fire<TaxApiEvent>(TaxApiEvent.modified);

      final _data = TaxModel.fromJson(_response.data['data']);
      await ref.read(userRepositoryProvider.notifier).getUser();

      return Either.success(_data);
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Tax-----------------------//

  //--------------------Delete Tax--------------------//
  Future<Either<String, String>> deleteTax(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.taxes(id),
      );

      gEventListener.fire<TaxApiEvent>(TaxApiEvent.modified);
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

  //--------------------Delete Tax--------------------//
}

final taxRepoProvider = Provider.autoDispose<TaxRepository>(
  TaxRepository.new,
);

enum TaxType { single, group }

enum TaxApiEvent { modified }

final taxListProvider = FutureProvider(
  (ref) => Future.microtask(
    () => ref.read(taxRepoProvider).getTaxesList(type: TaxType.single),
  ),
);

final taxGroupProvider = FutureProvider(
  (ref) => Future.microtask(
    () => ref.read(taxRepoProvider).getTaxesList(type: TaxType.group),
  ),
);

final taxDropdownProvider = FutureProvider<TaxModelResponse>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<TaxApiEvent>().listen((event) {
      if (event == TaxApiEvent.modified) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(taxRepoProvider).getTaxesList(),
    );
  },
);
