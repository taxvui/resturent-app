import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';

class SelectIngredientBottomModal extends ConsumerStatefulWidget {
  const SelectIngredientBottomModal({super.key, required this.ingredient});
  final IngredientCartItem ingredient;

  @override
  ConsumerState<SelectIngredientBottomModal> createState() => _SelectIngredientBottomModalState();
}

class _SelectIngredientBottomModalState extends ConsumerState<SelectIngredientBottomModal> {
  //----------------------Form Field Props----------------------//
  late int quantity;
  late final quantityController = TextEditingController();
  late final unitPriceController = TextEditingController();
  ItemUnit? selectedUnit;
  final focusNode = FocusNode();
  late final totalPriceNotifier = ValueNotifier<num>(0);

  void changeQuantity(int value, {bool fresh = false}) {
    quantity = fresh ? value : quantity + value;
    quantityController.text = quantity.toString();
  }

  void _updateTotal() {
    final unitPrice = unitPriceController.getNumber ?? 0;
    totalPriceNotifier.value = quantity * unitPrice;
  }
  //----------------------Form Field Props----------------------//

  @override
  void initState() {
    super.initState();
    quantity = widget.ingredient.quantity;
    selectedUnit = widget.ingredient.unit;
    quantityController.text = quantity.toString();
    unitPriceController.text = widget.ingredient.unitPrice?.toString() ?? '';

    quantityController.addListener(_updateTotal);
    unitPriceController.addListener(_updateTotal);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
      _updateTotal();
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    totalPriceNotifier.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemUnitAsync = ref.watch(itemUnitDropdownProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: widget.ingredient.name ?? "Ingredient"),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.outlined(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 0) {
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
                      child: NumberFormField(
                        controller: quantityController,
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(hintText: 'Ex: 10'),
                        textInputAction: TextInputAction.done,
                        decimalDigits: 0,
                        onChanged: (value) {
                          final _newQ = int.tryParse(value.trim()) ?? 0;
                          changeQuantity(_newQ, fresh: true);
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter quantity';
                          }

                          final parsedValue = int.tryParse(value);
                          if (parsedValue == null || parsedValue <= 0) {
                            return 'Quantity must be greater than 0';
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
                const SizedBox.square(dimension: 16),

                // Unit Price & Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit Price
                    Expanded(
                      child: NumberFormField(
                        controller: unitPriceController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price*',
                          hintText: 'Ex: \$1000',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Please enter unit price',
                          ),
                          FormBuilderValidators.notZeroNumber(
                            errorText: 'Unit price must be greater than 0',
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox.square(dimension: 14),

                    // Unit
                    Expanded(
                      child: AsyncCustomDropdown<ItemUnit, ItemUnitList>(
                        asyncData: itemUnitAsync,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          hintText: 'Select one',
                        ),
                        value: selectedUnit,
                        items: itemUnitAsync.when(
                          data: (data) => [
                            // Navigator
                            CustomDropdownMenuItem.navigator(
                              label: '#',
                              navLabel: '+ Add New',
                              onNavTap: () async {
                                if (ref.canSnackbar(context, PMKeys.units, action: PermissionAction.create)) {
                                  return await context.router.push<ItemUnit>(ManageUnitRoute()).then(
                                    (value) {
                                      if (value != null) {
                                        setState(() => selectedUnit = value);
                                      }
                                    },
                                  );
                                }
                              },
                            ),

                            // Unit List
                            ...?data.data?.data?.map((unit) {
                              return CustomDropdownMenuItem(
                                value: unit,
                                label: TextSpan(text: unit.unitName ?? "N/A"),
                              );
                            }),
                          ],
                          error: (e, s) => [],
                          loading: () => [],
                        ),
                        onChanged: (v) => setState(() => selectedUnit = v),
                        validator: FormBuilderValidators.required(
                          errorText: 'Please select a unit.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 24),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    if (Form.maybeOf(formContext)?.validate() == true) {
                      Navigator.of(context).pop(
                        widget.ingredient.copyWith(
                          quantity: quantity,
                          unitPrice: unitPriceController.getNumber,
                          unitId: selectedUnit?.id,
                          unit: selectedUnit,
                        ),
                      );
                    }
                  },
                  child: ValueListenableBuilder<num>(
                    valueListenable: totalPriceNotifier,
                    builder: (_, totalPrice, _) {
                      return Text('Continue - ${totalPrice.quickCurrency()}');
                    },
                  ),
                ),

                // Keyboard Spacer
                SizedBox.square(
                  dimension: MediaQuery.viewInsetsOf(context).bottom,
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }
}

Future<IngredientCartItem?> showSelectedIngredientModal(
  BuildContext context,
  IngredientCartItem ingredient,
) async {
  return await showModalBottomSheet<IngredientCartItem>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    builder: (modalContext) {
      return SelectIngredientBottomModal(
        ingredient: ingredient,
      );
    },
  );
}

class IngredientCartItem {
  int? id;
  String? name;
  int quantity;
  num? unitPrice;
  int? unitId;
  ItemUnit? unit;

  IngredientCartItem({
    this.id,
    this.name,
    this.quantity = 0,
    this.unitPrice,
    this.unitId,
    this.unit,
  });

  num get totalPrice => quantity * (unitPrice ?? 0);

  IngredientCartItem copyWith({
    int? id,
    String? name,
    int? quantity,
    num? unitPrice,
    int? unitId,
    ItemUnit? unit,
  }) {
    return IngredientCartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitId: unitId ?? this.unitId,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IngredientCartItem && other.id == id && other.unitId == unitId;
  }

  @override
  int get hashCode => Object.hash(id, unitId);

  @override
  String toString() {
    return 'IngredientCartItem(id: $id, name: $name, quantity: $quantity, unitPrice: $unitPrice, unitId: $unitId)';
  }
}
