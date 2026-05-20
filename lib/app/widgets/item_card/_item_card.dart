import 'package:faker/faker.dart' as f;
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/core.dart';
import '../widgets.dart';

class HorizontalItemCard extends StatelessWidget {
  const HorizontalItemCard._({
    super.key,
    required this.data,
    this.onTap,
    required this.cardType,
    this.action,
    this.cartQuantity,
    this.onChangeQuantity,
    this.onRemoveItem,
    this.maxHeight = 78,
    this.padding,
    required this.saleAsPrimaryPrice,
  });

  final ItemCardData data;
  final void Function()? onTap;
  // ignore: library_private_types_in_public_api
  final _HorizontalItemCardType cardType;
  final Widget? action;
  final int? cartQuantity;
  final void Function(int newQuantity)? onChangeQuantity;
  final void Function()? onRemoveItem;
  final double maxHeight;
  final EdgeInsetsGeometry? padding;
  final bool saleAsPrimaryPrice;

  const HorizontalItemCard.itemList({
    Key? key,
    required ItemCardData data,
    required Widget action,
    void Function()? onTap,
    bool saleAsPrimaryPrice = true,
    EdgeInsetsGeometry? padding,
  }) : this._(
          key: key,
          data: data,
          cardType: _HorizontalItemCardType.itemList,
          action: action,
          onTap: onTap,
          padding: padding,
          saleAsPrimaryPrice: saleAsPrimaryPrice,
        );

