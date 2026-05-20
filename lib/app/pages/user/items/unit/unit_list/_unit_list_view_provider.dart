part of 'unit_list_view.dart';

class UnitListViewNotifier extends _UnitListViewMixer {
  UnitListViewNotifier(super.ref) {
    initPaging();
  }

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<ItemUnit>> fetchData(int page) {
    return repo.getItemUnits(
      page: page,
      search: searchController.text,
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.unit) {
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

final unitListViewProvider = ChangeNotifierProvider.autoDispose(
  UnitListViewNotifier.new,
);

abstract class _UnitListViewMixer extends ChangeNotifier with PaginatedControllerMixin<ItemUnit> {
  _UnitListViewMixer(this.ref) : repo = ref.watch(itemsRepoProvider);
  final Ref ref;
  final ItemsRepository repo;
}
