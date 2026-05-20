import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../common/widgets/widgets.dart';
import '../../components/components.dart';
import '../manage_order_notifier_base.dart';
import '../../../../../widgets/widgets.dart';

part '_edit_order_provider.dart';

@RoutePage()
class EditOrderView extends ConsumerStatefulWidget {
  const EditOrderView({super.key, required this.editModel});
  final Sale editModel;

  @override
  ConsumerState<EditOrderView> createState() => _EditOrderViewState();
}

class _EditOrderViewState extends ConsumerState<EditOrderView> {
  @override
  void initState() {
    ref.read(editOrderViewProvider).initEdit(widget.editModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(editOrderViewProvider);
    final cartController = ref.watch(editOrderCartProvider);

    ref.listen(editOrderCartProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(controller.selectedPaymentOption.provider)
            .initEdit(
              controller.prepSaleData(widget.editModel),
              resetState: true,
            );
      });
    });

    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return FormWrapper(
      useDefaultInvoker: true,
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              // widget.editModel.isPaymentPending ? 'Kot Edit' : 'Edit Order',
              widget.editModel.isPaymentPending
                  ? context.t.pages.orders.manageOrders.title.editKOT
                  : context.t.pages.orders.manageOrders.title.editOrder,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Type
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: controller.selectedOrderType.childBuilder(editOrderViewProvider),
                ),

                Padding(
                  padding: const EdgeInsets.all(16).copyWith(top: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bill Items
                      Text(
                        // 'Bill Items',
                        context.t.common.billItems,
                        style: _sectionHeaderStyle,
                      ),
                      const SizedBox.square(dimension: 8),

                      // Add More Items
                      SizedBox.fromSize(
                        size: const Size.fromHeight(40),
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const _EditSaleItemCart(),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            foregroundColor: _theme.colorScheme.primary,
                            backgroundColor: _theme.colorScheme.primary.withValues(
                              alpha: 0.10,
                            ),
                          ),
                          // child: const Text('+ Add Items'),
                          child: Text('+ ${context.t.common.addItems}'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items
                ...List.generate(cartController.cartItems.length, (index) {
                  final cartItem = cartController.cartItems[index];
                  return HorizontalItemCard.cartList(
                    key: ValueKey(cartItem.item.id),
                    data: ItemCardData(
                      itemName: cartItem.item.productName ?? "N/A",
                      imageUrl: cartItem.item.images?.firstOrNull?.remote,
                      salesPrice: cartItem.totalPrice,
                    ),
                    cartQuantity: cartItem.cartQuantity,
                    onTap: () async {
                      final _result = await showItemDetailsModal(
                        context,
                        cartItem.item,
                        cartItem: cartItem,
                      );
                      if (_result != null) {
                        return cartController.handleCartItem(_result);
                      }
                    },
                    onChangeQuantity: (nQ) {
                      return cartController.handleCartItem(
                        cartItem.copyWith(cartQuantity: nQ),
                      );
                    },
                    onRemoveItem: () {
                      return cartController.handleCartItem(
                        cartItem.copyWith(cartQuantity: 0),
                      );
                    },
                  );
                }),
                const SizedBox.square(dimension: 12),

                // Payment
                if (widget.editModel.meta?.paymentType != null) ...[
                  Text(
                    // 'Payment',
                    context.t.common.payment,
                    style: _sectionHeaderStyle,
                  ).fMarginSymmetric(horizontal: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: PaymentOptionEnum.values.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemBuilder: (_, index) {
                            final _paymentOption = PaymentOptionEnum.values[index];
                            final _isSeleceted = controller.selectedPaymentOption == _paymentOption;

                            return SelectedButton(
                              onPressed: () {
                                controller.handleSelectPaymentOption(_paymentOption);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ref
                                      .read(_paymentOption.provider)
                                      .initEdit(
                                        widget.editModel.copyWith(
                                          details: controller.prepSaleData(widget.editModel).details,
                                        ),
                                        resetState: true,
                                      );
                                });
                              },
                              isSelected: _isSeleceted,
                              child: Text(_paymentOption.label(context)),
                            );
                          },
                          separatorBuilder: (_, _) {
                            return const SizedBox.square(dimension: 10);
                          },
                        ),
                      ),

                      // Payment Options
                      controller.selectedPaymentOption.childBuilder(),
                    ],
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (FormWrapper.validate(formContext)) {
                return _handleFormSubmit(
                  context,
                  isKot: widget.editModel.isPaymentPending,
                );
              }
            },
            // child: const Text('Update'),
            child: Text(context.t.action.update),
          ).fMarginSymmetric(horizontal: 16, vertical: 12),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context, {bool isKot = false}) async {
    final _controller = ref.watch(editOrderViewProvider);

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => _controller.handleManageSale(
        widget.editModel.copyWith(isKOT: isKot),
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
      context.router.pop();
      context.router.push(
        InvoicePreviewRoute(
          previewType: ThermalPreview(
            SalePurchaseThermalInvoiceData.fromSale(_result.right!.data!),
            isSale: true,
          ),
        ),
      );
    }
  }
}

class _EditSaleItemCart extends ConsumerWidget {
  // ignore: unused_element_parameter
  const _EditSaleItemCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartController = ref.watch(editOrderCartProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Add Items'),
        actions: [
          IconButton(
            onPressed: () async {
              return await context.router.push<void>(ManageItemRoute());
            },
            icon: const Icon(HugeIconsStroke.packageAdd),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: cartController.searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: 'Search items name',
              actions: [
                const SizedBox.square(dimension: 8),
                CustomSearchFieldActionButton.barcodeScan(
                  onPressed: () async {
                    final _result = await SharedWidgets.scanBarcode(
                      context,
                    );
                    if (_result != null) {
                      cartController.searchController.text = _result;
                      cartController.pagingController.refresh();
                    }
                  },
                ),
              ],
            ),
            onTapFilter: () async {
              final _result = await showItemFilterBottomModalSheet(
                context: context,
                selectedFilters: {...cartController.filters},
              );
              if (_result == null) {
                return;
              }

              return cartController.handleFilter(_result);
            },
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              cartController.pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Items
          Expanded(
            child: ItemCartWidget.boxWidget(
              controller: cartController,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavWrapper(
        padding: const EdgeInsets.all(16),
        child: ItemCartWidget.totalButton(
          totalAmount: cartController.cartAmountOverview.totalAmount,
          totalQuantity: cartController.cartAmountOverview.totalQuantity,
          onPressed: Navigator.of(context).pop,
        ),
      ),
    );
  }
}
