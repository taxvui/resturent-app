import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../widgets.dart';

//---------------------------Base Widget---------------------------//
abstract class MultiSelectFormField<T, R> extends StatelessWidget {
  const MultiSelectFormField._({
    super.key,
    this.value,
    required this.asyncData,
    required this.items,
    this.onChanged,
    this.decoration,
    this.selectedItemBuilder,
    this.validator,
    this.onRefresh,
  });
  final List<T>? value;
  final AsyncValue<R> asyncData;
  final VoidCallback? onRefresh;
  final List<CustomDropdownMenuItem<T>> items;
  final ValueChanged<List<T>>? onChanged;
  final InputDecoration? decoration;
  final SelectedItemBuilder<T>? selectedItemBuilder;
  final String? Function(List<T>? value)? validator;

  factory MultiSelectFormField.dropdown({
    Key? key,
    List<T>? value,
    required AsyncValue<R> asyncData,
    VoidCallback? onRefresh,
    required List<CustomDropdownMenuItem<T>> items,
    ValueChanged<List<T>>? onChanged,
    InputDecoration? decoration,
    SelectedItemBuilder<T>? selectedItemBuilder,
    String? Function(List<T>? value)? validator,
  }) {
    return _MultiSelectDropdownWidget<T, R>(
      key: key,
      asyncData: asyncData,
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: decoration,
      selectedItemBuilder: selectedItemBuilder,
      validator: validator,
      onRefresh: onRefresh,
    );
  }

  factory MultiSelectFormField.bottomModal({
    Key? key,
    List<T>? value,
    required AsyncValue<R> asyncData,
    VoidCallback? onRefresh,
    required List<CustomDropdownMenuItem<T>> items,
    ValueChanged<List<T>>? onChanged,
    InputDecoration? decoration,
    SelectedItemBuilder<T>? selectedItemBuilder,
    String? Function(List<T>? value)? validator,
    required BottomModalItemBuilder<T> listBuilder,
  }) {
    return _MultiSelectBottomModalWidget<T, R>(
      key: key,
      asyncData: asyncData,
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: decoration,
      selectedItemBuilder: selectedItemBuilder,
      validator: validator,
      onRefresh: onRefresh,
      listBuilder: listBuilder,
    );
  }
}

typedef SelectedItemBuilder<T> =
    Widget Function(
      BuildContext context,
      CustomDropdownMenuItem<T> item,
      VoidCallback onRemove,
    );

class MultiSelectedItemButton extends StatelessWidget {
  const MultiSelectedItemButton({
    super.key,
    required this.label,
    this.style,
    this.onTap,
    this.onRemove,
  });
  final InlineSpan label;
  final ButtonStyle? style;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _style =
        style ??
        FilledButton.styleFrom(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 2, 4, 2),
          backgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.10),
          foregroundColor: _theme.colorScheme.primary,
          disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.10),
          disabledForegroundColor: _theme.colorScheme.primary,
        );

    return FilledButton.icon(
      label: Text.rich(label),
      onPressed: onTap,
      style: FilledButton.styleFrom(minimumSize: Size.zero).merge(_style),
      icon: onRemove == null
          ? null
          : InkWell(
              onTap: onRemove,
              child: const Icon(Bootstrap.x_circle_fill, color: Colors.red, size: 14),
            ),
      iconAlignment: IconAlignment.end,
    );
  }
}
//---------------------------Base Widget---------------------------//

//---------------------------Dropdown Widget---------------------------//
class _MultiSelectDropdownWidget<T, R> extends MultiSelectFormField<T, R> {
  const _MultiSelectDropdownWidget({
    super.key,
    required super.asyncData,
    super.value,
    required super.items,
    super.onChanged,
    super.decoration,
    super.selectedItemBuilder,
    super.validator,
    super.onRefresh,
  }) : super._();

