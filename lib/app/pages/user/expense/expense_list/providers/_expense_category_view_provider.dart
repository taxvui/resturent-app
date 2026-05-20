part of '../expense_list_view.dart';

class ExpenseCategoryListViewNotifier extends ChangeNotifier with PaginatedControllerMixin<ExpenseCategory> {
  ExpenseCategoryListViewNotifier(this.ref) : repo = ref.watch(expenseRepoProvider) {
    initPaging();
  }

  final Ref ref;
  final ExpenseRepository repo;

  late final searchController = TextEditingController();

  @override
  Future<PaginatedListModel<ExpenseCategory>> fetchData(int page) {
    return Future.microtask(
      () => repo.getExpenseCategories(
        page: page,
        search: searchController.text,
      ),
    );
  }

  @override
  void initRefreshListener() {
    final _apiEventSub = GlobalEventManager.I.on<ExpenseApiEvent>().listen((event) {
      if (event == ExpenseApiEvent.category) {
        pagingController.refresh();
      }
    });

    ref.onDispose(_apiEventSub.cancel);
    super.initRefreshListener();
  }
}

final expenseCategoryListViewProvider = ChangeNotifierProvider.autoDispose(
  ExpenseCategoryListViewNotifier.new,
);
