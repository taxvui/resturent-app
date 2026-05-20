part of 'purchase_list_view.dart';

class PurchaseListViewNotifier extends _PurchaseListViewMixer {
  PurchaseListViewNotifier(super.ref);

  late final searchController = TextEditingController();

  DateFilterDropdownItem? selectedDateFilter = DropdownDateFilter.daily;
  void updateDateFilter(DateFilterDropdownItem? newFilter) {
    selectedDateFilter = newFilter;
    pagingController.refresh();
    notifyListeners();
  }

  Map<PurchaseListFilter, String?> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<PurchaseListFilter, String?> newFilters) {
    if (mapEquals(newFilters, filters)) return;

    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }

  @override
  Future<PaginatedListModel<Purchase>> fetchData(int page) {
    return repo.getPurchaseList(
      page: page,
      fromDate: selectedDateFilter?.fromDate.dbFormat,
      toDate: selectedDateFilter?.toDate.dbFormat,
      search: searchController.text,
      paymentStatus: filters[PurchaseListFilter.paymentStatus],
    );
  }

  EventSub<PurchaseApiEvent>? _apiEventSub;

  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<PurchaseApiEvent>().listen((event) {
      if (event == PurchaseApiEvent.modified) {
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

final purchaseListViewProvider = ChangeNotifierProvider.autoDispose(
  PurchaseListViewNotifier.new,
);

abstract class _PurchaseListViewMixer extends ChangeNotifier with PaginatedControllerMixin<Purchase> {
  _PurchaseListViewMixer(this.ref) : repo = ref.read(purchaseRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final PurchaseRepository repo;
}

enum PurchaseListFilter { paymentStatus }
