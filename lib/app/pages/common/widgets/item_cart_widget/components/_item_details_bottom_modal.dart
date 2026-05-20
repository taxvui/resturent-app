import 'package:expansion_widget/expansion_widget.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';
import '../item_cart_widget.dart' show ItemCartModel;

class ItemDetailsBottomModal extends ConsumerStatefulWidget {
  const ItemDetailsBottomModal({
    super.key,
    required this.item,
    this.cartItem,
  });
  final PItem item;

  final ItemCartModel? cartItem;
  bool get isEditMode => cartItem != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemDetailsBottomModalState();
}

class _ItemDetailsBottomModalState extends ConsumerState<ItemDetailsBottomModal> {
  //-----------------------Form Field Props-----------------------//
  late final ValueNotifier<List<PItemVariation>> selectedVariationsNotifier;
  late final ValueNotifier<int> quantityNotifier;
  late final instractionController = TextEditingController();
  late final ValueNotifierMap<int, ValueNotifierList<ModifierOption>> selectedItemModifierGroupsNotifier;
  late final ValueNotifier<num> totalAmountNotifier;

  num _calculateItemTotal() {
    final _itemType = ItemTypeEnum.fromString(widget.item.priceType);

    final basePrice = _itemType.isVariation
        ? selectedVariationsNotifier.value.fold<num>(0, (p, eV) => p + (eV.price ?? 0))
        : (widget.item.salesPrice ?? 0);

    final optionsSum = selectedItemModifierGroupsNotifier.values.fold<num>(
      0,
      (sumGroup, notifierList) {
        final list = notifierList.value;
        final groupSum = list.fold<num>(0, (sumOpt, opt) => sumOpt + (opt.price ?? 0));
        return sumGroup + groupSum;
      },
    );

    return (basePrice + optionsSum) * quantityNotifier.value;
  }

  void _updateItemTotal() {
    totalAmountNotifier.value = _calculateItemTotal();
  }
  //-----------------------Form Field Props-----------------------//

