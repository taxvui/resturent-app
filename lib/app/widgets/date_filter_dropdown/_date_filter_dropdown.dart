import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart' as intl;

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../core/core.dart';
import '../custom_dropdown/_custom_dropdown.dart';

part '_month_filter_dropdown.dart';

class DropdownDateFilter extends StatefulWidget {
  const DropdownDateFilter({
    super.key,
    this.items,
    this.value,
    this.replaceDefault = false,
    this.showCustom = true,
    this.onChanged,
    this.decoration,
  }) : isFormField = false,
       inputDecoration = null;

  const DropdownDateFilter.formField({
    super.key,
    this.items,
    this.value,
    this.replaceDefault = false,
    this.showCustom = true,
    this.onChanged,
    this.inputDecoration,
  }) : isFormField = true,
       decoration = null;

  final DateFilterDropdownItem? value;
  final List<DateFilterDropdownItem>? items;
  final void Function(DateFilterDropdownItem value)? onChanged;
  final bool replaceDefault;
  final bool showCustom;
  final DropdownDateFilterDecoration? decoration;
  final bool isFormField;
  final InputDecoration? inputDecoration;

  @override
  State<DropdownDateFilter> createState() => DropdownDateFilterState();

  static final _now = DateTime.now();

  // Dynamic getters for default dropdown items
  static DateFilterDropdownItem get daily {
    return _createDefaultItem(
      startDate: _now,
      endDate: _now,
      label: t.enums.dropdownDateFilter.daily,
      key: 'daily',
    );
  }

  static DateFilterDropdownItem get weekly {
    return _createDefaultItem(
      startDate: _now.subtract(const Duration(days: 6)),
      endDate: _now,
      label: t.enums.dropdownDateFilter.weekly,
      key: 'weekly',
    );
  }

  static DateFilterDropdownItem get monthly {
    return _createDefaultItem(
      startDate: DateTime(_now.year, _now.month, 1),
      endDate: _now,
      label: t.enums.dropdownDateFilter.monthly,
      key: 'monthly',
    );
  }

  static DateFilterDropdownItem get yearly {
    return _createDefaultItem(
      startDate: DateTime(_now.year, DateTime.january, 1),
      endDate: _now,
      label: t.enums.dropdownDateFilter.yearly,
      key: 'yearly',
    );
  }

  static List<DateFilterDropdownItem> get defaultDropdownItems {
    return [
      daily,
      weekly,
      monthly,
      yearly,
    ];
  }

  static DateFilterDropdownItem _createDefaultItem({
    required DateTime startDate,
    required DateTime endDate,
    required String label,
    required String key,
  }) {
    return DateFilterDropdownItem(
      fromDate: startDate,
      toDate: endDate,
      label: label,
      key: key,
    );
  }

  static DropdownDateFilterDecoration defaultDecoration(BuildContext context) {
    final _theme = Theme.of(context);
    return DropdownDateFilterDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(4),
      selectedLabelStyle: _theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      foregroundColor: Colors.white,
      itemLabelStyle: _theme.textTheme.bodyMedium,
    );
  }

  static void setCustomDateRange({
    required GlobalKey<DropdownDateFilterState> key,
    required DateTimeRange dateRange,
  }) {
    final state = key.currentState;
    if (state == null) {
      throw Exception('DropdownDateFilter state is not available.');
    }
    state._setCustomDateRange(dateRange);
  }
}

class DropdownDateFilterState extends State<DropdownDateFilter> {
  late DateFilterDropdownItem _selectedValue;
  late List<DateFilterDropdownItem> _dropdownItems;

  @override
  void initState() {
    super.initState();
    _updateDropdownItems();
  }

