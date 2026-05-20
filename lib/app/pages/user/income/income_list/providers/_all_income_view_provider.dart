part of '../income_list_view.dart';

class AllIncomeListViewNotifier extends ChangeNotifier with PaginatedControllerMixin<Income> {
  AllIncomeListViewNotifier(this.ref) : repo = ref.watch(incomeRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final IncomeRepository repo;

  Map<IncomeFilter, dynamic> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<IncomeFilter, dynamic> newFilters) {
    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<Income>> fetchData(int page) {
    return Future.microtask(
      () => repo.getIncomeList(
        page: page,
        categoryId: filters[IncomeFilter.category],
        query: searchController.text,
      ),
    );
  }

  EventSub<IncomeApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<IncomeApiEvent>().listen((event) {
      if (event == IncomeApiEvent.income) {
        pagingController.refresh();
      }
    });
    super.initRefreshListener();
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }
}

final allIncomeListViewProvider = ChangeNotifierProvider.autoDispose(
  AllIncomeListViewNotifier.new,
);

enum IncomeFilter { category }
