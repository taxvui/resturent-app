import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../common/widgets/widgets.dart';
import '../../components/components.dart';
import '../../manage_order/manage_order_notifier_base.dart';

part '_manage_quotation_view_provider.dart';

@RoutePage()
class ManageQuotationView extends ConsumerStatefulWidget {
  const ManageQuotationView({
    super.key,
    this.isConverting = false,
    this.editModel,
  });
  final bool isConverting;
  final Quotation? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageQuotationViewState();
}

class _ManageQuotationViewState extends ConsumerState<ManageQuotationView> {
  late final selectedOrderTypeNotifier = ValueNotifier<OrderTypeEnum>(
    OrderTypeEnum.dineIn,
  );

  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageQuotationViewProvider).initEdit(widget.editModel!);
    } else {
      initPaymentData();
    }
    ref.read(manageQuotationViewProvider).deliveryChargeController.addListener(initPaymentData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageQuotationViewProvider);
    final cartController = ref.watch(quotationCartProvider);
    final _customerListAsync = ref.watch(customerDropdownProvider);

    ref.listen(quotationCartProvider, (_, _) => initPaymentData());

    final _theme = Theme.of(context);

    final _sectionHeaderStyle = _theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isConverting
                  // ? 'Convert to Sale'
                  ? context.t.pages.quotation.manageQuotation.title.convert
                  : widget.isEditMode
                  ? 'Edit Quotation'
                  : 'Add New Quotation',
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isConverting) ...[
                  ValueListenableBuilder(
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
                              itemCount: OrderTypeEnum.values.take(3).length,
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
                              manageQuotationViewProvider,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],

                Padding(
                  padding: EdgeInsetsDirectional.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isConverting) ...[
                        // Customer Dropdown
                        SizedBox(
                          height: 45,
                          child: AsyncCustomDropdown<int, PartyList>(
                            asyncData: _customerListAsync,
                            decoration: InputDecoration(
                              // labelText: 'Customer',
                              labelText: context.t.form.sales.customer.label,
                              // hintText: 'Select customer',
                              hintText: context.t.form.sales.customer.hint,
                              suffixIcon: IconButton.filled(
                                onPressed: () async {
                                  return context.router.push<void>(ManagePartyRoute());
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xffF0F0F0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusDirectional.horizontal(
                                      end: const Radius.circular(3),
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                              ).fMarginSymmetric(horizontal: 0.425, vertical: 1),
                            ),
                            value: controller.dropdownValues['customer_id'],
                            items: _customerListAsync.when(
                              data: (data) => [
                                ...?data.data?.data?.map((customer) {
                                  return CustomDropdownMenuItem<int>(
                                    value: customer.id,
                                    label: TextSpan(text: customer.name ?? "N/A"),
                                  );
                                }),
                              ],
                              error: (e, s) => [],
                              loading: () => [],
                            ),
                            showClearButton: true,
                            onChanged: (value) {
                              return controller.handleDropdownChange(
                                MapEntry('customer_id', value),
                              );
                            },
                          ),
                        ),
                        const SizedBox.square(dimension: 16),
                      ],

                      // Bill Items
                      Text(
                        // 'Bill Items',
                        context.t.common.billItems,
                        style: _theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox.square(dimension: 12),

                      // Add More Items
                      SizedBox.fromSize(
                        size: const Size.fromHeight(40),
                        child: FilledButton(
                          onPressed: () async {
                            return context.router.push<void>(
                              QuotationItemListRoute(getBack: true),
                            );
                          },
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

                // Added Items
                if (cartController.cartItems.isNotEmpty)
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
                  })
                else
                  Center(
                    child: Text(
                      // 'No items added.\n Please try adding an item.',
                      context.t.exceptions.noItemAdded,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox.square(dimension: 12),

                // Payment
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
                              if (controller.selectedPaymentOption == _paymentOption) {
                                return;
                              }
                              controller.handleSelectPaymentOption(_paymentOption);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref
                                    .read(_paymentOption.provider)
                                    .initEdit(
                                      (widget.editModel ?? Quotation()).copyWith(
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
                const SizedBox.square(dimension: 12),
              ],
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 80,
            child: BottomNavWrapper(
              child: Builder(
                builder: (_) {
                  if (widget.isConverting) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox.expand(
                            child: OutlinedButton(
                              onPressed: () async {
                                if (!ItemCartWidget.hasItems(context, cartController)) {
                                  return;
                                }
                                if (selectedOrderTypeNotifier.value == OrderTypeEnum.dineIn &&
                                    controller.dropdownValues['table_id'] == null) {
                                  showCustomSnackBar(
                                    context,
                                    // content: Text('Please select a table to create a kot.'),
                                    content: Text(context.t.exceptions.pleaseSelectATableToCreateAKot),
                                    customSnackBarType: CustomOverlayType.info,
                                  );
                                  return;
                                }
                                if (FormWrapper.validate(formContext)) {
                                  return _handleConvertSale(context, isKOT: true);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              // child: const Text('KOT'),
                              child: Text(context.t.common.kot),
                            ),
                          ),
                        ),
                        const SizedBox.square(dimension: 10),
                        Expanded(
                          flex: 8,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (FormWrapper.validate(formContext) &&
                                  ItemCartWidget.hasItems(context, cartController)) {
                                return _handleConvertSale(context);
                              }
                            },
                            // child: const Text('Submit'),
                            child: Text(context.t.action.submit),
                          ),
                        ),
                      ],
                    );
                  }

                  return ElevatedButton(
                    onPressed: () async {
                      if (FormWrapper.validate(formContext) &&
                          ItemCartWidget.hasItems(context, cartController) &&
                          ref.read(controller.selectedPaymentOption.provider).validate(context)) {
                        return _handleQuotationSubmit(context);
                      }
                    },
                    // child: Text(widget.isEditMode ? 'Update' : 'Save'),
                    child: Text(widget.isEditMode ? context.t.action.update : context.t.action.save),
                  );
                },
              ),
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleConvertSale(
    BuildContext context, {
    bool isKOT = false,
  }) async {
    final _controller = ref.read(manageQuotationViewProvider);

    final _quotationData = _controller.prepQuotationData(widget.editModel);
    final _saleData = Sale.fromQuotation(_quotationData).copyWith(
      isKOT: isKOT,
      salesType: selectedOrderTypeNotifier.value.stringValue,
    );

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => _controller.handleManageSale(_saleData),
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
      if (isKOT) {
        if (ref.read(printerSettingsProvider).autoPrint) {
          ref.read(kotThermalInvoiceProvider(_result.right!.data!));
        }
      } else {
        return context.router.push<void>(
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

  Future<void> _handleQuotationSubmit(BuildContext context) async {
    final _controller = ref.read(manageQuotationViewProvider);
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () {
        return _controller.handleManageQuotation(
          (widget.editModel ?? Quotation()).copyWith(
            meta: (widget.editModel?.meta ?? SaleMeta()).copyWith(
              paymentType: selectedOrderTypeNotifier.value.stringValue,
            ),
          ),
        );
      },
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

  void initPaymentData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(manageQuotationViewProvider);
      ref
          .read(controller.selectedPaymentOption.provider)
          .initEdit(
            controller.prepQuotationData(widget.editModel),
            resetState: true,
          );
    });
  }
}