  @override
  void didUpdateWidget(DropdownDateFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.items != widget.items ||
        oldWidget.replaceDefault != widget.replaceDefault ||
        oldWidget.showCustom != widget.showCustom) {
      _updateDropdownItems();
    }
  }

  void _updateDropdownItems() {
    final newItems = [
      if (!widget.replaceDefault) ...DropdownDateFilter.defaultDropdownItems,
      ...?widget.items,
      if (widget.showCustom)
        DateFilterDropdownItem.custom(
          fromDate: DateTime.now().subtract(const Duration(days: 6)),
          toDate: DateTime.now(),
          // label: 'Custom',
          label: t.enums.dropdownDateFilter.custom,
        ),
    ];

    final newValue =
        widget.value ??
        newItems.firstWhere(
          (item) => !item._isCustom,
          orElse: () => newItems.first,
        );

    setState(() {
      _dropdownItems = newItems;
      _selectedValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _items = _dropdownItems.map((range) {
      return DropdownMenuItem<DateFilterDropdownItem>(
        value: range,
        onTap: range._isCustom ? () async => await _handleCustomSelection(range) : null,
        child: Text(range.label),
      );
    }).toList();

    final _theme = Theme.of(context);
    final _buttonDecoration = widget.decoration ?? DropdownDateFilter.defaultDecoration(context);

    if (widget.isFormField) {
      return DropdownButtonFormField2<DateFilterDropdownItem>(
        decoration: widget.inputDecoration,
        buttonStyleData: const ButtonStyleData(
          width: double.maxFinite,
          height: kMinInteractiveDimension,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(FeatherIcons.chevronDown),
          iconSize: 16,
        ),
        value: _selectedValue,
        dropdownStyleData: DropdownStyleData(maxHeight: 300),
        items: _items,
        onChanged: _handleOnChanged,
      );
    }

    return DropdownButton2<DateFilterDropdownItem>(
      underline: const SizedBox.shrink(),
      alignment: Alignment.centerLeft,
      style: _buttonDecoration.itemLabelStyle,
      buttonStyleData: ButtonStyleData(
        decoration: _buttonDecoration,
        padding: _buttonDecoration.buttonPadding,
        width: _buttonDecoration.buttonWidth,
        height: _buttonDecoration.buttonHeight,
      ),
      iconStyleData: IconStyleData(
        icon: const Icon(FeatherIcons.chevronDown),
        iconEnabledColor: _buttonDecoration.foregroundColor,
        iconSize: 16,
      ),
      value: _selectedValue,
      selectedItemBuilder: (context) {
        return [
          ..._dropdownItems.map(
            (range) {
              return Center(
                child: Text(
                  range.label,
                  style: _buttonDecoration.selectedLabelStyle,
                ),
              );
            },
          ),
        ];
      },
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: _buttonDecoration.color ?? _theme.colorScheme.surface,
        ),
        width: _buttonDecoration.menuWidth,
        maxHeight: _buttonDecoration.menuMaxHeight,
      ),
      items: _items,
      onChanged: _handleOnChanged,
    );
  }

  void _handleOnChanged(DateFilterDropdownItem? value) {
    if (value == null || value._isCustom) return;
    _updateSelection(value);
  }

  Future<void> _handleCustomSelection(DateFilterDropdownItem customItem) async {
    final previousValue = _selectedValue;
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: customItem.fromDate,
        end: customItem.toDate,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            rangeSelectionBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      final newItem = DateFilterDropdownItem.custom(
        fromDate: dateRange.start,
        toDate: dateRange.end,
        label: t.enums.dropdownDateFilter.custom,
        // label: 'Custom',
      );

      setState(() {
        _dropdownItems = _dropdownItems.map((item) {
          return item._isCustom ? newItem : item;
        }).toList();
        _selectedValue = newItem;
      });

      widget.onChanged?.call(newItem);
    } else {
      _updateSelection(previousValue);
    }
  }

  void _updateSelection(DateFilterDropdownItem value) {
    setState(() => _selectedValue = value);
    widget.onChanged?.call(value);
  }

  void _setCustomDateRange(DateTimeRange customRange) {
    final newItem = DateFilterDropdownItem.custom(
      fromDate: customRange.start,
      toDate: customRange.end,
      label: t.enums.dropdownDateFilter.custom,
      // label: 'Custom',
    );

    setState(() {
      _dropdownItems = _dropdownItems.map((item) {
        return item._isCustom ? newItem : item;
      }).toList();
      _selectedValue = newItem;
    });

    widget.onChanged?.call(newItem);
  }
}

class DateFilterDropdownItem {
  final DateTime fromDate;
  final DateTime toDate;
  final String label;
  final bool _isCustom;
  final String key;

  DateFilterDropdownItem({
    required this.fromDate,
    required this.toDate,
    required this.label,
    required this.key,
  }) : _isCustom = false;

  factory DateFilterDropdownItem.custom({
    required DateTime fromDate,
    required DateTime toDate,
    required String label,
  }) {
    return DateFilterDropdownItem._(
      fromDate: fromDate,
      toDate: toDate,
      label: label,
      isCustom: true,
      key: 'custom',
    );
  }

  const DateFilterDropdownItem._({
    required this.fromDate,
    required this.toDate,
    required this.label,
    required bool isCustom,
    required this.key,
  }) : _isCustom = isCustom;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;

    return other is DateFilterDropdownItem && other.key == key && other._isCustom == _isCustom;
  }

  @override
  int get hashCode {
    return Object.hash(key, _isCustom);
  }

  @override
  String toString() {
    return 'DateFilterDropdownItem(startDate: $fromDate, endDate: $toDate, label: $label, _isCustom:$_isCustom)';
  }
}

