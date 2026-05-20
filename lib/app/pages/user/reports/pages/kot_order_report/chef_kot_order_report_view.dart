import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/model/model.dart' as model;
import '../../../../../data/repository/repository.dart' as repo;
import '../../../../../services/services.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../orders/components/components.dart';

@RoutePage()
class ChefKotOrderReportView extends ConsumerStatefulWidget {
  const ChefKotOrderReportView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  ConsumerState<ChefKotOrderReportView> createState() => _ChefKotOrderReportViewState();
}

class _ChefKotOrderReportViewState extends ConsumerState<ChefKotOrderReportView>
    with PaginatedControllerMixin<model.KOTOrder> {
  //------------------------State Vars------------------------//
  final _dateFilter = ValueNotifier<DateFilterDropdownItem>(
    DropdownDateFilter.daily,
  );
  final selectedFiltersNotifier = ValueNotifier<Map<String, dynamic>>({
    "order_status": null,
    "food_item_type": null,
  });
  late final searchController = TextEditingController();
  //------------------------State Vars------------------------//

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: Text(context.t.common.allKOT),
        actions: [
          ValueListenableBuilder(
            valueListenable: _dateFilter,
            builder: (_, selectedDateFilter, child) {
              return DropdownDateFilter(
                value: selectedDateFilter,
                onChanged: _dateFilter.set,
              ).fMarginSymmetric(horizontal: 8, vertical: 10);
            },
          ),

          if (widget.scaffoldKey != null) ...[
            const NotificationButton(),
          ],

          const SizedBox.square(dimension: 8),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: Column(
          children: [
            // Search Field
            CustomSearchField(
              controller: searchController,
              decoration: CustomSearchFieldDecoration(
                hintText: context.t.common.search,
                actions: [
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.pdf(
                    onPressed: () async {
                      return await showAsyncLoadingOverlay<void>(
                        context,
                        asyncFunction: () {
                          return SharedWidgets.openFile(context, () {
                            return ref.read(
                              kotOrderReportPDFProvider(
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
                              kotOrderReportPDFProvider(
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
                suffixIcon: IconButton.outlined(
                  onPressed: () => showFilterBottomModal(context),
                  style: IconButton.styleFrom(
                    shape: const RoundedRectangleBorder(),
                    side: Divider.createBorderSide(context, width: 1.25),
                    foregroundColor: _theme.colorScheme.outline,
                  ),
                  icon: ValueListenableBuilder(
                    valueListenable: selectedFiltersNotifier,
                    builder: (_, selectedFilters, child) {
                      final _filterCount = selectedFilters.entries.where((e) => e.value != null).length;
                      return Badge.count(
                        count: _filterCount,
                        isLabelVisible: _filterCount > 0,
                        child: child,
                      );
                    },
                    child: const Icon(IconlyLight.filter),
                  ),
                ),
              ),
              onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                pagingController.refresh,
              ),
            ).fMarginLTRB(16, 8, 16, 0),

            // List
            Expanded(
              child: PagedListView(
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<model.KOTOrder>(
                  itemBuilder: (_, item, index) {
                    return InkWell(
                      onTap: () => showDetailsDialog(context, item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: Divider.createBorderSide(context)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KOT & Order Invoice Number
                            Row(
                              children: [
                                // KOT Invoice
                                Expanded(
                                  child: Text(
                                    '${context.t.common.kot}: ${item.kotInvoiceNumber ?? "N/A"}',
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: '${context.t.common.order}: ',
                                      children: [
                                        TextSpan(
                                          text: item.invoiceNumber ?? "N/A",
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      color: _theme.paragraphColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            DefaultTextStyle.merge(
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                color: _theme.paragraphColor,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item Count & Table Number
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${context.t.common.items}: ${item.itemCount.commaSeparated()}',
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${context.t.common.table}: ${item.kotTable?.name ?? "N/A"}',
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Date Time & Customer Name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.saleDate?.getFormatedString(pattern: 'dd/MM/yyyy hh:mm a') ?? "N/A",
                                        ),
                                      ),

                                      Expanded(
                                        child: Text(
                                          item.party?.name ?? "Guest",
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> showFilterBottomModal(BuildContext context) {
    return showFilterModalSheet<String, dynamic>(
      context: context,
      selectedFilters: selectedFiltersNotifier.value,
      onSave: selectedFiltersNotifier.set,
      filters: [
        FilterModalData.dropdown(
          key: 'food_item_type',
          labelText: context.t.common.itemFoodType,
          hintText: context.t.common.selectItemFoodType,
          items: [
            CustomDropdownMenuItem(
              value: null,
              label: TextSpan(text: 'All Type'),
            ),
            CustomDropdownMenuItem(
              value: ItemFoodTypeEnum.veg,
              label: TextSpan(text: ItemFoodTypeEnum.veg.label(context)),
            ),
            CustomDropdownMenuItem(
              value: ItemFoodTypeEnum.nonVeg,
              label: TextSpan(text: ItemFoodTypeEnum.nonVeg.label(context)),
            ),
          ],
        ),

        FilterModalData.dropdown(
          key: 'order_status',
          labelText: context.t.common.orderStatus,
          hintText: context.t.common.selectOrderStatus,
          items: [
            ...KotOrderStatus.orderListTabs.map((status) {
              return CustomDropdownMenuItem(
                value: status,
                label: TextSpan(text: status.label(context)),
              );
            }),
          ],
        ),
      ],
    );
  }

  Future<void> showDetailsDialog(BuildContext context, model.KOTOrder data) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (modalContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: context.t.common.itemDetails),
          action: [
            Text(
              data.orderStatus.label(context),
              style: Theme.of(modalContext).textTheme.bodyLarge?.copyWith(
                color: data.orderStatus.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          child: KotTicketCard.indexed(
            index: 0,
            data: data,
            showActions: false,
          ),
        );
      },
    );
  }

  @override
  Future<model.KOTOrderList> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(repo.saleRepoProvider)
          .getKOTOrderReportList(
            page: page,
            search: searchController.text,
            status: selectedFiltersNotifier.value['order_status']?.stringValue,
            fromDate: _dateFilter.value.fromDate.dbFormat,
            toDate: _dateFilter.value.toDate.dbFormat,
            foodItemType: selectedFiltersNotifier.value['food_item_type']?.stringValue,
          ),
    );
  }

  EventSub<repo.KOTOrderAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _dateFilter.addListener(pagingController.refresh);
    selectedFiltersNotifier.addListener(pagingController.refresh);
    _apiEventSub = GlobalEventManager.I.on<repo.KOTOrderAE>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
