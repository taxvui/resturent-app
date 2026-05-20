/*
import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../../i18n/strings.g.dart';
import '../../../../../../core/core.dart';
import '../../../../../../widgets/widgets.dart';
import '../../../../../../data/repository/repository.dart';
import '../../../../../common/widgets/widgets.dart';

@RoutePage()
class StockReportListView extends ConsumerStatefulWidget {
  const StockReportListView({super.key});

  @override
  ConsumerState<StockReportListView> createState() => _StockReportListViewState();
}

class _StockReportListViewState extends ConsumerState<StockReportListView> with PaginatedControllerMixin<PStockReport> {
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
        title: Text(t.common.stockReport),
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
              hintText: t.common.searchInvoiceNumber,
              actions: [
                const SizedBox.square(dimension: 8),
                CustomSearchFieldActionButton.pdf(
                  onPressed: () async {
                    return await showAsyncLoadingOverlay<void>(
                      context,
                      asyncFunction: () {
                        return SharedWidgets.openFile(context, () {
                          return ref.read(
                            stockReportPDFProvider(
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
                            stockReportPDFProvider(
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

          // Stock List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, PStockReport>(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 16,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<PStockReport>(
                  itemBuilder: (c, stock, i) {
                    return StockReportCard(
                      cardData: ItemStock(
                        itemName: stock.productName ?? "N/A",
                        stock: stock.stocksSumProductStock ?? 0,
                        purchasePrice: stock.finalPurchasePrice ?? 0,
                        salesPrice: stock.finalsalesPrice ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          t.exceptions.noItemStockFound,
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
  Future<PaginatedListModel<PStockReport>> fetchData(int page) {
    return ref.read(itemsRepoProvider).getStockItemReport(
          page: page,
          search: searchController.text,
          fromDate: _dateFilter.value.fromDate.dbFormat,
          toDate: _dateFilter.value.toDate.dbFormat,
        );
  }

  @override
  void initRefreshListener() {
    _dateFilter.addListener(pagingController.refresh);
  }
}

class StockReportCard extends StatelessWidget {
  const StockReportCard({super.key, required this.cardData});
  final ItemStock cardData;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _cTextStyle = _theme.textTheme.bodyMedium?.copyWith(
      color: _theme.colorScheme.secondary,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item Name
          Text(
            cardData.itemName,
            style: _theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox.square(dimension: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stock
                    Text(
                      'Stock: ${cardData.stock}',
                      style: _cTextStyle,
                    ),

                    // Purchase Price
                    Text(
                      '${t.common.purchase}: ${cardData.purchasePrice.quickCurrency(decimalDigits: 2)}',
                      style: _cTextStyle?.copyWith(fontSize: 13),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stock
                    Text(
                      '${t.common.stockValue}: ${cardData.stockValue.quickCurrency(decimalDigits: 2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _cTextStyle,
                    ),

                    // Purchase Price
                    Text(
                      '${t.common.sales}: ${cardData.salesPrice.quickCurrency(decimalDigits: 2)}',
                      style: _cTextStyle?.copyWith(fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class ItemStock {
  final String itemName;
  final int stock;
  final num purchasePrice;
  final num salesPrice;
  num get stockValue => stock * purchasePrice;

  const ItemStock({
    required this.itemName,
    required this.stock,
    required this.purchasePrice,
    required this.salesPrice,
  });
}
*/