class DropdownDateFilterDecoration extends BoxDecoration {
  const DropdownDateFilterDecoration({
    super.backgroundBlendMode,
    super.border,
    super.borderRadius,
    super.color,
    super.boxShadow,
    super.gradient,
    super.image,
    super.shape,
    this.buttonWidth,
    this.buttonHeight,
    this.menuWidth,
    this.menuMaxHeight,
    this.buttonPadding = const EdgeInsetsDirectional.only(end: 10),
    this.foregroundColor,
    this.selectedLabelStyle,
    this.itemLabelStyle,
  });
  final double? buttonWidth;
  final double? buttonHeight;
  final double? menuWidth;
  final double? menuMaxHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final Color? foregroundColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? itemLabelStyle;

  @override
  DropdownDateFilterDecoration copyWith({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
    double? buttonWidth,
    double? buttonHeight,
    double? menuWidth,
    double? menuMaxHeight,
    EdgeInsetsGeometry? buttonPadding,
    Color? foregroundColor,
    TextStyle? selectedLabelStyle,
    TextStyle? itemLabelStyle,
  }) {
    return DropdownDateFilterDecoration(
      color: color ?? this.color,
      image: image ?? this.image,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      shape: shape ?? this.shape,
      buttonWidth: buttonWidth ?? this.buttonWidth,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      menuWidth: menuWidth ?? this.menuWidth,
      menuMaxHeight: menuWidth ?? this.menuMaxHeight,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      itemLabelStyle: itemLabelStyle ?? this.itemLabelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
    );
  }
}

class DateFilterRow extends StatelessWidget {
  const DateFilterRow({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final DateFilterRowData value;
  final ValueChanged<DateFilterRowData> onChanged;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _dropdownDecoration = DropdownDateFilter.defaultDecoration(context);
    final _borderColor = _theme.colorScheme.secondary.withValues(alpha: 0.25);

    final _dropdownKey = GlobalKey<DropdownDateFilterState>();

    return Container(
      constraints: BoxConstraints(maxHeight: 48),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor, width: 1.25)),
      ),
      child: Row(
        children: [
          const SizedBox.square(dimension: 16),
          Flexible(
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  IconlyLight.calendar,
                  size: 24,
                  color: _theme.colorScheme.secondary,
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: value.dateRange.start.getFormatedString(pattern: 'dd-MM-yyyy'),
                      children: [
                        TextSpan(
                          text: '  ${context.t.common.to}  ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async => await _pickDateRange(
                              context,
                              _dropdownKey,
                            ),
                        ),
                        TextSpan(
                          text: value.dateRange.end.getFormatedString(pattern: 'dd-MM-yyyy'),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async => await _pickDateRange(
                              context,
                              _dropdownKey,
                            ),
                        ),
                      ],
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async => await _pickDateRange(
                          context,
                          _dropdownKey,
                        ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1.25),

          // Quick Filter Selector
          DropdownDateFilter(
            key: _dropdownKey,
            showCustom: true,
            decoration: _dropdownDecoration.copyWith(
              border: const Border(),
              foregroundColor: _theme.colorScheme.secondary,
              selectedLabelStyle: _dropdownDecoration.selectedLabelStyle?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
            value: value.value,
            onChanged: (v) {
              return onChanged(
                value.copyWith(
                  value: v,
                  dateRange: DateTimeRange(
                    start: v.fromDate,
                    end: v.toDate,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    GlobalKey<DropdownDateFilterState> dropdownKey,
  ) async {
    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: value.dateRange.start,
        end: value.dateRange.end,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return DatePickerTheme(
          data: DatePickerThemeData(
            rangeSelectionBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      onChanged(value.copyWith(dateRange: dateRange));
      DropdownDateFilter.setCustomDateRange(
        key: dropdownKey,
        dateRange: dateRange,
      );
    }
  }
}

class DateFilterRowData {
  final DateFilterDropdownItem value;
  final DateTimeRange dateRange;

  DateFilterRowData({
    DateFilterDropdownItem? value,
    DateTimeRange? dateRange,
  }) : value = value ?? DropdownDateFilter.daily,
       dateRange =
           dateRange ??
           DateTimeRange(
             start: DateTime.now(),
             end: DateTime.now(),
           );

  DateFilterRowData copyWith({
    DateFilterDropdownItem? value,
    DateTimeRange? dateRange,
  }) {
    return DateFilterRowData(
      value: value ?? this.value,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DateFilterRowData &&
            runtimeType == other.runtimeType &&
            value == other.value &&
            dateRange == other.dateRange;
  }

  @override
  int get hashCode => Object.hash(value, dateRange);
  @override
  String toString() => 'DateFilterRowData(value: $value, dateRange: $dateRange)';
}
