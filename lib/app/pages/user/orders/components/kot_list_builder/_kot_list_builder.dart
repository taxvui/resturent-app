import 'package:expansion_widget/expansion_widget.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/model/model.dart' as model;
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../common/widgets/widgets.dart';

part '_cancel_bottom_modal.dart';
part '_kot_item_card.dart';

class KotListBuilder extends ConsumerStatefulWidget {
  const KotListBuilder({
    super.key,
    this.filterNotifier,
  });
  final ValueNotifier<Map<String, dynamic>>? filterNotifier;

  @override
  ConsumerState<KotListBuilder> createState() => KotListBuilderState();
}

class KotListBuilderState extends ConsumerState<KotListBuilder> with PaginatedControllerMixin<model.KOTOrder> {
  //------------------------State Vars------------------------//
  final orderStatusFilterNotifier = ValueNotifier<KotOrderStatus>(KotOrderStatus.pending);
  final statusCountsNotifier = ValueNotifier<model.KotOrderStatusData>((
    pendingCount: 0,
    preparingCount: 0,
    readyCount: 0,
    cancelledCount: 0,
  ));
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
    return DefaultTabController(
      length: 4,
      child: RefreshIndicator(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Filter
            SizedBox.fromSize(
              size: const Size.fromHeight(kToolbarHeight),
              child: ValueListenableBuilder(
                valueListenable: statusCountsNotifier,
                builder: (_, statusCounts, _) {
                  final _countsList = [
                    statusCounts.pendingCount,
                    statusCounts.preparingCount,
                    statusCounts.readyCount,
                    statusCounts.cancelledCount,
                  ];

                  return ValueListenableBuilder(
                    valueListenable: orderStatusFilterNotifier,
                    builder: (_, selected, _) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: KotOrderStatus.orderListTabs.length,
                        itemBuilder: (_, index) {
                          final _orderStatus = KotOrderStatus.orderListTabs[index];
                          return SelectedButton.outlined(
                            isSelected: _orderStatus == selected,
                            onPressed: () => orderStatusFilterNotifier.set(_orderStatus),
                            child: Text("${_orderStatus.label(context)} (${_countsList[index]})"),
                          );
                        },
                        separatorBuilder: (_, _) {
                          return const SizedBox.square(dimension: 8);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Items
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingController,
                padding: const EdgeInsets.all(16).copyWith(top: 8),
                builderDelegate: PagedChildBuilderDelegate<model.KOTOrder>(
                  itemBuilder: (_, item, index) {
                    return KotTicketCard.indexed(
                      index: index,
                      data: item,
                      onItemStatusChanged: ref.canT(
                        PMKeys.kot,
                        action: PermissionAction.update,
                        input: (value) => handleChangeItemStatus(context, value),
                      ),
                      onOrderStatusChanged: ref.canT(
                        PMKeys.kot,
                        action: PermissionAction.update,
                        input: (value) => handleChangeOrderStatus(context, value),
                      ),
                      onPrint: () => ref.read(kotThermalInvoiceProvider(item)),
                      onCancelled: ref.canT(
                        PMKeys.kot,
                        action: PermissionAction.update,
                        input: () => handleCancelOrder(context, item),
                      ),
                    );
                  },
                ),
                separatorBuilder: (_, _) {
                  return const SizedBox.square(dimension: 12);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleCancelOrder(BuildContext context, model.KOTOrder data) async {
    try {
      return await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        builder: (modalContext) => KOTOrderCancelModalSheet(orderID: data.id!),
      );
    } catch (_) {}
  }

  Future<void> handleChangeItemStatus(BuildContext context, ({int id, KotItemStatus status}) data) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(saleRepoProvider).manageKOTItemStatus(data.id, data.status.stringValue),
        ),
      );

      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(_result),
        );
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
  }

  Future<void> handleChangeOrderStatus(BuildContext context, ({int id, KotOrderStatus status}) data) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(saleRepoProvider).manageKOTOrderStatus(data.id, data.status.stringValue),
        ),
      );

      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(_result),
        );
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
  }

  @override
  Future<model.KOTOrderList> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(saleRepoProvider)
          .getKOTOrderList(
            page: page,
            search: widget.filterNotifier?.value['search'],
            kitchenId: widget.filterNotifier?.value['kitchen_id'],
            status: orderStatusFilterNotifier.value.stringValue,
            fromDate: (widget.filterNotifier?.value["date_filter"] as DateFilterDropdownItem?)?.fromDate.dbFormat,
            toDate: (widget.filterNotifier?.value["date_filter"] as DateFilterDropdownItem?)?.toDate.dbFormat,
          ),
    );
  }

  @override
  void getRawData(model.PaginatedListModel<model.KOTOrder> data) {
    statusCountsNotifier.set((data as model.KOTOrderList).statusCount);
    super.getRawData(data);
  }

  EventSub<KOTOrderAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    orderStatusFilterNotifier.addListener(pagingController.refresh);
    widget.filterNotifier?.addListener(pagingController.refresh);
    _apiEventSub = GlobalEventManager.I.on<KOTOrderAE>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
