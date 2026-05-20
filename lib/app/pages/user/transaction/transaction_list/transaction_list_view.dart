import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

@RoutePage()
class TransactionListView extends ConsumerStatefulWidget {
  const TransactionListView({super.key});

  @override
  ConsumerState<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<TransactionListView>
    with PaginatedControllerMixin<TransactionReport> {
  late final searchController = TextEditingController();
  final filters = ValueNotifier<Map<String, String?>>({});
  final _dateFilter = ValueNotifier<DateFilterDropdownItem>(
    DropdownDateFilter.daily,
  );

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
        title: Text(context.t.common.transaction),
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
          ValueListenableBuilder(
            valueListenable: filters,
            builder: (_, value, _) {
              return CustomSearchField(
                controller: searchController,
                decoration: const CustomSearchFieldDecoration(
                  hintText: 'Search invoice no',
                ),
                appliedFilterCount: value.length,
                onTapFilter: () async {
                  return await showFilterModalSheet<String, String>(
                    context: context,
                    selectedFilters: {...value},
                    filters: [
                      FilterModalData.radioTiles(
                        key: 'transaction_type',
                        items: [
                          RadioFilterModalData(
                            // label: 'Sales',
                            label: context.t.common.sales,
                            value: 'sales_credit',
                          ),
                          RadioFilterModalData(
                            // label: 'Purchase',
                            label: context.t.common.purchase,
                            value: 'purchase_debit',
                          ),
                          RadioFilterModalData(
                            // label: 'Money In',
                            label: context.t.common.moneyIn,
                            value: 'money_in_credit',
                          ),
                          RadioFilterModalData(
                            // label: 'Money Out',
                            label: context.t.common.moneyOut,
                            value: 'money_out_debit',
                          ),
                        ],
                      ),
                    ],
                    onSave: (v) => filters.value = v,
                  );
                },
                onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                  pagingController.refresh,
                ),
              );
            },
          ),

          // Transaction List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, TransactionReport>.separated(
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
                separatorBuilder: (c, i) {
                  return const SizedBox.square(dimension: 6);
                },
              ),
            ),
          ),
        ],
      ).fMarginLTRB(16, 16, 16, 0),
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
          type: switch (filters.value['transaction_type']) {
            "sales_credit" || "money_in_credit" => 'credit',
            "purchase_debit" || "money_out_debit" => 'debit',
            _ => null,
          },
        );
  }

  @override
  void initRefreshListener() {
    _dateFilter.addListener(pagingController.refresh);
    filters.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}
