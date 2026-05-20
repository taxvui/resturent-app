import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';
import '../../../../../../data/repository/repository.dart';
import '../../../../../../widgets/widgets.dart';
import '../../../../../common/widgets/widgets.dart';

@RoutePage()
class DueCollectionReportListView extends ConsumerStatefulWidget {
  const DueCollectionReportListView({super.key});

  @override
  ConsumerState<DueCollectionReportListView> createState() => _DueCollectionReportListViewState();
}

class _DueCollectionReportListViewState extends ConsumerState<DueCollectionReportListView>
    with PaginatedControllerMixin<DueCollectionReport> {
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
        title: Text(context.t.common.dueCollection),
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
                            dueCollectionReportPDFProvider(
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
                            dueCollectionReportPDFProvider(
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
              child: PagedListView<int, DueCollectionReport>(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 16,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<DueCollectionReport>(
                  itemBuilder: (c, dueCollection, i) {
                    late final TransactionCardStatus _status;
                    late final num _secondaryValue;

                    if (dueCollection.isFullyPaid) {
                      _status = TransactionCardStatus.paid;
                      _secondaryValue = dueCollection.totalDue ?? 0;
                    } else if (dueCollection.isPartiallyPaid) {
                      _status = TransactionCardStatus.partial;
                      _secondaryValue = dueCollection.dueAmountAfterPay ?? 0;
                    } else {
                      _status = TransactionCardStatus.due;
                      _secondaryValue = 0;
                    }

                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: TransactionCardType.dueReport(status: _status),
                        invoiceNumber: dueCollection.invoiceNumber ?? "N/A",
                        transactionDate: dueCollection.paymentDate,
                        paymentType: dueCollection.paymentType?.name,
                        primaryValue: dueCollection.totalDue ?? 0,
                        secondaryValue: _secondaryValue,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          'No item due collection invoice found!\n You can see due collection invoices when available.',
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
  Future<PaginatedListModel<DueCollectionReport>> fetchData(int page) {
    return ref
        .read(dueRepoProvider)
        .getDueCollectionReport(
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
