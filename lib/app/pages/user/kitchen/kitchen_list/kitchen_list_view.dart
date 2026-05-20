import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../manage_kitchen/manage_kitchen_view.dart';
import '../manage_kitchen_items/manage_kitchen_items_view.dart';
import 'components/components.export.dart';

@RoutePage()
class KitchenListView extends ConsumerStatefulWidget {
  const KitchenListView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  ConsumerState<KitchenListView> createState() => _KitchenListViewState();
}

class _KitchenListViewState extends ConsumerState<KitchenListView> with PaginatedControllerMixin<KitchenModel> {
  //------------------------State Vars------------------------//
  final searchController = TextEditingController();
  final selectedKitchenNotifier = ValueNotifier<int?>(null);
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
    final kitchenListAsync = ref.watch(kitchenDropdownProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: Text(context.t.common.kitchen(n: 2)),
        actions: [
          if (widget.scaffoldKey != null) ...[
            const NotificationButton(),
          ],
          const SizedBox.square(dimension: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    flex: 6,
                    child: CustomSearchField(
                      controller: searchController,
                      decoration: CustomSearchFieldDecoration(
                        hintText: context.t.common.search,
                      ),
                      onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                        pagingController.refresh,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),

                  // Kitchen Filter
                  Expanded(
                    flex: 4,
                    child: SizedBox.fromSize(
                      size: Size.fromHeight(44),
                      child: ValueListenableBuilder(
                        valueListenable: selectedKitchenNotifier,
                        builder: (_, value, _) {
                          return AsyncCustomDropdown<int, KitchenListModel>(
                            asyncData: kitchenListAsync,
                            value: value,
                            items: kitchenListAsync.when(
                              data: (data) {
                                return [
                                  CustomDropdownMenuItem(
                                    value: null,
                                    label: TextSpan(text: 'All Kitchen'),
                                  ),
                                  ...?data.data?.data?.map((kitchen) {
                                    return CustomDropdownMenuItem(
                                      value: kitchen.id,
                                      label: TextSpan(text: kitchen.name ?? "N/A"),
                                    );
                                  }),
                                ];
                              },
                              error: (_, _) => [],
                              loading: () => [],
                            ),
                            onChanged: selectedKitchenNotifier.set,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kitchen List
            Expanded(
              child: PagedListView.separated(
                padding: const EdgeInsets.all(16).copyWith(bottom: 72),
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<KitchenModel>(
                  itemBuilder: (_, item, index) {
                    return KitchenCard(
                      data: item,
                      onStatusChanged: (value) => handleChangeStatus(
                        context,
                        item.copyWith(status: value),
                      ),
                      onManageItem: () => handleManageKitchenItems(context, kitchen: item),
                      onDeleteItem: (value) => handleDeleteKitchenItem(context, value),
                      onDelete: () => handleDeleteKitchen(context, item.id!),
                      onEdit: () => handleManageKitchen(context, editModel: item),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.pages.kitchen.list.noKitchensFound,
                          onRetry: pagingController.refresh,
                        );
                      },
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
      floatingActionButton: SizedBox(
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: () => handleManageKitchen(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.pages.kitchen.manage.addKitchen),
          icon: const Icon(Icons.add, size: 18),
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> handleManageKitchen(BuildContext context, {KitchenModel? editModel}) async {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(modalContext).bottom),
          child: ManageKitchenView(editModel: editModel),
        );
      },
    );
  }

  Future<void> handleManageKitchenItems(BuildContext context, {required KitchenModel kitchen}) async {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(modalContext).bottom),
          child: ManageKitchenItemsView(kitchen: kitchen),
        );
      },
    );
  }

  Future<void> handleChangeStatus(BuildContext context, KitchenModel data) async {
    try {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(kitchenRepoProvider).manageKitchenStatus(id: data.id!, status: data.status ? 1 : 0),
        ),
      );

      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(_result),
        );
        return;
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }
    }
  }

  Future<void> handleDeleteKitchenItem(BuildContext context, ({int itemId, int kitchenId}) data) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.pages.kitchen.card.deleteItemConfirm,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(kitchenRepoProvider).deleteKitchenItem(data.kitchenId, data.itemId),
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
  }

  Future<void> handleDeleteKitchen(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.pages.kitchen.card.deleteKitchenConfirm,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(kitchenRepoProvider).deleteKitchen(id),
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
  }

  @override
  Future<KitchenListModel> fetchData(int page) {
    return ref
        .read(kitchenRepoProvider)
        .getKitchenList(
          page: page,
          kitchenId: selectedKitchenNotifier.value,
          search: searchController.text,
        );
  }

  EventSub<KitchenModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<KitchenModel>().listen((_) {
      pagingController.refresh();
    });
    selectedKitchenNotifier.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}
