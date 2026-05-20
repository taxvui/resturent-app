part of 'party_list_view.dart';

class AllPartiesNotifier extends PartyListNotifierBase {
  AllPartiesNotifier(super.ref, {required super.searchController});

  @override
  Future<PaginatedListModel<Party>> fetchData(int page) {
    return repo.getParties(page: page, search: searchController.text);
  }
}

class CustomerNotifier extends PartyListNotifierBase {
  CustomerNotifier(super.ref, {required super.searchController});

  @override
  Future<PaginatedListModel<Party>> fetchData(int page) {
    return repo.getParties(
      page: page,
      type: 'customer',
      search: searchController.text,
    );
  }
}

class SupplierNotifier extends PartyListNotifierBase {
  SupplierNotifier(super.ref, {required super.searchController});

  @override
  Future<PaginatedListModel<Party>> fetchData(int page) {
    return repo.getParties(
      page: page,
      type: 'supplier',
      search: searchController.text,
    );
  }
}

abstract class PartyListNotifierBase with PaginatedControllerMixin<Party> {
  PartyListNotifierBase(this.ref, {required this.searchController}) : repo = ref.watch(partyRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final PartyRepository repo;
  final TextEditingController searchController;

  EventSub<PartyAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<PartyAE>().listen((event) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

class PartyListViewNotifier extends ChangeNotifier {
  PartyListViewNotifier(this.ref) {
    allPartiesNotifier = AllPartiesNotifier(ref, searchController: searchController);
    customerNotifier = CustomerNotifier(ref, searchController: searchController);
    supplierNotifier = SupplierNotifier(ref, searchController: searchController);
  }

  final Ref ref;

  late final AllPartiesNotifier allPartiesNotifier;
  late final CustomerNotifier customerNotifier;
  late final SupplierNotifier supplierNotifier;
  late final notifiers = [
    allPartiesNotifier,
    customerNotifier,
    supplierNotifier,
  ];

  late final searchController = TextEditingController();

  void refreshAll() {
    allPartiesNotifier.pagingController.refresh();
    customerNotifier.pagingController.refresh();
    supplierNotifier.pagingController.refresh();
  }

  @override
  void dispose() {
    for (var element in notifiers) {
      element._apiEventSub?.cancel();
    }
    super.dispose();
  }
}

final partyListViewProvider = ChangeNotifierProvider.autoDispose(
  PartyListViewNotifier.new,
);
