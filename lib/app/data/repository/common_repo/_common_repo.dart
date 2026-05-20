import '../../../widgets/widgets.dart' show DropdownDateFilter, DateFilterDropdownItem;
import '../repository.dart';

class CommonRepository extends BaseRepository {
  CommonRepository(super.ref) : super(putAuthHeader: true);

  //--------------------------Get Terms & Conditions--------------------------//
  Future<SummerNoteModel2> getTermsCondition() async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.termsConditions);

      return SummerNoteModel2.fromJson(_response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to terms & conditions.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------------Get Terms & Conditions--------------------------//

  //--------------------------Get Privacy & Policy--------------------------//
  Future<SummerNoteModel2> getPrivacyPolicy() async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.privacyPolicy);

      return SummerNoteModel2.fromJson(_response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to privacy & policy.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------------Get Privacy & Policy--------------------------//

  //--------------------------Get About Us--------------------------//
  Future<SummerNoteModel> getAboutUs() async {
    try {
      final _response = await dioClient.get(DAPIEndpoints.aboutUs);

      return SummerNoteModel.fromJson(_response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to about us.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //--------------------------Get About Us--------------------------//

  //-----------------------Get Money In/Out List-----------------------//
  Future<PaginatedMoneyInOutListModel> getMoneyInOutList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    String? salesType,
    required String type,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.moneyInOut,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          "sales_type": salesType,
          "type": type,
        }.removeNullValue,
      );

      return PaginatedMoneyInOutListModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get item list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Money In/Out List-----------------------//

  //-----------------------Get Loss/Profit List-----------------------//

  /// [type] = 'loss' or 'profit'
  Future<PaginatedLossProfitListModel> getLossProfitList({
    int page = 1,
    String? search,
    String? fromDate,
    String? toDate,
    String? type,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.lossProfit,
        queryParameters: {
          "page": page,
          "from_date": fromDate,
          "to_date": toDate,
          "search": search,
          "loss_profit": type,
        }.removeNullValue,
      );

      return PaginatedLossProfitListModel.fromJson(_response.data);
    } on DioException catch (e) {
      final _message = e.response?.data['message'] ?? 'Failed to get loss profit list';
      throw Exception(_message);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Loss/Profit List-----------------------//

  //-----------------------Get Dashboard Overview-----------------------//
  Future<DashboardResponseModel<DashboardSummary>> getDashboardSummary({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dashboardSummary,
        queryParameters: {
          "from_date": fromDate,
          "to_date": toDate,
        }.removeNullValue,
      );

      return DashboardResponseModel<DashboardSummary>.fromJson(
        _response.data,
        (data) => DashboardSummary.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to dashboard summary.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Dashboard Overview-----------------------//

  //-----------------------Get Dashboard Chart-----------------------//
  Future<DashboardResponseModel<DashboardChart>> getDashboardChart({
    required String duration,
  }) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.dashboardChart,
        queryParameters: {"duration": duration},
      );

      return DashboardResponseModel<DashboardChart>.fromJson(
        _response.data,
        (data) => DashboardChart.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to dashboard chart.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Get Dashboard Chart-----------------------//

  //-----------------------Currency-----------------------//
  Future<CurrencyReponseModel> getCurrency([int? id]) async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.currencies(id),
      );

      return CurrencyReponseModel.fromJson(_response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to dashboard chart.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  //-----------------------Currency-----------------------//

  //-----------------------Get Modules-----------------------//
  Future<ModulesModel> getModules() async {
    try {
      final _response = await dioClient.get(
        DAPIEndpoints.modules,
      );

      return ModulesModel.fromJson(_response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed get modules data');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  //-----------------------Get Modules-----------------------//
}

final commonRepoProvider = Provider.autoDispose<CommonRepository>(
  (ref) => CommonRepository(ref),
);

final overviewDateFilterProvider = StateProvider.autoDispose<DateFilterDropdownItem>(
  (ref) => DropdownDateFilter.daily,
);
final chartDateFilterProvider = StateProvider.autoDispose<DateFilterDropdownItem>(
  (ref) => DropdownDateFilter.weekly,
);

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardResponseModel<DashboardSummary>>(
  (ref) {
    final dateFilter = ref.watch(overviewDateFilterProvider);

    return ref
        .read(commonRepoProvider)
        .getDashboardSummary(
          fromDate: dateFilter.fromDate.dbFormat,
          toDate: dateFilter.toDate.dbFormat,
        );
  },
);

final dashboardChartProvider = FutureProvider.autoDispose<DashboardResponseModel<DashboardChart>>(
  (ref) {
    final dateFilter = ref.watch(chartDateFilterProvider);

    return ref
        .read(commonRepoProvider)
        .getDashboardChart(
          duration: dateFilter.key,
        );
  },
);

final recentTransactionProvider = FutureProvider.autoDispose(
  (ref) => Future.microtask(
    () => ref.read(partyRepoProvider).getTransactionList(),
  ),
);

final currencyListProvider = FutureProvider(
  (ref) => Future.microtask(ref.read(commonRepoProvider).getCurrency),
);

final modulesProvider = FutureProvider<ModulesModel>(
  (ref) => Future.microtask(ref.read(commonRepoProvider).getModules),
);
