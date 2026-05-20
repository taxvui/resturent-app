part of 'due_list_view.dart';

abstract class DueFilterBase<T> extends ChangeNotifier with PaginatedControllerMixin<T> {
  Map<String, dynamic> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<String, dynamic> newFilters) {
    if (mapEquals(newFilters, filters)) return;

    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }
}

class DueListTabNotifier extends DueFilterBase<DueModel> {
  DueListTabNotifier(this.ref) {
    initPaging();
  }
  final Ref ref;

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<DueModel>> fetchData(int page) {
    final _dateFilter = ref.read(_dateFilterProvider);

    return ref
        .read(dueRepoProvider)
        .getDueList(
          page: page,
          search: searchController.text,
          fromDate: _dateFilter.fromDate.dbFormat,
          toDate: _dateFilter.toDate.dbFormat,
          status: filters['status'],
        );
  }

  @override
  void initRefreshListener() {
    final _apiEventSub = GlobalEventManager.I.on<DueAE>().listen((event) {
      pagingController.refresh();
    });

    ref.onDispose(_apiEventSub.cancel);

    ref.listen<DateFilterDropdownItem>(
      _dateFilterProvider,
      (_, _) => pagingController.refresh(),
    );
    super.initRefreshListener();
  }
}

final _dueListTabProvider = ChangeNotifierProvider.autoDispose(
  DueListTabNotifier.new,
);

class DueCollectionListTabNotifier extends DueFilterBase<DueCollection> {
  DueCollectionListTabNotifier(this.ref) {
    initPaging();
  }
  final Ref ref;

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<DueCollection>> fetchData(int page) {
    final _dateFilter = ref.read(_dateFilterProvider);

    return ref
        .read(dueRepoProvider)
        .getDueCollectionList(
          page: page,
          search: searchController.text,
          fromDate: _dateFilter.fromDate.dbFormat,
          toDate: _dateFilter.toDate.dbFormat,
          status: filters['status'],
        );
  }

  @override
  void initRefreshListener() {
    final _apiEventSub = GlobalEventManager.I.on<DueAE>().listen((event) {
      pagingController.refresh();
    });

    ref.onDispose(_apiEventSub.cancel);

    ref.listen<DateFilterDropdownItem>(
      _dateFilterProvider,
      (_, _) => pagingController.refresh(),
    );
    super.initRefreshListener();
  }
}

final _dueCollectionListTabProvider = ChangeNotifierProvider.autoDispose(
  DueCollectionListTabNotifier.new,
);
