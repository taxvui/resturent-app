import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../../../core/core.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../components/components.dart';

@RoutePage()
class OrderListView extends ConsumerStatefulWidget {
  const OrderListView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  ConsumerState<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends ConsumerState<OrderListView> with PaginatedControllerMixin<Sale> {
  final _filters = ValueNotifier<Map<String, dynamic>>({
    'date_filter': DropdownDateFilter.daily,
    'order_type': null,
    'payment_status': null,
  });
  late final searchController = TextEditingController();

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: Text(context.t.pages.orderList.title),
        /*
        actions: [
          if (ref.can(PMKeys.sales)) ...[
            // PDF Export Button
            SizedBox.square(
              dimension: 32,
              child: CustomSearchFieldActionButton.pdf(
                onPressed: () {},
                iconColor: _theme.colorScheme.onPrimary,
                style: CustomSearchFieldActionButton.defaultStyle(context).copyWith(
                  side: WidgetStateProperty.all<BorderSide>(
                    BorderSide(color: _theme.colorScheme.onPrimary),
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(7)),
                ),
              ),
            ),
            const SizedBox.square(dimension: 10),

            // Print Button
            SizedBox.square(
              dimension: 32,
              child: CustomSearchFieldActionButton.print(
                onPressed: () {},
                iconColor: _theme.colorScheme.onPrimary,
                style: CustomSearchFieldActionButton.defaultStyle(context).copyWith(
                  side: WidgetStateProperty.all<BorderSide>(
                    BorderSide(color: _theme.colorScheme.onPrimary),
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(7)),
                ),
              ),
            ),
            const SizedBox.square(dimension: 8),
          ],
        ],
        */
      ),
      body: PermissionGate(
        moduleKey: PMKeys.sales,
        fallback: PermissionGate.imageFallback(),
        child: RefreshIndicator.adaptive(
          onRefresh: () => Future.sync(pagingController.refresh),
          child: Column(
            children: [
              // Search Field
              ValueListenableBuilder(
                valueListenable: _filters,
                builder: (_, selectedFilters, _) {
                  return CustomSearchField(
                    controller: searchController,
                    decoration: CustomSearchFieldDecoration(
                      hintText: context.t.common.searchInvoiceNumber,
                    ),
                    appliedFilterCount: selectedFilters.entries.where((e) => e.value != null).length,
                    onTapFilter: () async {
                      return await showFilterModalSheet<String, dynamic>(
                        context: context,
                        selectedFilters: {...selectedFilters},
                        filters: [
                          FilterModalData.dateFilterDropdown(
                            key: 'date_filter',
                            labelText: context.t.common.date,
                          ),
                          FilterModalData.dropdown(
                            key: 'order_type',
                            labelText: context.t.pages.orderList.filters.orderType.label,
                            hintText: context.t.pages.orderList.filters.orderType.hint,
                            items: [
                              ...[
                                (label: context.t.common.all, value: null),
                                (label: context.t.enums.orderTypes.dineIn, value: 'dine_in'),
                                (label: context.t.enums.orderTypes.pickUp, value: 'pickup'),
                                (label: context.t.enums.orderTypes.delivery, value: 'delivery'),
                                (label: context.t.enums.orderTypes.reservation, value: 'reservation'),
                                (label: context.t.enums.orderTypes.quotation, value: 'quotation'),
                              ].map((entry) {
                                return CustomDropdownMenuItem<String?>(
                                  value: entry.value,
                                  label: TextSpan(text: entry.label),
                                );
                              }),
                            ],
                            gridFlex: 6,
                          ),
                          FilterModalData.dropdown(
                            key: 'payment_status',
                            gridFlex: 6,
                            labelText: context.t.pages.orderList.filters.paymentStatus.label,
                            hintText: context.t.pages.orderList.filters.paymentStatus.hint,
                            items: [
                              ...[
                                (label: context.t.common.all, value: null),
                                (label: context.t.enums.paymentStatus.paid, value: 'paid'),
                                (label: context.t.enums.paymentStatus.unpaid, value: 'unpaid'),
                              ].map((entry) {
                                return CustomDropdownMenuItem<String?>(
                                  value: entry.value,
                                  label: TextSpan(text: entry.label),
                                );
                              }),
                            ],
                          ),
                        ],
                        onSave: _filters.set,
                      );
                    },
                    onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                      pagingController.refresh,
                    ),
                  );
                },
              ).fMarginLTRB(16, 16, 16, 0),

              Expanded(
                child: PagedListView<int, Sale>(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Sale>(
                    itemBuilder: (c, sale, i) {
                      final _cardData = OrderTransactionCardData(
                        cardType: OrderCardType.orderList(
                          status: sale.isPaymentPending
                              ? OrderCardTransactionStatus.pending
                              : OrderCardTransactionStatus.completed,
                          hasDue: sale.dueAmount != 0,
                        ),
                        invoiceNumber: sale.invoiceNumber ?? "N/A",
                        tableName: sale.kotTable?.name,
                        transactionDate: sale.saleDate,
                        primaryValue: sale.totalAmount ?? 0,
                        secondaryValue: sale.isPaymentPending
                            ? (sale.dueAmount ?? 0)
                            : sale.dueAmount == 0
                            ? (sale.totalAmount ?? 0) - (sale.dueAmount ?? 0)
                            : (sale.dueAmount ?? 0),
                      );
                      return OrderCard(
                        cardData: _cardData,
                        action: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (ref.can(PMKeys.sales, action: PermissionAction.update)) ...[
                              if (_cardData.cardType.status == OrderCardTransactionStatus.pending) ...[
                                SizedBox.square(
                                  dimension: 24,
                                  child: IconButton(
                                    onPressed: () async {
                                      return _handleOrderPayment(
                                        context,
                                        sale.id!,
                                      );
                                    },
                                    style: IconButton.styleFrom(
                                      visualDensity: const VisualDensity(
                                        horizontal: VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    icon: UniversalImage(
                                      DAppDrawerIcons.expense.svgPath,
                                      colorFilter: ColorFilter.mode(
                                        DAppColors.kSuccess,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox.square(dimension: 4),
                              ],
                            ],
                            PopupMenuButton<String>(
                              itemBuilder: (_) {
                                return [
                                  ('view', context.t.common.view),
                                  if (ref.can(PMKeys.sales, action: PermissionAction.update)) ...[
                                    ('edit', context.t.common.edit),
                                  ],
                                  if (ref.can(PMKeys.sales, action: PermissionAction.delete)) ...[
                                    ('delete', context.t.common.delete),
                                  ],
                                ].map((menu) {
                                  return PopupMenuItem<String>(
                                    value: menu.$1,
                                    child: Text(menu.$2),
                                  );
                                }).toList();
                              },
                              onSelected: (v) async {
                                return await switch (v) {
                                  'view' => _handleViewDetails(context, sale.id!),
                                  'edit' => _handleEdit(context, sale.id!),
                                  'delete' => _handleDelete(context, sale.id!),
                                  _ => null,
                                };
                              },
                              child: Icon(
                                Icons.more_vert,
                                color: _theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    noItemsFoundIndicatorBuilder: (context) {
                      return EmptyWidget(
                        replaceDefault: false,
                        emptyBuilder: (context) {
                          return RetryButtons.scrollView(
                            context.t.exceptions.noSaleFoundPleaseSAddProduct,
                            onRetry: pagingController.refresh,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    ).unfocusPrimary();
  }

  Future<void> _handleViewDetails(BuildContext context, int id) async {
    final _details = await _fetchSaleDetails(context, id);
    if (context.mounted && _details != null) {
      return context.router.push<void>(
        InvoicePreviewRoute(
          previewType: ThermalPreview(
            SalePurchaseThermalInvoiceData.fromSale(_details),
            isSale: true,
          ),
        ),
      );
    }
  }

  Future<void> _handleEdit(BuildContext context, int saleId) async {
    final _details = await _fetchSaleDetails(context, saleId);

    if (context.mounted && _details != null) {
      return await context.router.push<void>(
        EditOrderRoute(editModel: _details),
      );
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    int saleId,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: popContext.t.exceptions.doYouWantToDeleteThisSale,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(saleRepoProvider).deleteSale(saleId),
        ),
      );

      if (context.mounted) {
        if (_result.isFailure) {
          showCustomSnackBar(
            context,
            content: Text(_result.left!),
            customSnackBarType: CustomOverlayType.error,
          );
          return;
        }
      }
    }
  }

  Future<void> _handleOrderPayment(BuildContext context, saleId) async {
    final _details = await _fetchSaleDetails(context, saleId);

    if (context.mounted && _details != null) {
      return context.router.push<void>(
        OrderPaymentRoute(
          saleData: _details.copyWith(isKOT: true),
        ),
      );
    }
  }

  Future<Sale?> _fetchSaleDetails(BuildContext context, int saleId) async {
    try {
      final _details = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(saleRepoProvider).getSaleDetails(saleId),
        ),
      );

      if (context.mounted && _details.data != null) {
        return _details.data;
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
    return null;
  }

  @override
  Future<PaginatedListModel<Sale>> fetchData(int page) {
    final _dateFilter = _filters.value['date_filter'] as DateFilterDropdownItem?;

    return ref
        .read(saleRepoProvider)
        .getSaleList(
          page: page,
          search: searchController.text,
          fromDate: _dateFilter?.fromDate.dbFormat,
          toDate: _dateFilter?.toDate.dbFormat,
          paymentStatus: _filters.value['payment_status'],
          salesType: _filters.value['order_type'],
        );
  }

  EventSub<SaleAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _filters.addListener(pagingController.refresh);

    _apiEventSub = GlobalEventManager.I.on<SaleAE>().listen((event) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
