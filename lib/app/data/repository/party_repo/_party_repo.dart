import '../repository.dart';

class PartyRepository extends BaseRepository {
  PartyRepository(super.ref) : super(putAuthHeader: true);

  //-----------------------Get Party List-----------------------//
  Future<PartyList> getParties({
    int page = 1,
    String? search,
    String? type,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.parties(),
        queryParameters: {
          "page": page,
          "type": type,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PartyList.fromJson(
        _response.data,
        (party) => Party.fromJson(party),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get parties';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Party List-----------------------//

  //-----------------------Get Party Details-----------------------//
  Future<PartyDetailsModel> getDetails(int id) async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.parties(id));

      return PartyDetailsModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get party details';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Party Details-----------------------//

  //-----------------------Manage Party-----------------------//
  Future<Either<String, Party>> manageParty(
    Party data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);
    if (data.id != null) {
      _formData.fields.add(MapEntry("_method", 'put'));
    }

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.parties(data.id),
        data: _formData,
      );

      gEventListener.fire<PartyAE>(PartyModifiedAE());

      return Either.success(Party.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Manage Party-----------------------//

  //-------------Create Customer Delivery Address-------------//
  Future<Either<String, DeliveryAddress>> createCustomerDeliveryAddress(
    DeliveryAddress data,
  ) async {
    final _formData = await Future.microtask(data.toJson().getTypedData);

    try {
      final _response = await dioClient.post(
        DAPIEndpoints.deliveryAddress,
        data: _formData,
      );

      gEventListener.fire<PartyAE>(PartyModifiedAE());

      return Either.success(DeliveryAddress.fromJson(_response.data['data']));
    } on DioException catch (e) {
      return Either.failure(
        e.response?.data['message'] ?? e.message ?? 'Something went wrong please try again',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-------------Create Customer Delivery Address-------------//

  //--------------------Delete Party--------------------//
  Future<Either<String, String>> deleteParty(int id) async {
    try {
      final _response = await dioClient.delete(
        DAPIEndpoints.parties(id),
      );

      gEventListener.fire<PartyAE>(PartyDeletedAE(id));
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
  //--------------------Delete Party--------------------//

  //--------------------Get Party Ledger--------------------//
  Future<PaginatedPartyLedgerListModel> getPartyLedger({
    int page = 1,
    required int partyId,
    required String partyType,
    String? fromDate,
    String? toDate,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.partyLedger(partyId),
        queryParameters: {
          "page": page,
          'type': partyType,
          'from_date': fromDate,
          'to_date': toDate,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return PaginatedPartyLedgerListModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get party ledger';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------Get Party Ledger--------------------//

  //-----------------------Get Transaction List-----------------------//
  Future<TransactionList> getTransactionList({
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
    String? type,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.transactions,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "type": type,
          "search": search,
        }.removeNullValue,
      );

      return TransactionList.fromJson(
        _response.data,
        (transaction) => Transaction.fromJson(transaction),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get transaction list.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Transaction List-----------------------//

  //-----------------------Get Transaction Report-----------------------//
  Future<TransactionReportList> getTransactionReport({
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
    bool noPaging = false,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.transactionReport,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          if (noPaging) "no_paginate": 1,
        }.removeNullValue,
      );

      return TransactionReportList.fromJson(
        _response.data,
        (transaction) => TransactionReport.fromJson(transaction),
      );
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get transaction report.';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get Transaction Report-----------------------//
}

final partyRepoProvider = Provider.autoDispose<PartyRepository>(
  PartyRepository.new,
);

typedef PartyLedgerParams = ({
  int page,
  int partyId,
  String partyType,
  String? fromDate,
  String? toDate,
});

final partyLedgerListProvider = FutureProvider.autoDispose.family<PaginatedPartyLedgerListModel, PartyLedgerParams>(
  (ref, params) {
    return Future.microtask(
      () => ref
          .read(partyRepoProvider)
          .getPartyLedger(
            page: params.page,
            partyId: params.partyId,
            partyType: params.partyType,
            fromDate: params.fromDate,
            toDate: params.toDate,
          ),
    );
  },
);

final customerDropdownProvider = FutureProvider<PartyList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<PartyAE>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(partyRepoProvider).getParties(type: 'customer', noPaging: true),
    );
  },
);

final supplierDropdownProvider = FutureProvider<PartyList>(
  (ref) {
    final _apiEventSub = GlobalEventManager.I.on<PartyAE>().listen((event) {
      ref.invalidateSelf();
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(partyRepoProvider).getParties(type: 'supplier', noPaging: true),
    );
  },
);

final partyDetailsProvider = FutureProvider.family<PartyDetailsModel, int>(
  (ref, id) {
    final _apiEventSub = GlobalEventManager.I.on<PartyAE>().listen((event) {
      if (event is! PartyDeletedAE) {
        ref.invalidateSelf();
      }
    });

    ref.onDispose(_apiEventSub.cancel);

    return Future.microtask(
      () => ref.read(partyRepoProvider).getDetails(id),
    );
  },
);

//---------------------------Api Events---------------------------//
abstract class PartyAE extends BaseApiEvent {
  const PartyAE();
}

class PartyModifiedAE extends PartyAE {
  const PartyModifiedAE();
}

class PartyDeletedAE extends PartyAE {
  final int id;
  const PartyDeletedAE(this.id);
}

//---------------------------Api Events---------------------------//
