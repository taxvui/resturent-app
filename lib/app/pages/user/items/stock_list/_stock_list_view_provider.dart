part of 'stock_list_view.dart';

/*
class StockListViewNotifier extends _StockListViewMixer {
  StockListViewNotifier(super.ref);

  late final searchController = TextEditingController();

  Map<ItemFilterType, dynamic> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<ItemFilterType, dynamic> newFilters) {
    if (mapEquals(newFilters, filters)) return;

    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }

  @override
  Future<PaginatedListModel<PItemStock>> fetchData(int page) {
    return repo.getStockItemList(
      page: page,
      search: searchController.text,
      categoryId: filters[ItemFilterType.category],
      sortBy: filters[ItemFilterType.price],
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub =
        GlobalEventListener.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.item) {
        pagingController.refresh();
      }
    });
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }
}

final stockListViewProvider = ChangeNotifierProvider.autoDispose(
  StockListViewNotifier.new,
);

abstract class _StockListViewMixer extends ChangeNotifier
    with PaginatedControllerMixin<PItemStock> {
  _StockListViewMixer(this.ref) : repo = ref.watch(itemsRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final ItemsRepository repo;

  int totalItems = 0;
  int lowStocks = 0;
  num stockValue = 0;

  @override
  void getRawData(PaginatedListModel<PItemStock> data) {
    final xData = (data as PaginatedStockListModel);

    totalItems = xData.totalProducts ?? 0;
    lowStocks = xData.lowStockCount ?? 0;
    stockValue = xData.totalStockValue ?? 0;
    notifyListeners();
    super.getRawData(data);
  }
}
*/
