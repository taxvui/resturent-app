import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

class MoneyInOutListViewNotifier extends ChangeNotifier with PaginatedControllerMixin<MoneyInOutModel> {
  MoneyInOutListViewNotifier(this.ref, this.type) : _repo = ref.read(commonRepoProvider) {
    initPaging();
  }

  final Ref ref;
  final CommonRepository _repo;
  final String type;

  DateFilterDropdownItem? selectedDateFilter = DropdownDateFilter.daily;
  void updateDateFilter(DateFilterDropdownItem? newFilter) {
    selectedDateFilter = newFilter;
    pagingController.refresh();
    notifyListeners();
  }

  late final searchController = TextEditingController();
  Map<String, String?> filters = {};
  int get filterCount {
    return filters.entries.where((element) => element.value?.trim().isNotEmpty == true).length;
  }

  void handleFilter(Map<String, String?> newFilters) {
    if (mapEquals(newFilters, filters)) return;

    filters
      ..clear()
      ..addAll(newFilters);
    pagingController.refresh();
    notifyListeners();
  }

  @override
  Future<PaginatedListModel<MoneyInOutModel>> fetchData(int page) {
    return _repo.getMoneyInOutList(
      page: page,
      type: type,
      salesType: filters['sales_type'],
      search: searchController.text,
      fromDate: selectedDateFilter?.fromDate.dbFormat,
      toDate: selectedDateFilter?.toDate.dbFormat,
    );
  }

  num totalAmount = 0;
  @override
  void getRawData(PaginatedListModel<MoneyInOutModel> data) {
    final xData = (data as PaginatedMoneyInOutListModel);
    totalAmount = xData.amount ?? 0;
    notifyListeners();
    super.getRawData(data);
  }

  @override
  void pageDispose() {
    searchController.dispose();
    super.pageDispose();
  }
}

final moneyInOutListViewProvider = ChangeNotifierProvider.autoDispose.family<MoneyInOutListViewNotifier, String>(
  (ref, arg) => MoneyInOutListViewNotifier(ref, arg),
);
