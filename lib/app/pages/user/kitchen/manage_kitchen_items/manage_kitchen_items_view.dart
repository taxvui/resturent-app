import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

class ManageKitchenItemsView extends ConsumerStatefulWidget {
  const ManageKitchenItemsView({super.key, required this.kitchen});
  final KitchenModel kitchen;

  @override
  ConsumerState<ManageKitchenItemsView> createState() => _ManageKitchenItemsViewState();
}

class _ManageKitchenItemsViewState extends _$ManageKitchenItemsViewState {
  @override
  void initState() {
    initEdit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final unassignedProductsAsync = ref.watch(unassignedProductsProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: context.t.pages.kitchen.manageItems.title),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              // Items
              ValueListenableBuilder(
                valueListenable: selectedItemsNotifier,
                builder: (_, selectedItems, _) {
                  return MultiSelectFormField<PItem, List<PItem>>.dropdown(
                    asyncData: unassignedProductsAsync,
                    decoration: InputDecoration(
                      labelText: context.t.common.items,
                      hintText: context.t.form.item.hint,
                    ),
                    selectedItemBuilder: (context, item, onRemove) {
                      return MultiSelectedItemButton(label: item.label);
                    },
                    value: selectedItems,
                    items: unassignedProductsAsync.when(
                      data: (data) {
                        return List<PItem>.from([...widget.kitchen.products, ...data]).map((item) {
                          return CustomDropdownMenuItem<PItem>(
                            value: item,
                            label: TextSpan(text: item.productName ?? "N/A"),
                          );
                        }).toList();
                      },
                      error: (_, _) => [],
                      loading: () => [],
                    ),
                    onChanged: selectedItemsNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.pages.kitchen.manageItems.selectItemsError,
                    ),
                    onRefresh: () => ref.refresh(unassignedProductsProvider.future),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Added Items
              ValueListenableBuilder(
                valueListenable: selectedItemsNotifier,
                builder: (_, selectedItems, _) {
                  return Container(
                    constraints: BoxConstraints.tight(Size.fromHeight(205)),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(Divider.createBorderSide(context)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        DefaultTextStyle.merge(
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          child: Container(
                            width: double.maxFinite,
                            color: DAppColors.kSurfaceLight,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text(context.t.pages.kitchen.manageItems.addedItems),
                          ),
                        ),

                        // Items
                        if (selectedItems.isEmpty) ...[
                          Expanded(
                            child: Center(
                              child: Text(
                                context.t.pages.kitchen.manageItems.noItemsAdded,
                                textAlign: TextAlign.center,
                                style: _theme.textTheme.bodyMedium?.copyWith(
                                  color: _theme.paragraphColor,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              itemCount: selectedItems.length,
                              itemBuilder: (_, index) {
                                final item = selectedItems[index];

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: Divider.createBorderSide(context)),
                                  ),
                                  child: Row(
                                    spacing: 12,
                                    children: [
                                      Text((index + 1).commaSeparated()),

                                      // Name
                                      Expanded(
                                        child: Text(item.productName ?? "N/A"),
                                      ),

                                      // Price
                                      Flexible(
                                        flex: 0,
                                        child: Text(
                                          item.currentPrice.quickCurrency(),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),

                                      // Delete Action
                                      IconButton(
                                        onPressed: () {
                                          final _newList = List<PItem>.from(selectedItems)
                                            ..removeWhere((element) => element == item);
                                          return selectedItemsNotifier.set(_newList);
                                        },
                                        style: IconButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          visualDensity: const VisualDensity(
                                            horizontal: VisualDensity.minimumDensity,
                                            vertical: VisualDensity.minimumDensity,
                                          ),
                                          iconSize: 16,
                                          foregroundColor: DAppColors.kError,
                                        ),
                                        icon: const Icon(FeatherIcons.trash2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 24),

              // Action Buttons
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: SizedBox.fromSize(
                      size: const Size.fromHeight(48),
                      child: OutlinedButton(
                        onPressed: Navigator.of(context).pop,
                        style: CustomButtonStyles.destructiveOutline(),
                        child: Text(context.t.action.cancel),
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 14),

                  // Save
                  Expanded(
                    child: SizedBox.fromSize(
                      size: const Size.fromHeight(48),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (FormWrapper.validate(formContext)) {
                            return handleFormSubmit(context);
                          }
                        },
                        child: Text(context.t.action.save),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).unfocusPrimary();
  }
}

abstract class _$ManageKitchenItemsViewState extends ConsumerState<ManageKitchenItemsView> {
  //---------------------------Form Field Props---------------------------//
  final selectedItemsNotifier = ValueNotifier<List<PItem>>([]);
  //---------------------------Form Field Props---------------------------//

  void initEdit() {
    selectedItemsNotifier.value = widget.kitchen.products;
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = widget.kitchen.copyWith(
        products: selectedItemsNotifier.value,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(kitchenRepoProvider).manageKitchenItems(_data),
        ),
      );

      if (context.mounted) {
        context.router.maybePop(_result);
        return;
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
