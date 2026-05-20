import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';
import '../../../../../../data/repository/repository.dart';
import '../../../../../../widgets/widgets.dart';
import '../../../../../common/widgets/widgets.dart';

@RoutePage()
class IncomeReportListView extends ConsumerStatefulWidget {
  const IncomeReportListView({super.key});

  @override
  ConsumerState<IncomeReportListView> createState() => _IncomeReportListViewState();
}

class _IncomeReportListViewState extends ConsumerState<IncomeReportListView>
    with PaginatedControllerMixin<IncomeReport> {
  final _dateFilter = ValueNotifier<DateFilterDropdownItem>(
    DropdownDateFilter.daily,
  );
  late final searchController = TextEditingController();

  @override
  void initState() {
    initPaging();
    super.initState();
  }

  @override
  void dispose() {
    pageDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      initRefreshListener();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.incomeReport),
        actions: [
          ValueListenableBuilder<DateFilterDropdownItem>(
            valueListenable: _dateFilter,
            builder: (_, value, _) {
              return DropdownDateFilter(
                value: value,
                onChanged: (v) => _dateFilter.value = v,
              );
            },
          ).fMarginSymmetric(horizontal: 16, vertical: 10),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchInvoiceNumber,
              actions: [
                const SizedBox.square(dimension: 8),
                CustomSearchFieldActionButton.pdf(
                  onPressed: () async {
                    return await showAsyncLoadingOverlay<void>(
                      context,
                      asyncFunction: () {
                        return SharedWidgets.openFile(context, () {
                          return ref.read(
                            incomeReportPDFProvider(
                              DateTimeRange(
                                start: _dateFilter.value.fromDate,
                                end: _dateFilter.value.toDate,
                              ),
                            ).future,
                          );
                        });
                      },
                    );
                  },
                ),
                const SizedBox.square(dimension: 4),
                CustomSearchFieldActionButton.print(
                  onPressed: () async {
                    return await showAsyncLoadingOverlay<void>(
                      context,
                      asyncFunction: () {
                        return SharedWidgets.printPDF(
                          context,
                          () => ref.read(
                            incomeReportPDFProvider(
                              DateTimeRange(
                                start: _dateFilter.value.fromDate,
                                end: _dateFilter.value.toDate,
                              ),
                            ).future,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Transaction List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, IncomeReport>(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 16,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<IncomeReport>(
                  itemBuilder: (c, income, i) {
                    final _tileData = IncomeExpenseListTileData(
                      name: income.incomeFor ?? "N/A",
                      amount: income.amount ?? 0,
                      categoryName: income.category?.categoryName ?? "N/A",
                      date: income.incomeDate,
                    );

                    return IncomeExpenseListTile(tileData: _tileData);
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noItemIncomeFound,
                          onRetry: pagingController.refresh,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).unfocusPrimary();
  }

  @override
  Future<PaginatedListModel<IncomeReport>> fetchData(int page) {
    return ref
        .read(incomeRepoProvider)
        .getIncomeReport(
          page: page,
          search: searchController.text,
          fromDate: _dateFilter.value.fromDate.dbFormat,
          toDate: _dateFilter.value.toDate.dbFormat,
        );
  }

  @override
  void initRefreshListener() {
    _dateFilter.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}
