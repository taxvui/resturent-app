part of 'category_list_view.dart';

class CategoryListViewNotifier extends _CategoryListViewMixer {
  CategoryListViewNotifier(super.ref) {
    initPaging();
  }

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<ItemCategory>> fetchData(int page) {
    return repo.getItemCategories(
      page: page,
      search: searchController.text,
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.category) {
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

final categoryListViewProvider = ChangeNotifierProvider.autoDispose(
  CategoryListViewNotifier.new,
);

abstract class _CategoryListViewMixer extends ChangeNotifier with PaginatedControllerMixin<ItemCategory> {
  _CategoryListViewMixer(this.ref) : repo = ref.watch(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository repo;
}
