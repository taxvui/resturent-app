import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';
import '../../../../../../widgets/widgets.dart';
import '../../../../../../data/repository/repository.dart';
import '../../../../../common/widgets/widgets.dart';

@RoutePage()
class PurchaseReportListView extends ConsumerStatefulWidget {
  const PurchaseReportListView({super.key});

  @override
  ConsumerState<PurchaseReportListView> createState() => _PurchaseReportListViewState();
}

class _PurchaseReportListViewState extends ConsumerState<PurchaseReportListView>
    with PaginatedControllerMixin<PurchaseReport> {
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
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      initRefreshListener();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.purchaseReport),
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
                            purchaseReportPDFProvider(
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
                            purchaseReportPDFProvider(
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
              child: PagedListView<int, PurchaseReport>(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<PurchaseReport>(
                  itemBuilder: (c, report, i) {
                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: TransactionCardType.purchaseReport(
                          status: report.dueAmount == 0 ? TransactionCardStatus.paid : TransactionCardStatus.due,
                        ),
                        invoiceNumber: report.invoiceNumber ?? "N/A",
                        transactionDate: report.purchaseDate,
                        paymentType: report.paymentMethod?.name,
                        primaryValue: report.totalAmount ?? 0,
                        secondaryValue: report.dueAmount ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noPurchaseFoundPleaseTryAddingPurchase,
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
  Future<PaginatedListModel<PurchaseReport>> fetchData(int page) {
    return ref
        .read(purchaseRepoProvider)
        .getPurchaseReportList(
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