  @override
  Widget build(BuildContext context) {
    final _selectedValues = <T>{...?value};

    return StatefulBuilder(
      builder: (_, setState) {
        final _showSelected = _selectedValues.isNotEmpty;

        return FormField<List<T>>(
          validator: validator,
          initialValue: value,
          builder: (field) {
            return AsyncCustomDropdown<T, R>(
              asyncData: asyncData,
              decoration: (decoration ?? const InputDecoration()).copyWith(
                errorText: field.errorText,
              ),
              items: items.map((item) {
                return CustomDropdownMenuItem<T>.custom(
                  padding: EdgeInsetsDirectional.zero,
                  enabled: false,
                  value: item.value,
                  child: StatefulBuilder(
                    builder: (context, menuSetState) {
                      final _isSelected = _selectedValues.contains(item.value);
                      return InkWell(
                        onTap: () {
                          _isSelected ? _selectedValues.remove(item.value) : _selectedValues.add(item.value as T);
                          setState(() {});
                          menuSetState(() {});
                        },
                        child: Row(
                          children: [
                            Expanded(child: item.build(context)),
                            Checkbox(
                              value: _isSelected,
                              onChanged: (newVal) {
                                _isSelected ? _selectedValues.remove(item.value) : _selectedValues.add(item.value as T);
                                setState(() {});
                                menuSetState(() {});
                              },
                            ),
                            const SizedBox.square(dimension: 8),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              onChanged: (_) {},
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  field.didChange(_selectedValues.toList());
                  return onChanged?.call(_selectedValues.toList());
                }
              },
              customButton: !_showSelected
                  ? null
                  : SizedBox.fromSize(
                      size: Size.fromHeight(48),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 12, bottom: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedValues.length,
                        itemBuilder: (_, index) {
                          final _selectedItem = items.firstWhere((it) {
                            return it.value == _selectedValues.toList().reversed.toList()[index];
                          });

                          if (selectedItemBuilder != null) {
                            return selectedItemBuilder!(
                              context,
                              _selectedItem,
                              () {
                                setState(
                                  () => _selectedValues.remove(
                                    _selectedItem.value,
                                  ),
                                );
                                field.didChange(_selectedValues.toList());
                                return onChanged?.call(
                                  _selectedValues.toList(),
                                );
                              },
                            );
                          }

                          return MultiSelectedItemButton(
                            key: ValueKey(_selectedItem),
                            label: _selectedItem.label,
                            onRemove: () {
                              setState(
                                () => _selectedValues.remove(
                                  _selectedItem.value,
                                ),
                              );
                              field.didChange(_selectedValues.toList());
                              return onChanged?.call(_selectedValues.toList());
                            },
                          );
                        },
                        separatorBuilder: (_, _) {
                          return const SizedBox.square(dimension: 8);
                        },
                      ),
                    ),
              onRefresh: onRefresh,
            );
          },
        );
      },
    );
  }
}
//---------------------------Dropdown Widget---------------------------//

//---------------------------Bottom Modal Widget---------------------------//
class _MultiSelectBottomModalWidget<T, R> extends MultiSelectFormField<T, R> {
  const _MultiSelectBottomModalWidget({
    super.key,
    required super.asyncData,
    super.value,
    required super.items,
    super.onChanged,
    super.decoration,
    super.selectedItemBuilder,
    super.validator,
    super.onRefresh,
    required this.listBuilder,
  }) : super._();

  final BottomModalItemBuilder<T> listBuilder;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _decoration = decoration ?? const InputDecoration();
    Widget? _hint = _decoration.hintText == null
        ? null
        : Text(
            _decoration.hintText!,
            style: _theme.textTheme.bodyLarge
                ?.merge(_decoration.hintStyle)
                .copyWith(color: _theme.colorScheme.secondary),
          );

    return FormField<List<T>>(
      key: key,
      initialValue: value,
      validator: validator,
      builder: (field) {
        final _selectedValues = <T>{...?field.value};
        final _showSelected = _selectedValues.isNotEmpty;
        return GestureDetector(
          onTap: () async {
            final _result = await _showBottomModal(context);
            if (_result != null) {
              field.didChange(_result);
              return onChanged?.call(_result);
            }
          },
          child: InputDecorator(
            decoration: _decoration.copyWith(
              errorText: field.errorText,
            ),
            child: !_showSelected
                ? _hint
                : SizedBox.fromSize(
                    size: Size.fromHeight(48),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 12, bottom: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedValues.length,
                      itemBuilder: (_, index) {
                        final _selectedItem = items.firstWhere((it) {
                          return it.value == _selectedValues.toList().reversed.toList()[index];
                        });

                        if (selectedItemBuilder != null) {
                          return selectedItemBuilder!(
                            context,
                            _selectedItem,
                            () {
                              _selectedValues.remove(
                                _selectedItem.value,
                              );
                              field.didChange(_selectedValues.toList());
                              return onChanged?.call(
                                _selectedValues.toList(),
                              );
                            },
                          );
                        }

                        return MultiSelectedItemButton(
                          key: ValueKey(_selectedItem),
                          label: _selectedItem.label,
                          onRemove: () {
                            _selectedValues.remove(
                              _selectedItem.value,
                            );
                            field.didChange(_selectedValues.toList());
                            return onChanged?.call(_selectedValues.toList());
                          },
                        );
                      },
                      separatorBuilder: (_, _) {
                        return const SizedBox.square(dimension: 8);
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<List<T>?> _showBottomModal(BuildContext context) async {
    return await showModalBottomSheet<List<T>>(
      context: context,
      builder: (modalContext) {
        final _selectedValues = <T>{...?value};

        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQuery.sizeOf(modalContext).height * 0.65,
          ),
          child: BottomModalSheetWrapper(
            title: const TextSpan(text: 'Multi Select List'),
            child: Column(
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (_, setState) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final _item = items[index];
                          final _isSelected = _selectedValues.contains(_item.value);
                          return InkWell(
                            onTap: () {
                              setState(
                                () {
                                  _isSelected
                                      ? _selectedValues.remove(_item.value)
                                      : _selectedValues.add(_item.value as T);
                                },
                              );
                            },
                            child: listBuilder(
                              context,
                              _item,
                              _selectedValues.contains(_item.value),
                            ),
                          );
                        },
                        separatorBuilder: (c, i) {
                          return const Divider(height: 0);
                        },
                      );
                    },
                  ),
                ),

                // Action Button
                ElevatedButton(
                  onPressed: () => Navigator.of(modalContext).pop(
                    _selectedValues.toList(),
                  ),
                  child: const Text('Apply'),
                ).fMarginLTRB(16, 0, 16, 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

typedef BottomModalItemBuilder<T> =
    Widget Function(
      BuildContext context,
      CustomDropdownMenuItem<T> item,
      bool isSelected,
    );
//---------------------------Bottom Modal Widget---------------------------//
