import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_pos/app/core/core.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

@RoutePage()
class LossProfitListView extends ConsumerStatefulWidget {
  const LossProfitListView({super.key});

  @override
  ConsumerState<LossProfitListView> createState() => _LossProfitListViewState();
}

class _LossProfitListViewState extends ConsumerState<LossProfitListView> with PaginatedControllerMixin<LossProfit> {
  late final searchController = TextEditingController();
  final lossProfitOverview = ValueNotifier<({num totalLoss, num totalProfit})>((
    totalLoss: 0,
    totalProfit: 0,
  ));
  final selectedDateFilter = ValueNotifier<DateFilterDropdownItem>(
    DropdownDateFilter.daily,
  );
  final selectedFilter = ValueNotifier<Map<String, String?>>({
    'type': null,
  });

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
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.lossProfit.title),
        actions: [
          ValueListenableBuilder(
            valueListenable: selectedDateFilter,
            builder: (_, value, _) {
              return DropdownDateFilter(
                value: value,
                onChanged: (v) {
                  selectedDateFilter.value = v;
                  pagingController.refresh();
                },
              );
            },
          ).fMarginSymmetric(vertical: 10, horizontal: 12),
        ],
      ),
      body: Column(
        children: [
          // Static Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Overview
              ValueListenableBuilder(
                valueListenable: lossProfitOverview,
                builder: (_, value, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: OverviewContainer(
                          label: context.t.common.profit,
                          value: value.totalProfit.abs(),
                          color: Color(0xffE1FFD8),
                          isCurrency: true,
                        ),
                      ),
                      SizedBox.square(dimension: 8),
                      Expanded(
                        child: OverviewContainer(
                          label: context.t.common.loss,
                          value: value.totalLoss.abs(),
                          color: Color(0xffF0E2FF),
                          isCurrency: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Search Field
              ValueListenableBuilder(
                valueListenable: selectedFilter,
                builder: (context, value, child) {
                  return CustomSearchField(
                    controller: searchController,
                    decoration: CustomSearchFieldDecoration(
                      // hintText: 'Search invoice no',
                      hintText: context.t.common.searchInvoiceNumber,
                    ),
                    appliedFilterCount: value.entries.where((element) => element.value != null).length,
                    onTapFilter: () async {
                      return await showFilterModalSheet<String, String>(
                        context: context,
                        selectedFilters: {...value},
                        onSave: (v) {
                          selectedFilter.value = v;
                          pagingController.refresh();
                        },
                        filters: [
                          FilterModalData<String, String>.radioTiles(
                            key: 'type',
                            items: [
                              RadioFilterModalData<String>(
                                // label: 'Loss',
                                label: context.t.common.loss,
                                value: 'loss',
                              ),
                              RadioFilterModalData<String>(
                                // label: 'Profit',
                                label: context.t.common.profit,
                                value: 'profit',
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                      pagingController.refresh,
                    ),
                  );
                },
              ),
            ],
          ).fMarginLTRB(16, 16, 16, 0),

          // Loss Profit List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, LossProfit>.separated(
                padding: const EdgeInsetsDirectional.all(16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<LossProfit>(
                  itemBuilder: (c, transaction, i) {
                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: TransactionCardType.saleList(
                          status: transaction.isLoss
                              ? TransactionCardStatus.loss(
                                  value: transaction.lossProfit?.abs(),
                                )
                              : TransactionCardStatus.profit(
                                  value: transaction.lossProfit?.abs(),
                                ),
                        ),
                        invoiceNumber: transaction.invoiceNumber ?? 'N/A',
                        paymentType: transaction.paymentType?.name,
                        transactionDate: transaction.saleDate,
                        primaryValue: transaction.totalAmount ?? 0,
                        secondaryValue: transaction.lossProfit ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.pages.lossProfit.noLossProfitFound,
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
      ),
    ).unfocusPrimary();
  }

  @override
  Future<PaginatedListModel<LossProfit>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(commonRepoProvider)
          .getLossProfitList(
            page: page,
            search: searchController.text,
            type: selectedFilter.value['type'],
            fromDate: selectedDateFilter.value.fromDate.dbFormat,
            toDate: selectedDateFilter.value.toDate.dbFormat,
          ),
    );
  }

  @override
  void getRawData(PaginatedListModel<LossProfit> data) {
    final _data = (data as PaginatedLossProfitListModel);
    lossProfitOverview.value = (
      totalLoss: _data.totalLoss ?? 0,
      totalProfit: _data.totalProfit ?? 0,
    );
    super.getRawData(data);
  }
}