  const HorizontalItemCard.cartList({
    Key? key,
    required ItemCardData data,
    required int cartQuantity,
    required void Function(int newQuantity)? onChangeQuantity,
    void Function()? onTap,
    void Function()? onRemoveItem,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(horizontal: 0),
    bool saleAsPrimaryPrice = true,
  }) : this._(
          key: key,
          data: data,
          cardType: _HorizontalItemCardType.cartList,
          cartQuantity: cartQuantity,
          onChangeQuantity: onChangeQuantity,
          onTap: onTap,
          onRemoveItem: onRemoveItem,
          maxHeight: 68,
          padding: padding,
          saleAsPrimaryPrice: saleAsPrimaryPrice,
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCartItem = cardType == _HorizontalItemCardType.cartList;

    return Slidable(
      key: ValueKey(data.hashCode),
      endActionPane: isCartItem
          ? ActionPane(
              closeThreshold: 0.25,
              openThreshold: 0.25,
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => onRemoveItem?.call(),
                  backgroundColor: Colors.red.withValues(alpha: 0.10),
                  foregroundColor: Colors.red,
                  icon: FeatherIcons.trash2,
                ),
              ],
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints.tightFor(height: maxHeight),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: Divider.createBorderSide(context),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Item Image
              SizedBox.square(
                dimension: isCartItem ? 64 : 88,
                child: CustomNetworkImage(
                  url: data.imageUrl,
                  fit: BoxFit.fitWidth,
                ).fMarginAll(6),
              ),

              // Main content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: cardType == _HorizontalItemCardType.itemList
                      ? _buildItemListContent(context, theme)
                      : _buildCartListContent(context, theme, isCartItem),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemListContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item Name
              Text(
                data.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 2),

              // Item Price
              Text(
                data.salesPrice.quickCurrency(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 2),
            ],
          ),
        ),
        ?action,
      ],
    );
  }

  Widget _buildCartListContent(
    BuildContext context,
    ThemeData theme,
    bool isCartItem,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 4),
              Text(
                (saleAsPrimaryPrice ? data.salesPrice : data.purchasePrice).quickCurrency(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          spacing: 8,
          children: [
            IconButton(
              onPressed: onChangeQuantity == null
                  ? null
                  : () {
                      final newQuantity = (cartQuantity ?? 0) - 1;
                      if (newQuantity >= 0) onChangeQuantity?.call(newQuantity);
                    },
              icon: const Icon(Bootstrap.dash_square),
              style: IconButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                iconSize: 20,
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
            Text(
              (cartQuantity ?? 0).commaSeparated(decimalDigits: 0),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            IconButton(
              onPressed: onChangeQuantity == null
                  ? null
                  : () {
                      final newQuantity = (cartQuantity ?? 0) + 1;
                      onChangeQuantity?.call(newQuantity);
                    },
              icon: const Icon(Bootstrap.plus_square),
              style: IconButton.styleFrom(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                iconSize: 20,
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _HorizontalItemCardType { itemList, cartList }

class ItemCardData {
  final String? imageUrl;
  final String itemName;
  final num purchasePrice;
  final num salesPrice;

  const ItemCardData({
    this.imageUrl,
    required this.itemName,
    this.purchasePrice = 0,
    this.salesPrice = 0,
  });

  factory ItemCardData.mock([int randomness = 1]) {
    return ItemCardData(
      itemName: f.faker.food.dish(),
      imageUrl: f.faker.image.loremPicsum(random: randomness),
      purchasePrice: f.random.decimal(min: 10),
      salesPrice: f.random.decimal(min: 10),
    );
  }

  ItemCardData copyWith({
    String? imageUrl,
    String? itemName,
    int? stock,
    num? purchasePrice,
    num? salesPrice,
  }) {
    return ItemCardData(
      imageUrl: imageUrl ?? this.imageUrl,
      itemName: itemName ?? this.itemName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salesPrice: salesPrice ?? this.salesPrice,
    );
  }
}

class VerticalItemCard extends StatelessWidget {
  const VerticalItemCard({
    super.key,
    required this.data,
    this.cartQuantity = 0,
    this.onClearQuantity,
    this.onTap,
    this.onQuantityTap,
    this.saleAsPrimaryPrice = true,
  });
  final ItemCardData data;
  final int? cartQuantity;
  final VoidCallback? onClearQuantity;
  final VoidCallback? onTap;
  final VoidCallback? onQuantityTap;
  final bool saleAsPrimaryPrice;

  @override
  Widget build(BuildContext context) {
    final _mqSize = MediaQuery.sizeOf(context);
    final _theme = Theme.of(context);

    final _addedToCart = cartQuantity != null && cartQuantity! > 0;

    return LayoutBuilder(
      builder: (_, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              clipBehavior: Clip.antiAlias,
              constraints: constraints,
              decoration: BoxDecoration(
                color: _theme.colorScheme.primaryContainer,
                boxShadow: [DAppBoxShadowStyles.boxShadow2],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      _addedToCart ? _theme.colorScheme.primary : _theme.colorScheme.secondary.withValues(alpha: 0.2),
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Column(
                children: [
                  // Image
                  Container(
                    constraints: BoxConstraints.tightFor(
                      height: _mqSize.isTn ? 72 : 90,
                    ),
                    decoration: BoxDecoration(
                      color: _theme.colorScheme.primaryContainer,
                    ),
                    alignment: AlignmentDirectional.topEnd,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: CustomNetworkImage(
                            url: data.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (_addedToCart) ...[
                          PositionedDirectional(
                            top: 6,
                            start: 6,
                            end: 0,
                            child: SizedBox(
                              height: 20,
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: InkWell(
                                      onTap: onQuantityTap,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 34,
                                          minHeight: 20,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          cartQuantity!.toString(),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: _theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Clear Button
                                  CloseButton(
                                    onPressed: () => onClearQuantity?.call(),
                                    color: Colors.red,
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -4,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),

                  // Description
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Item Name
                          Text(
                            data.itemName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: _mqSize.isTn ? 12 : null,
                            ),
                          ),

                          // Price
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _addedToCart ? _theme.colorScheme.primaryContainer : null,
                            ),
                            child: Text(
                              (saleAsPrimaryPrice ? data.salesPrice : data.purchasePrice).quickCurrency(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    _addedToCart ? _theme.colorScheme.onPrimaryContainer : _theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ).fMarginSymmetric(horizontal: 4, vertical: 2),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
