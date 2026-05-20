import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:persistent_header_adaptive/persistent_header_adaptive.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../components/components.dart';
import '../manage_order_notifier_base.dart';
import '../../../../../data/repository/repository.dart';

part '_bottom_nav_action.dart';
part '_quick_order_view_provider.dart';

@RoutePage()
class QuickOrderView extends ConsumerStatefulWidget {
  const QuickOrderView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuickOrderViewState();
}

class _QuickOrderViewState extends ConsumerState<QuickOrderView> {
  late final selectedOrderTypeNotifier = ValueNotifier<OrderTypeEnum>(
    OrderTypeEnum.dineIn,
  );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userRepositoryProvider);
    final quickOrderController = ref.watch(quickOrderViewProvider);
    final orderCartProvider = ref.watch(quickOrderCartProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            scaffoldKey: widget.scaffoldKey,
            title: Skeletonizer(
              enabled: user.isLoading,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(user.value?.business?.companyName ?? "N/A"),
                titleTextStyle: _theme.textTheme.titleMedium?.copyWith(
                  color: _theme.colorScheme.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: user.value?.isShopOwner == true
                    ? Text(user.value?.business?.enrolledPlan?.plan?.subscriptionName ?? "N/A")
                    : null,
                subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
                  color: _theme.colorScheme.onPrimary,
                ),
              ),
            ),
            actions: [
              const NotificationButton(),
              const SizedBox.square(dimension: 8),
            ],
          ),
          body: PermissionGate(
            moduleKey: PMKeys.sales,
            action: PermissionAction.create,
            fallback: PermissionGate.imageFallback(),
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(
                orderCartProvider.pagingController.refresh,
              ),
              child: CustomScrollView(
                slivers: [
                  // Quick Order Type Selector
                  AdaptiveHeightSliverPersistentHeader(
                    floating: true,
                    needRepaint: true,
                    child: ColoredBox(
                      color: _theme.colorScheme.primaryContainer,
                      child: ValueListenableBuilder(
                        valueListenable: selectedOrderTypeNotifier,
                        builder: (_, selected, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Quick Order Type Selector
                              SizedBox.fromSize(
                                size: const Size.fromHeight(kToolbarHeight),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: OrderTypeEnum.values.length,
                                  itemBuilder: (context, index) {
                                    final _orderType = OrderTypeEnum.values[index];
                                    return SelectedButton.outlined(
                                      isSelected: _orderType == selected,
                                      onPressed: () {
                                        return selectedOrderTypeNotifier.set(
                                          _orderType,
                                        );
                                      },
                                      child: Text(_orderType.label(context)),
                                    );
                                  },
                                  separatorBuilder: (_, _) {
                                    return const SizedBox.square(dimension: 8);
                                  },
                                ),
                              ),

                              // Quick Order Action
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: selected.childBuilder(
                                  quickOrderViewProvider,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Search Field
                  AdaptiveHeightSliverPersistentHeader(
                    pinned: true,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: _theme.colorScheme.primaryContainer,
                      child: Consumer(
                        builder: (context, newRef, _) {
                          final _filterCount = newRef.watch(quickOrderCartProvider).filterCount;
                          return CustomSearchField(
                            controller: orderCartProvider.searchController,
                            appliedFilterCount: _filterCount,
                            onTapFilter: () async {
                              final _result = await showItemFilterBottomModalSheet(
                                context: context,
                                selectedFilters: {...orderCartProvider.filters},
                              );
                              if (_result != null) {
                                return orderCartProvider.handleFilter(_result);
                              }
                            },
                            decoration: CustomSearchFieldDecoration(
                              hintText: context.t.common.searchItemsName,
                            ),
                            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                              orderCartProvider.pagingController.refresh,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Item Cart
                  ItemCartWidget.sliverWidget(
                    controller: orderCartProvider,
                    padding: const EdgeInsets.all(16).copyWith(top: 8),
                  ),
                ],
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: PermissionGate(
            moduleKey: PMKeys.sales,
            action: PermissionAction.create,
            child: IntrinsicHeight(
              child: ValueListenableBuilder(
                valueListenable: selectedOrderTypeNotifier,
                builder: (_, selectedOrderType, _) {
                  return BottomActionBuilder(
                    onDetails: switch (selectedOrderType) {
                      OrderTypeEnum.orderQuotation => null,
                      _ => ref.canT(
                        PMKeys.kot,
                        input: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                          ),
                          builder: (modalContext) => BottomModalSheetWrapper(
                            title: TextSpan(text: modalContext.t.common.kitchenOrders),
                            child: Scaffold(body: KotListBuilder()),
                          ),
                        ),
                      ),
                    },
                    onKOT: switch (selectedOrderType) {
                      OrderTypeEnum.orderQuotation => null,
                      _ => ref.canT(
                        PMKeys.sales,
                        action: PermissionAction.create,
                        input: () async {
                          if (!ItemCartWidget.hasItems(context, orderCartProvider)) {
                            return;
                          }
                          if (selectedOrderTypeNotifier.value == OrderTypeEnum.dineIn &&
                              quickOrderController.dropdownValues['table_id'] == null) {
                            showCustomSnackBar(
                              context,
                              content: Text(context.t.exceptions.pleaseSelectATableToCreateAKot),
                              customSnackBarType: CustomOverlayType.info,
                            );
                            return;
                          }
                          return _handleKOTSubmit(context);
                        },
                      ),
                    },
                    onPayment: ref.canT(
                      PMKeys.sales,
                      action: PermissionAction.create,
                      input: () async {
                        if (ItemCartWidget.hasItems(context, orderCartProvider)) {
                          final _salesType = selectedOrderTypeNotifier.value.stringValue;

                          final _saleData = quickOrderController.prepSaleData().copyWith(salesType: _salesType);

                          final _result = await context.router.push(
                            OrderPaymentRoute(saleData: _saleData),
                          );

                          if (_result != null) return _resetState();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleKOTSubmit(BuildContext context) async {
    final controller = ref.read(quickOrderViewProvider);

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => controller.handleManageSale(
        Sale(
          isKOT: true,
          salesType: selectedOrderTypeNotifier.value.stringValue,
        ),
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

      if (ref.read(printerSettingsProvider).autoPrint) {
        ref.read(kotThermalInvoiceProvider(_result.right!.data!));
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            persist: false,
            backgroundColor: CustomOverlayType.success.backgroundColor,
            content: Text(context.t.prompt.extMsg.kotSavedSuccessfully),
            action: SnackBarAction(
              label: context.t.common.view,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              onPressed: () async {
                return context.router.push<void>(
                  InvoicePreviewRoute(
                    previewType: ThermalPreview(
                      SalePurchaseThermalInvoiceData.fromSale(_result.right!.data!),
                      isSale: true,
                    ),
                  ),
                );
              },
            ),
          ),
        );

      return _resetState();
    }
  }

  void _resetState() {
    GlobalEventManager.I.fire<ItemCartEvent>(QuickOrderCartEvent.clearCart);
    ref.invalidate(quickOrderViewProvider);
  }
}