  void initData() {
    if (widget.isEditMode) {
      selectedVariationsNotifier = ValueNotifier<List<PItemVariation>>(widget.cartItem?.variations ?? []);
      quantityNotifier = ValueNotifier(widget.cartItem?.cartQuantity ?? 1);
      selectedItemModifierGroupsNotifier = ValueNotifierMap<int, ValueNotifierList<ModifierOption>>({
        ...?widget.cartItem?.modifierOptions?.map<int, ValueNotifierList<ModifierOption>>((modifierId, options) {
          return MapEntry(
            modifierId,
            ValueNotifierList<ModifierOption>(options)..addListener(_updateItemTotal),
          );
        }),
      });
      totalAmountNotifier = ValueNotifier(widget.cartItem?.totalPrice ?? _calculateItemTotal());
      instractionController.text = widget.cartItem?.instrctions ?? '';
    } else {
      selectedVariationsNotifier = ValueNotifier([]);
      quantityNotifier = ValueNotifier(1);
      selectedItemModifierGroupsNotifier = ValueNotifierMap();
      totalAmountNotifier = ValueNotifier(_calculateItemTotal());
    }

    quantityNotifier.addListener(_updateItemTotal);
    selectedVariationsNotifier.addListener(_updateItemTotal);
    selectedItemModifierGroupsNotifier.addListener(_updateItemTotal);
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final itemDetailsAsync = ref.watch(itemDetailsProvider(widget.item.id!));
    final itemDetails = itemDetailsAsync.value?.data;
    final _itemType = ItemTypeEnum.fromString(itemDetails?.priceType);

    final _theme = Theme.of(context);

    final _sectionHeader = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return BottomModalSheetWrapper(
      title: TextSpan(text: context.t.common.itemDetails),
      child: FormWrapper(
        builder: (formContext) {
          return RefreshIndicator.adaptive(
            onRefresh: () => ref.refresh(itemDetailsProvider(widget.item.id!).future),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Skeletonizer(
                      enabled: itemDetailsAsync.isLoading,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Overview
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 68,
                                child: CustomNetworkImage(
                                  url: itemDetails?.images?.firstOrNull?.remote,
                                ),
                              ),
                              const SizedBox.square(dimension: 10),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Item Name
                                    Text(
                                      itemDetails?.productName ?? "N/A",
                                      style: _theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    if (!_itemType.isVariation) ...[
                                      // Item Price
                                      Text(
                                        itemDetails?.salesPrice?.quickCurrency() ?? "N/A",
                                        style: _theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox.square(dimension: 2),
                                    ],

                                    // Item Category & Food Type
                                    Text(
                                      '${ItemFoodTypeEnum.fromString(itemDetails?.foodType).label(context)} - ${itemDetails?.category?.categoryName ?? ''}',
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: _theme.paragraphColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox.square(dimension: 8),

                          // Preparation Time
                          Text.rich(
                            context.t.pages.items.itemDetails.extra.preparationTime(
                              min: TextSpan(
                                text: itemDetails?.preparationTime ?? '0',
                                style: TextStyle(
                                  color: _theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              mins: (p0) => TextSpan(
                                text: p0,
                                style: TextStyle(
                                  color: _theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            style: _theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _theme.paragraphColor,
                            ),
                          ),

                          // Description
                          if (itemDetails?.description != null) ...[
                            const SizedBox.square(dimension: 4),
                            ReadMore2(
                              itemDetails!.description!,
                              textStyle: _theme.textTheme.bodyMedium?.copyWith(
                                color: _theme.paragraphColor,
                              ),
                            ),
                          ],
                          const SizedBox.square(dimension: 16),

                          // Item Variations
                          if (_itemType.isVariation) ...[
                            Text(context.t.common.variations, style: _sectionHeader),
                            const SizedBox.square(dimension: 10),
                            ValueListenableBuilder(
                              valueListenable: selectedVariationsNotifier,
                              builder: (_, selectedVariations, _) {
                                return FormField<List<PItemVariation>>(
                                  validator: FormBuilderValidators.required(
                                    errorText: context.t.pages.items.itemDetails.extra.pleaseSelectVariation,
                                  ),
                                  initialValue: selectedVariations,
                                  builder: (field) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        ...?itemDetails?.variations?.map((itemVariation) {
                                          final _isSelected = selectedVariations.contains(itemVariation);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.fromBorderSide(
                                                Divider.createBorderSide(context),
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(itemVariation.name ?? "N/A"),
                                                      Text(itemVariation.price?.quickCurrency() ?? "N/A"),
                                                    ],
                                                  ),
                                                ),
                                                FilledButton(
                                                  style: FilledButton.styleFrom(
                                                    minimumSize: const Size(82, 32),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    backgroundColor: _isSelected
                                                        ? _theme.colorScheme.primary
                                                        : _theme.colorScheme.primary.withValues(
                                                            alpha: 0.15,
                                                          ),
                                                    foregroundColor: _isSelected
                                                        ? _theme.colorScheme.onPrimary
                                                        : _theme.colorScheme.primary,
                                                  ),
                                                  onPressed: () {
                                                    final newList = List.of(selectedVariations);
                                                    if (_isSelected) {
                                                      newList.remove(itemVariation);
                                                    } else {
                                                      newList.add(itemVariation);
                                                    }

                                                    field.didChange(newList);
                                                    return selectedVariationsNotifier.set(newList);
                                                  },
                                                  child: Text(
                                                    _isSelected ? context.t.action.selected : context.t.action.select,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),

                                        // Error Text
                                        if (field.hasError) ...[
                                          Text(
                                            field.errorText!,
                                            style: _theme.inputDecorationTheme.errorStyle,
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox.square(dimension: 16),
                          ],

                          // Modifier Options
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...?itemDetails?.modifiers?.map((itemModifier) {
                                final groupId = itemModifier.id!;
                                selectedItemModifierGroupsNotifier.putIfAbsent(
                                  groupId,
                                  () => ValueNotifierList<ModifierOption>()..addListener(_updateItemTotal),
                                );

                                return ValueListenableBuilder(
                                  valueListenable: selectedItemModifierGroupsNotifier,
                                  builder: (_, selectedItemModifierGroups, _) {
                                    final selectedGroupOptionsNotifier = selectedItemModifierGroups[groupId]!;
                                    return ValueListenableBuilder(
                                      valueListenable: selectedGroupOptionsNotifier,
                                      builder: (_, selectedGroupOptions, _) {
                                        return FormField<ModifierOption?>(
                                          initialValue: selectedGroupOptions.firstOrNull,
                                          validator: !itemModifier.isRequired
                                              ? null
                                              : FormBuilderValidators.required(
                                                  // errorText: 'Please select an option.',
                                                  errorText: context.t.pages.items.itemDetails.extra.pleaseSelectOption,
                                                ),
                                          builder: (field) {
                                            return ExpansionWidget.autoSaveState(
                                              initiallyExpanded: true,
                                              titleBuilder: (av, ev, ie, tf) {
                                                return InkWell(
                                                  onTap: () => tf(animated: true),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        ie ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                                        size: 20,
                                                        color: _theme.colorScheme.primary,
                                                      ),
                                                      const SizedBox.square(dimension: 8),
                                                      Text(
                                                        itemModifier.modifierGroup?.name ?? "N/A",
                                                        style: _theme.textTheme.bodyLarge?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              expandedAlignment: Alignment.centerLeft,
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox.square(dimension: 10),
                                                  ...?itemModifier.modifierGroup?.options?.map((groupOption) {
                                                    return _buildRow(
                                                      context,
                                                      label: groupOption.name ?? "N/A",
                                                      value: groupOption.price?.quickCurrency() ?? "N/A",
                                                      isSelected: selectedGroupOptions.contains(groupOption),
                                                      isAvailable: groupOption.isAvailable,
                                                      onSelected: (value) {
                                                        if (value) {
                                                          if (!itemModifier.isMultiple) {
                                                            selectedGroupOptionsNotifier.clear();
                                                          }
                                                          selectedGroupOptionsNotifier.add(groupOption);
                                                          field.didChange(groupOption);
                                                        } else {
                                                          selectedGroupOptionsNotifier.remove(groupOption);
                                                          field.didChange(null);
                                                        }
                                                      },
                                                    ).fMarginOnly(bottom: 10);
                                                  }),

                                                  // Error Text
                                                  if (field.hasError) ...[
                                                    Text(
                                                      field.errorText!,
                                                      style: _theme.inputDecorationTheme.errorStyle,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                          const SizedBox.square(dimension: 8),

                          // Instructions
                          // Text('Instructions', style: _sectionHeader),
                          Text(context.t.common.instructions, style: _sectionHeader),
                          const SizedBox.square(dimension: 8),
                          TextFormField(
                            controller: instractionController,
                            minLines: 2,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              // hintText: 'Enter your instructions',
                              hintText: context.t.pages.items.itemDetails.extra.enterYourInstruction,
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Bar
                Skeletonizer(
                  enabled: itemDetailsAsync.isLoading,
                  child: Row(
                    children: [
                      // Quantity
                      Flexible(
                        flex: 0,
                        child: ValueListenableBuilder(
                          valueListenable: quantityNotifier,
                          builder: (_, quantity, _) {
                            return Row(
                              spacing: 18,
                              children: [
                                IconButton.outlined(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      quantityNotifier.set((quantity - 1));
                                    }
                                  },
                                  style:
                                      CustomSearchFieldActionButton.defaultStyle(
                                        context,
                                      ).copyWith(
                                        minimumSize: WidgetStateProperty.all(
                                          const Size.square(32),
                                        ),
                                      ),
                                ),
                                Text(
                                  quantity.commaSeparated(),
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => quantityNotifier.set(quantity + 1),
                                  style:
                                      CustomSearchFieldActionButton.defaultStyle(
                                        context,
                                      ).copyWith(
                                        minimumSize: WidgetStateProperty.all(
                                          const Size.square(32),
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
                            );
                          },
                        ),
                      ),
                      const SizedBox.square(dimension: 24),

                      // Add to Cart
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: totalAmountNotifier,
                          builder: (_, totalAmount, _) {
                            return ElevatedButton(
                              onPressed: itemDetails == null
                                  ? null
                                  : () {
                                      if (FormWrapper.validate(formContext)) {
                                        return _handleManageCartItem(context, itemDetails);
                                      }
                                    },
                              // child: Text('Add to Cart: ${totalAmount.quickCurrency()}'),
                              child: Text('${context.t.action.addToCart}: ${totalAmount.quickCurrency()}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ).fMarginLTRB(16, 12, 16, 16),

                // Keyboard Spacer
                SizedBox.square(
                  dimension: MediaQuery.viewInsetsOf(context).bottom,
                ),
              ],
            ),
          );
        },
      ),
    ).unfocusPrimary();
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isAvailable = true,
    bool isSelected = false,
    ValueChanged<bool>? onSelected,
  }) {
    final _theme = Theme.of(context);

    return GestureDetector(
      onTap: isAvailable ? () => onSelected?.call(!isSelected) : null,
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (isAvailable)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SizedBox.square(
                        dimension: 16,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (v) => onSelected?.call(v!),
                        ),
                      ).fMarginOnly(right: 8),
                    ),
                  TextSpan(text: label),
                ],
              ),
              style: _theme.textTheme.bodyLarge?.copyWith(
                color: isAvailable ? _theme.paragraphColor : DAppColors.kError,
              ),
            ),
          ),
          Flexible(
            flex: 0,
            child: isAvailable
                ? Text(
                    value,
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: DAppColors.kError.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      // 'Unavailable',
                      context.t.common.unavailable,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: DAppColors.kError,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleManageCartItem(BuildContext context, PItem itemDetails) {
    final _data = (widget.cartItem ?? ItemCartModel(item: itemDetails)).copyWith(
      cartQuantity: quantityNotifier.value,
      totalPrice: totalAmountNotifier.value,
      variations: selectedVariationsNotifier.value,
      modifierOptions: {
        ...selectedItemModifierGroupsNotifier.map(
          (modifierId, options) => MapEntry(modifierId, options.value),
        ),
      },
      instrctions: instractionController.text,
    );

    return Navigator.of(context).pop(_data);
  }
}

Future<ItemCartModel?> showItemDetailsModal(
  BuildContext context,
  PItem item, {
  ItemCartModel? cartItem,
}) {
  return showModalBottomSheet<ItemCartModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    builder: (popContext) {
      return ItemDetailsBottomModal(
        item: item,
        cartItem: cartItem,
      );
    },
  );
}
