part of '../expense_list_view.dart';

class AllExpenseListViewNotifier extends ChangeNotifier with PaginatedControllerMixin<Expense> {
  AllExpenseListViewNotifier(this.ref) : repo = ref.watch(expenseRepoProvider) {
    initPaging();
  }
  final Ref ref;
  final ExpenseRepository repo;

  Map<ExpenseFilter, dynamic> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value != null).length;
  }

  void handleFilter(Map<ExpenseFilter, dynamic> newFilters) {
    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<Expense>> fetchData(int page) {
    return Future.microtask(
      () => repo.getExpenseList(
        page: page,
        categoryId: filters[ExpenseFilter.category],
        query: searchController.text,
      ),
    );
  }

  @override
  void initRefreshListener() {
    final _apiEventSub = GlobalEventManager.I.on<ExpenseApiEvent>().listen((event) {
      if (event == ExpenseApiEvent.expense) {
        pagingController.refresh();
      }
    });

    ref.onDispose(_apiEventSub.cancel);
    super.initRefreshListener();
  }
}

final allExpenseListViewProvider = ChangeNotifierProvider.autoDispose(
  AllExpenseListViewNotifier.new,
);

enum ExpenseFilter { category }
