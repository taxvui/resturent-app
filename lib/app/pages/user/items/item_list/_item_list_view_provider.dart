part of 'item_list_view.dart';

class ItemListViewNotifier extends _ItemListViewMixer {
  ItemListViewNotifier(super.ref);

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
  Future<PaginatedListModel<PItem>> fetchData(int page) {
    return repo.getItemList(
      page: page,
      search: searchController.text,
      categoryId: filters[ItemFilterType.category],
      menuId: filters[ItemFilterType.menu],
      sortBy: filters[ItemFilterType.price],
      foodType: (filters[ItemFilterType.foodType] as ItemFoodTypeEnum?)?.stringValue,
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;

  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.item) {
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

final itemListViewProvider = ChangeNotifierProvider.autoDispose(
  ItemListViewNotifier.new,
);

abstract class _ItemListViewMixer extends ChangeNotifier with PaginatedControllerMixin<PItem> {
  _ItemListViewMixer(this.ref) : repo = ref.watch(itemsRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final ItemsRepository repo;
}
