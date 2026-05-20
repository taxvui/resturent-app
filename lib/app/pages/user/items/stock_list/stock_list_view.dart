/*
import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part '_stock_list_view_provider.dart';

@RoutePage()
class StockListView extends ConsumerWidget {
  const StockListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(stockListViewProvider);

    if (context.mounted) {
      controller.initRefreshListener();
    }

    return Scaffold(
      appBar: CustomAppBar(title: Text(t.pages.stock.stockList)),
      body: Column(
        children: [
          Column(
            children: [
              // Overview
              Row(
                children: [
                  Expanded(
                    child: OverviewContainer(
                      // label: 'Total Items',
                      label: t.common.totalItems,
                      value: controller.totalItems,
                      color: Color(0xffE1FFD8),
                      showCompactValue: true,
                    ),
                  ),
                  SizedBox.square(dimension: 8),
                  Expanded(
                    child: OverviewContainer(
                      label: t.common.lowStock,
                      value: controller.lowStocks,
                      color: Color(0xffFFE2E2),
                      showCompactValue: true,
                    ),
                  ),
                  SizedBox.square(dimension: 8),
                  Expanded(
                    child: OverviewContainer(
                      label: t.common.stockValue,
                      value: controller.stockValue,
                      color: Color(0xffF0E2FF),
                      isCurrency: true,
                      showCompactValue: true,
                      decimalDigits: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Search Field
              CustomSearchField(
                controller: controller.searchController,
                decoration: const CustomSearchFieldDecoration(
                  // hintText: 'Search items name',
                  hintText: t.common.searchItemsName,
                ),
                appliedFilterCount: controller.filterCount,
                onTapFilter: () async {
                  final _result = await showItemFilterBottomModalSheet(
                    context: context,
                    selectedFilters: {...controller.filters},
                  );
                  if (_result == null) {
                    return;
                  }

                  return controller.handleFilter(_result);
                },
                onChanged: (_) =>
                    Future.delayed(Durations.medium3).whenComplete(
                  controller.pagingController.refresh,
                ),
              ),
            ],
          ).fMarginLTRB(16, 16, 16, 0),

          // Items List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(controller.pagingController.refresh),
              child: PagedListView<int, PItemStock>.separated(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 72),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: controller.pagingController,
                builderDelegate: PagedChildBuilderDelegate<PItemStock>(
                  itemBuilder: (c, item, i) {
                    final _itemCardData = ItemCardData(
                      itemName: item.productName ?? "N/A",
                      imageUrl: item.images?.firstOrNull?.remote,
                      purchasePrice: item.finalPurchasePrice ?? 0,
                      salesPrice: item.finalsalesPrice ?? 0,
                      stock: item.stocksSumProductStock ?? 0,
                    );

                    return HorizontalItemCard.stockList(
                      onTap: () async {
                        return await context.router.push<void>(
                          ItemDetailsRoute(itemId: item.id!),
                        );
                      },
                      data: _itemCardData,
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          t.exceptions.noItemStockFound,
                          onRetry: controller.pagingController.refresh,
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
          )
        ],
      ),
    ).unfocusPrimary();
  }
}
*/
