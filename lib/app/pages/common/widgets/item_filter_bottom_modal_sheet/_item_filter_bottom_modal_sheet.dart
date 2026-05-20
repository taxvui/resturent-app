import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

enum ItemFilterType { category, menu, foodType, price }

Future<Map<ItemFilterType, dynamic>?> showItemFilterBottomModalSheet({
  required BuildContext context,
  List<FilterModalData<ItemFilterType, dynamic>>? customFilters,
  Map<ItemFilterType, dynamic>? selectedFilters,
}) async {
  final ref = ProviderScope.containerOf(context);

  final filterFutures = <ItemFilterType, Future<dynamic>>{
    ItemFilterType.category: ref.read(itemCategoryDropdownProvider.future),
    ItemFilterType.menu: ref.read(itemMenuDropdownProvider.future),
  };

  final results = await showAsyncLoadingOverlay(
    context,
    asyncFunction: () => Future.wait(
      filterFutures.entries.map(
        (entry) => entry.value.catchError((_) => null),
      ),
    ),
  );

  final resolvedFilters = {
    for (var i = 0; i < filterFutures.keys.length; i++) filterFutures.keys.elementAt(i): results[i],
  };

  if (!context.mounted) return null;

  final _newFilters =
      selectedFilters ??
      <ItemFilterType, dynamic>{
        ItemFilterType.price: 'low_to_high',
        ItemFilterType.foodType: null,
      };

  await showFilterModalSheet<ItemFilterType, dynamic>(
    context: context,
    selectedFilters: _newFilters,
    onSave: (value) => _newFilters
      ..clear()
      ..addAll(value),
    filters: [
      // Category Filter
      FilterModalData.dropdown(
        key: ItemFilterType.category,
        labelText: context.t.form.category.label(n: 1),
        hintText: context.t.form.category.hint,
        items: [
          ...?(resolvedFilters[ItemFilterType.category] as ItemCategoryList?)?.data?.data?.map(
            (category) {
              return CustomDropdownMenuItem<int>(
                value: category.id,
                label: TextSpan(text: category.categoryName ?? "N/A"),
              );
            },
          ),
        ],
      ),

      // Menu Filter
      FilterModalData.dropdown(
        key: ItemFilterType.menu,
        labelText: 'Menu',
        hintText: 'Select item menu',
        items: [
          ...?(resolvedFilters[ItemFilterType.menu] as ItemMenuList?)?.data?.data?.map(
            (menu) {
              return CustomDropdownMenuItem<int>(
                value: menu.id,
                label: TextSpan(text: menu.name ?? "N/A"),
              );
            },
          ),
        ],
      ),

      // Food Type Filter
      FilterModalData.custom(
        key: ItemFilterType.foodType,
        builder: (_, {initialValue, required onChanged}) {
          return SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ItemFoodTypeEnum.values.length,
              itemBuilder: (_, index) {
                final _foodType = ItemFoodTypeEnum.values[index];
                final _isSelected = initialValue == _foodType;

                return SelectedButton(
                  isSelected: _isSelected,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(_foodType.label(context)),
                  onPressed: () {
                    return onChanged(_isSelected ? null : _foodType);
                  },
                );
              },
              separatorBuilder: (_, _) {
                return const SizedBox.square(dimension: 8);
              },
            ),
          );
        },
      ),

      // Price Filter
      FilterModalData.radioTiles(
        key: ItemFilterType.price,
        header: TextSpan(text: context.t.common.price),
        items: [
          RadioFilterModalData(
            label: context.t.prompt.items.filter.extra.lowToHigh,
            value: 'low_to_high',
          ),
          RadioFilterModalData(
            label: context.t.prompt.items.filter.extra.highToLow,
            value: 'high_to_low',
          ),
        ],
      ),

      // Other Custom Filters
      ...?customFilters,
    ],
  );

  return _newFilters;
}
