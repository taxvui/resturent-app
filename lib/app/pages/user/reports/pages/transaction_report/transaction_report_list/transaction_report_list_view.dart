import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';
import '../../../../../../data/repository/repository.dart';
import '../../../../../../widgets/widgets.dart';
import '../../../../../common/widgets/widgets.dart';

@RoutePage()
class TransactionReportListView extends ConsumerStatefulWidget {
  const TransactionReportListView({super.key});

  @override
  ConsumerState<TransactionReportListView> createState() => _TransactionReportListViewState();
}

class _TransactionReportListViewState extends ConsumerState<TransactionReportListView>
    with PaginatedControllerMixin<TransactionReport> {
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
        title: Text(context.t.common.transactionReport),
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
                            transactionReportPDFProvider(
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
                            transactionReportPDFProvider(
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
              child: PagedListView<int, TransactionReport>(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<TransactionReport>(
                  itemBuilder: (c, report, i) {
                    late final TransactionCardType _cardType;

                    if (report.isSale) {
                      _cardType = TransactionCardType.saleList();
                    } else {
                      if (report.isPaid) {
                        _cardType = TransactionCardType.purchaseList(
                          status: TransactionCardStatus.paid,
                        );
                      } else {
                        _cardType = TransactionCardType.purchaseList(
                          status: TransactionCardStatus.due,
                        );
                      }
                    }

                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: _cardType,
                        invoiceNumber: report.invoiceNumber ?? "N/A",
                        transactionDate: report.date,
                        paymentType: report.paymentType?.name,
                        primaryValue: report.totalAmount ?? 0,
                        secondaryValue: (report.isPaid ? report.paidAmount : report.dueAmount) ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noTransactionFoundYouSeeTransactionHereWhenAvailable,
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
  Future<PaginatedListModel<TransactionReport>> fetchData(int page) {
    return ref
        .read(partyRepoProvider)
        .getTransactionList(
          page: page,
          fromDate: _dateFilter.value.fromDate.dbFormat,
          toDate: _dateFilter.value.toDate.dbFormat,
          search: searchController.text,
        );
  }

  @override
  void initRefreshListener() {
    _dateFilter.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}
