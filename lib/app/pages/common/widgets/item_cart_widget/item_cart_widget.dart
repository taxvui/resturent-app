import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../widgets.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

export 'components/components.dart' show showItemDetailsModal;

part '_item_cart_provider.dart';
part '_item_cart_model.dart';

class ItemCartWidget extends ConsumerWidget {
  const ItemCartWidget.boxWidget({
    super.key,
    required this.controller,
    this.padding,
  }) : _renderSliver = false;

  const ItemCartWidget.sliverWidget({
    super.key,
    required this.controller,
    this.padding,
  }) : _renderSliver = true;

  final ItemCartNotifierBase controller;
  final EdgeInsetsGeometry? padding;

  final bool _renderSliver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      controller.initRefreshListener();
    }

    final _mqSize = MediaQuery.sizeOf(context);

    final _padding = padding ?? const EdgeInsets.all(16);
    final _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisExtent: _mqSize.isTn ? 150 : 165,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
    );

    final _builderDelegate = PagedChildBuilderDelegate<PItem>(
      itemBuilder: (_, xitem, i) {
        final _itemType = ItemTypeEnum.fromString(xitem.priceType);

        final _cartItem = controller.cartItems.firstWhereOrNull(
          (element) => element.itemId == xitem.id,
        );

        return VerticalItemCard(
          cartQuantity: _cartItem?.cartQuantity,
          onTap: () async {
            final _result = await showItemDetailsModal(
              context,
              xitem,
              cartItem: _cartItem,
            );
            if (_result != null) {
              return controller.handleCartItem(_result);
            }
          },
          onClearQuantity: () => controller.handleCartItem(
            ItemCartModel(cartQuantity: 0, item: xitem),
          ),
          onQuantityTap: () async {
            final _result = await _showQuantityModal(
              context,
              _cartItem?.cartQuantity ?? 0,
            );

            if (_result != null) {
              final _item = (_cartItem ?? ItemCartModel(item: xitem)).copyWith(
                cartQuantity: _result,
              );
              return controller.handleCartItem(_item);
            }
          },
          saleAsPrimaryPrice: true,
          data: ItemCardData(
            itemName: xitem.productName ?? "N/A",
            imageUrl: xitem.images?.firstOrNull?.remote,
            salesPrice: (_itemType.isVariation ? xitem.minVariationPrice : xitem.salesPrice) ?? 0,
          ),
        );
      },
      noItemsFoundIndicatorBuilder: (context) {
        return EmptyWidget(
          replaceDefault: false,
          emptyBuilder: (context) {
            return RetryButtons.scrollView(
              // 'No item found!\n Please try adding an item.',
              context.t.pages.items.itemList.extra.emptyItem,
              onRetry: controller.pagingController.refresh,
            );
          },
        );
      },
    );

    Widget gridViewWidget;

    if (_renderSliver) {
      gridViewWidget = SliverPadding(
        padding: _padding,
        sliver: PagedSliverGrid<int, PItem>(
          pagingController: controller.pagingController,
          builderDelegate: _builderDelegate,
          gridDelegate: _gridDelegate,
        ),
      );
    } else {
      gridViewWidget = PagedGridView(
        padding: _padding,
        pagingController: controller.pagingController,
        builderDelegate: _builderDelegate,
        gridDelegate: _gridDelegate,
      );
    }

    return gridViewWidget;
  }

  static Widget totalButton({
    required void Function()? onPressed,
    int totalQuantity = 0,
    num totalAmount = 0,
    bool showTrailing = true,
    bool outlined = false,
    String? buttonText,
    TextAlign textAlign = TextAlign.center,
  }) {
    const _buttonPadding = EdgeInsetsDirectional.only(start: 6, end: 12);

    return Builder(
      builder: (context) {
        final _theme = Theme.of(context);

        final _totalAmount = '${buttonText ?? context.t.common.total} ${totalAmount.quickCurrency()}';

        final buttonContent = Row(
          children: [
            // Quantity box
            SizedBox.square(
              dimension: 38,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      constraints: BoxConstraints.tight(
                        const Size.square(34),
                      ),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: totalQuantity.commaSeparated(decimalDigits: 0),
                    child: Container(
                      constraints: BoxConstraints.tight(
                        const Size.square(34),
                      ),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        totalQuantity.commaSeparated(decimalDigits: 0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Total amount
            Expanded(
              child: Text(
                _totalAmount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
              ),
            ),

            // Trailing
            if (showTrailing)
              SizedBox.square(
                dimension: 24,
                child: const Icon(Icons.arrow_forward),
              ),
          ],
        );

        final buttonStyle = outlined
            ? OutlinedButton.styleFrom(
                padding: _buttonPadding.copyWith(top: 6, bottom: 6),
                backgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                side: BorderSide(
                  color: _theme.colorScheme.primary,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              )
            : ElevatedButton.styleFrom(padding: _buttonPadding);

        return Tooltip(
          message: _totalAmount,
          child: outlined
              ? OutlinedButton(
                  onPressed: onPressed,
                  style: buttonStyle,
                  child: buttonContent,
                )
              : ElevatedButton(
                  onPressed: onPressed,
                  style: buttonStyle,
                  child: buttonContent,
                ),
        );
      },
    );
  }

  Future<int?> _showQuantityModal(
    BuildContext context,
    int cartQuantity,
  ) async {
    int _quantity = cartQuantity;
    final quantityController = TextEditingController(
      text: _quantity.toString(),
    );
    final _focusNode = FocusNode();
    bool _focusedOnce = false;

    void changeQuantity(int value, {bool fresh = false}) {
      _quantity = fresh ? value : _quantity + value;
      quantityController.text = _quantity.toString();
    }

    return await showModalBottomSheet<int>(
      context: context,
      builder: (modalContext) {
        if (!_focusedOnce) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              FocusScope.of(modalContext).requestFocus(_focusNode);
              _focusedOnce = true;
            },
          );
        }
        final _theme = Theme.of(context);
        return FormWrapper(
          builder: (formContext) {
            return BottomModalSheetWrapper(
              title: TextSpan(text: context.t.pages.orders.manageOrders.extra.manageQuantity),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Quantity
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton.outlined(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (_quantity > 0) {
                              changeQuantity(-1);
                            }
                          },
                          style:
                              CustomSearchFieldActionButton.defaultStyle(
                                context,
                              ).copyWith(
                                minimumSize: WidgetStateProperty.all(
                                  const Size.square(48),
                                ),
                              ),
                        ),
                        const SizedBox.square(dimension: 12),
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            focusNode: _focusNode,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: context.t.form.itemCart.hint,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(),
                            onChanged: (value) {
                              final _newQ = int.tryParse(value.trim()) ?? 0;
                              return changeQuantity(_newQ, fresh: true);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.t.form.itemCart.error.required;
                              }

                              final parsedValue = int.tryParse(value);
                              if (parsedValue == null || parsedValue <= 0) {
                                return context.t.form.itemCart.error.noZero;
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox.square(dimension: 12),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add),
                          onPressed: () => changeQuantity(1),
                          style:
                              CustomSearchFieldActionButton.defaultStyle(
                                context,
                              ).copyWith(
                                minimumSize: WidgetStateProperty.all(
                                  const Size.square(48),
                                ),
                                backgroundColor: WidgetStateProperty.all(
                                  _theme.colorScheme.primary.withValues(alpha: 0.15),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  _theme.colorScheme.primary,
                                ),
                                side: WidgetStateProperty.all(BorderSide.none),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox.square(dimension: 24),

                    // Action Button
                    ElevatedButton(
                      onPressed: () {
                        if (Form.maybeOf(formContext)?.validate() == true) {
                          Navigator.of(modalContext).pop(_quantity);
                        }
                      },
                      child: Text(context.t.action.update),
                    ),

                    // Keyboard Spacer
                    SizedBox.square(
                      dimension: MediaQuery.viewInsetsOf(modalContext).bottom,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static bool hasItems(BuildContext context, ItemCartNotifierBase cart) {
    if (cart.cartItems.isEmpty) {
      showCustomSnackBar(
        context,
        // content: Text("Please add items to cart first"),
        content: Text(context.t.exceptions.pleaseAddItemToTheCartFirst),
        customSnackBarType: CustomOverlayType.info,
      );
      return false;
    }
    return true;
  }
}
