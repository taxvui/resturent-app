import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

export 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    this.isExpanded = true,
    this.decoration,
    this.autovalidateMode,
    this.value,
    this.onChanged,
    required this.items,
    this.validator,
    this.showClearButton = true,
    this.dropdownStyleData,
    this.buttonStyleData,
    this.onMenuStateChange,
    this.customButton,
    this.selectedItemBuilder,
  });
  final bool isExpanded;
  final InputDecoration? decoration;
  final AutovalidateMode? autovalidateMode;
  final T? value;
  final List<CustomDropdownMenuItem<T>>? items;
  final void Function(T? value)? onChanged;
  final String? Function(T? value)? validator;
  final bool showClearButton;
  final DropdownStyleData? dropdownStyleData;
  final ButtonStyleData? buttonStyleData;
  final ValueChanged<bool>? onMenuStateChange;
  final Widget? customButton;
  final List<Widget> Function(BuildContext context)? selectedItemBuilder;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _decoration = (decoration ?? const InputDecoration()).copyWith(
      contentPadding: decoration?.contentPadding ?? EdgeInsetsDirectional.only(start: 10, end: 8),
    );

    return DropdownButtonFormField2<T>(
      autovalidateMode: autovalidateMode,
      hint: _buildHint(_theme, _decoration),
      isExpanded: isExpanded,
      decoration: _decoration.copyWith(
        hintText: null,
        suffix: null,
        suffixIcon: null,
        enabled: onChanged != null,
      ),
      buttonStyleData: buttonStyleData ??
          const ButtonStyleData(
            width: double.maxFinite,
            height: kMinInteractiveDimension,
          ),
      dropdownStyleData: dropdownStyleData ?? DropdownStyleData(maxHeight: 300),
      iconStyleData: IconStyleData(
        icon: _buildSuffixIcon(context),
        openMenuIcon: const Icon(Icons.keyboard_arrow_up_rounded),
      ),
      menuItemStyleData: MenuItemStyleData(
        customHeights: [
          ...List.generate(items?.length ?? 0, (index) {
            if (items?[index]._type == _CustomDropdownMenuItemType.navigator) {
              return 38.0;
            }
            return kMinInteractiveDimension;
          })
        ],
        padding: EdgeInsets.zero,
        selectedMenuItemBuilder: (context, child) {
          return ColoredBox(
            color: _theme.colorScheme.primary.withValues(alpha: 0.15),
            child: child,
          );
        },
      ),
      selectedItemBuilder: selectedItemBuilder ??
          (context) {
            return [
              ...?items?.map(
                (e) => Text.rich(
                  e.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ];
          },
      customButton: customButton,
      value: value,
      items: items,
      onChanged: onChanged,
      onMenuStateChange: onMenuStateChange,
      validator: validator,
    );
  }

  Widget? _buildHint(ThemeData theme, InputDecoration baseDecor) {
    if (baseDecor.hintText == null) return null;
    return Text(
      baseDecor.hintText!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.inputDecorationTheme.hintStyle?.copyWith(
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    if (showClearButton && value != null) {
      return Tooltip(
        message: 'Clear',
        child: InkWell(
          onTap: () => onChanged?.call(null),
          child: Icon(
            Bootstrap.x_circle_fill,
            color: Colors.red.withValues(alpha: 0.75),
            size: 14,
          ),
        ),
      );
    }

    return const Icon(Icons.keyboard_arrow_down_rounded);
  }
}

class CustomDropdownMenuItem<T> extends DropdownMenuItem<T> {
  CustomDropdownMenuItem({
    super.key,
    required this.label,
    this.padding,
    super.alignment,
    super.enabled,
    super.onTap,
    super.value,
  })  : _type = _CustomDropdownMenuItemType.item,
        super(child: Text.rich(label));

  final InlineSpan label;
  final EdgeInsetsDirectional? padding;
  final _CustomDropdownMenuItemType _type;

  CustomDropdownMenuItem._navigator({
    required this.label,
    this.padding,
    super.alignment,
    super.enabled,
    super.onTap,
    super.value,
  })  : _type = _CustomDropdownMenuItemType.navigator,
        super(child: Text.rich(label));

  factory CustomDropdownMenuItem.navigator({
    required String label,
    required String navLabel,
    required void Function() onNavTap,
    EdgeInsetsDirectional? padding,
  }) {
    return CustomDropdownMenuItem._navigator(
      enabled: false,
      padding: padding,
      label: WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Builder(builder: (context) {
          final _theme = Theme.of(context);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  text: navLabel,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(context);
                      return onNavTap.call();
                    },
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: _theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  const CustomDropdownMenuItem.custom({
    super.key,
    super.alignment,
    super.enabled,
    super.onTap,
    super.value,
    required super.child,
    this.padding,
  })  : _type = _CustomDropdownMenuItemType.custom,
        label = const WidgetSpan(child: SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    if (_type == _CustomDropdownMenuItemType.item) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: super.build(context),
      );
    }

    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.15,
                ),
          ),
        ),
      ),
      child: super.build(context),
    );
  }
}

enum _CustomDropdownMenuItemType {
  item,
  navigator,
  custom;
}

class AsyncCustomDropdown<T, R> extends CustomDropdown<T> {
  const AsyncCustomDropdown({
    super.key,
    super.value,
    super.validator,
    super.decoration,
    super.autovalidateMode,
    super.isExpanded,
    required super.items,
    super.onChanged,
    required this.asyncData,
    super.showClearButton,
    this.onRefresh,
    super.dropdownStyleData,
    super.buttonStyleData,
    super.customButton,
    super.onMenuStateChange,
    super.selectedItemBuilder,
  });
  final AsyncValue<R> asyncData;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return asyncData.when<Widget>(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      skipError: false,
      data: (_) => super.build(context),
      error: (err, str) => _buildError(err),
      loading: () => Skeletonizer(
        child: CustomDropdown<T>(
          autovalidateMode: AutovalidateMode.disabled,
          decoration: decoration,
          items: [],
          isExpanded: isExpanded,
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return CustomDropdown<T>(
      autovalidateMode: AutovalidateMode.always,
      decoration: decoration?.copyWith(
        suffixIcon: IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
      ),
      items: [],
      validator: (_) => error.toString(),
    );
  }
}
