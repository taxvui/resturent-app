import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../core/core.dart';
import '../widgets.dart';

//------------------------------Widgets & Usages------------------------------//
class _FilterBottomModalSheet<R, T> extends StatefulWidget {
  _FilterBottomModalSheet({
    super.key,
    this.header,
    this.selectedFilters,
    required this.filters,
  }) : assert(filters.isNotEmpty, "`filters cannot be empty`");

  final InlineSpan? header;
  final FilterValue<R, T>? selectedFilters;
  final List<FilterModalData<R, T>> filters;

  @override
  State<_FilterBottomModalSheet<R, T>> createState() => _FilterBottomModalSheetState<R, T>();
}

class _FilterBottomModalSheetState<R, T> extends State<_FilterBottomModalSheet<R, T>> {
  final FilterValue<R, T> values = {};

  @override
  void initState() {
    super.initState();

    values
      ..clear()
      ..addEntries(
        widget.filters.map((entry) {
          return MapEntry(
            entry.key,
            widget.selectedFilters?[entry.key] ?? entry.value,
          );
        }),
      );
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints.tightFor(width: double.maxFinite),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          ListTile(
            title: Text.rich(
              widget.header ?? TextSpan(text: context.t.prompt.items.filter.title),
              style: _theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: CloseButton(onPressed: Navigator.of(context).pop),
            visualDensity: const VisualDensity(horizontal: -4),
            contentPadding: const EdgeInsetsDirectional.only(start: 20, end: 8),
          ),
          const Divider(height: 0),

          // Filters
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SimpleResponsiveGridRow(
                children: List.generate(widget.filters.length, (index) {
                  final _filter = widget.filters[index];

                  return SimpleResponsiveGridCol(
                    flex: _filter.gridFlex,
                    child: _filter.builder(
                      context,
                      initialValue: values[_filter.key],
                      onChanged: (nV) => setState(
                        () => values[_filter.key] = nV,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Reset Button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybeOf(context)?.pop(
                      values..clear(),
                    ),
                    style: CustomButtonStyles.destructiveOutline(),
                    child: Text(context.t.action.reset),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Apply Button
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.maybeOf(context)?.pop(values),
                    child: Text(context.t.action.apply),
                  ),
                ),
              ),
            ],
          ).fPaddingSymmetric(horizontal: 20, vertical: 20),
        ],
      ),
    ).unfocusPrimary();
  }
}

Future<void> showFilterModalSheet<R, T>({
  required BuildContext context,
  required List<FilterModalData<R, T>> filters,
  FilterValue<R, T>? selectedFilters,
  void Function(FilterValue<R, T> value)? onSave,
}) async {
  final _result = await showModalBottomSheet<FilterValue<R, T>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (modalContext) {
      return _FilterBottomModalSheet<R, T>(
        key: UniqueKey(),
        filters: filters,
        selectedFilters: selectedFilters,
      );
    },
  );

  if (_result != null) return onSave?.call(_result);
}
//------------------------------Widgets & Usages------------------------------//

typedef FilterValue<R, T> = Map<R, T?>;
typedef FieldWidgetBuilder<T> =
    Widget Function(
      BuildContext context, {
      T? initialValue,
      required ValueChanged<T?> onChanged,
    });

class FilterModalData<R, T> {
  final R key;
  final T? value;
  // ignore: library_private_types_in_public_api
  final FieldWidgetBuilder<T> builder;
  final int gridFlex;

  FilterModalData._({
    required this.key,
    this.value,
    required this.builder,
    required this.gridFlex,
  });

  static const defaultGridFlex = 12;

  factory FilterModalData.dropdown({
    required R key,
    String? labelText,
    String? hintText,
    required List<CustomDropdownMenuItem<T>> items,
    int gridFlex = defaultGridFlex,
  }) {
    return FilterModalData._(
      key: key,
      gridFlex: gridFlex,
      builder: (context, {initialValue, required onChanged}) {
        return CustomDropdown<T>(
          isExpanded: true,
          decoration: InputDecoration(labelText: labelText, hintText: hintText),
          value: initialValue,
          items: items,
          onChanged: onChanged,
        );
      },
    );
  }

  factory FilterModalData.dateFilterDropdown({
    required R key,
    String? labelText,
    String? hintText,
    int gridFlex = defaultGridFlex,
  }) {
    return FilterModalData._(
      key: key,
      gridFlex: gridFlex,
      builder: (context, {initialValue, required onChanged}) {
        return DropdownDateFilter.formField(
          inputDecoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
          ),
          value: initialValue as DateFilterDropdownItem?,
          onChanged: onChanged as ValueChanged<DateFilterDropdownItem?>?,
        );
      },
    );
  }

  factory FilterModalData.radioTiles({
    required R key,
    InlineSpan? header,
    required List<RadioFilterModalData<T>> items,
    int gridFlex = defaultGridFlex,
  }) {
    return FilterModalData._(
      key: key,
      gridFlex: gridFlex,
      builder: (context, {initialValue, required onChanged}) {
        final _theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (header != null) ...[
              Text.rich(
                header,
                style: _theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 2),
            ],

            // Radio Tiles
            RadioGroup<T>(
              groupValue: initialValue,
              onChanged: onChanged,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(items.length, (index) {
                  return RadioListTile<T>(
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(items[index].label),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    value: items[index].value,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  factory FilterModalData.checkBox({
    required R key,
    required String label,
    required bool value,
    int gridFlex = defaultGridFlex,
  }) {
    return FilterModalData._(
      key: key,
      gridFlex: gridFlex,
      builder: (context, {initialValue, required onChanged}) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.trailing,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: initialValue as bool? ?? value,
          onChanged: onChanged as Function(bool? value),
        );
      },
    );
  }

  factory FilterModalData.custom({
    required R key,
    T? value,
    required FieldWidgetBuilder<T> builder,
    int gridFlex = defaultGridFlex,
  }) {
    return FilterModalData._(
      key: key,
      builder: builder,
      gridFlex: gridFlex,
      value: value,
    );
  }
}

class AsyncFilterModalData<R, T, E> extends FilterModalData<R, T> {
  AsyncFilterModalData._({
    required super.key,
    super.value,
    required super.builder,
    required super.gridFlex,
  }) : super._();

  factory AsyncFilterModalData.asyncDropdown({
    required R key,
    String? labelText,
    String? hintText,
    required AsyncValue<E> asyncData,
    required List<CustomDropdownMenuItem<T>> items,
    int gridFlex = FilterModalData.defaultGridFlex,
  }) {
    return AsyncFilterModalData._(
      key: key,
      gridFlex: gridFlex,
      builder: (context, {initialValue, required onChanged}) {
        return AsyncCustomDropdown<T, E>(
          asyncData: asyncData,
          isExpanded: true,
          decoration: InputDecoration(labelText: labelText, hintText: hintText),
          value: initialValue,
          items: items,
          onChanged: onChanged,
        );
      },
    );
  }
}

class RadioFilterModalData<T> {
  final String label;
  final T value;

  const RadioFilterModalData({required this.label, required this.value});

  @override
  bool operator ==(Object other) {
    return other is RadioFilterModalData<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
