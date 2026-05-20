import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:universal_image/universal_image.dart';
import 'package:iconly/iconly.dart';

import '../../core/core.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.decoration,
    this.controller,
    this.onChanged,
    this.appliedFilterCount = 0,
    this.onTapFilter,
  });

  final CustomSearchFieldDecoration? decoration;
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final int appliedFilterCount;
  final VoidCallback? onTapFilter;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    // ignore: unused_local_variable
    Widget? _clearButton;
    if (controller != null) {
      _clearButton = ValueListenableBuilder(
        valueListenable: controller!,
        builder: (_, value, child) {
          if (value.text.isEmpty) {
            return const SizedBox.square();
          }

          return child!;
        },
        child: SizedBox.square(
          dimension: 44,
          child: IconButton(
            icon: const CloseButtonIcon(),
            onPressed: () {
              controller?.clear();
              onChanged?.call('');
            },
            style: IconButton.styleFrom(
              iconSize: 18,
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
            ),
          ),
        ),
      );
    }

    final _decoration = (decoration ?? const CustomSearchFieldDecoration()).copyWith(
      prefixIcon:
          decoration?.prefixIcon ??
          Icon(
            FeatherIcons.search,
            size: 20,
            color: _theme.colorScheme.secondary,
          ),
      suffixIcon:
          decoration?.suffixIcon ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?_clearButton,
              if (onTapFilter != null)
                IconButton.filled(
                  onPressed: onTapFilter,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.horizontal(
                        end: const Radius.circular(4),
                      ),
                      side: BorderSide.none,
                    ),
                    backgroundColor: _theme.colorScheme.primary.withValues(
                      alpha: 0.0725,
                    ),
                    foregroundColor: _theme.colorScheme.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.fromWidth(46),
                  ),
                  icon: Badge.count(
                    count: appliedFilterCount,
                    alignment: AlignmentDirectional(2.25, -1.25),
                    isLabelVisible: appliedFilterCount > 0,
                    backgroundColor: _theme.colorScheme.primary,
                    textColor: _theme.colorScheme.onPrimary,
                    child: UniversalImage(
                      DAppSvgIcons.sliders.svgPath,
                      colorFilter: ColorFilter.mode(
                        _theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              controller: controller,
              decoration: _decoration,
              onChanged: onChanged,
            ),
          ),

          // Action Buttons,
          ...?decoration?.actions,
        ],
      ),
    );
  }
}

class CustomSearchFieldDecoration extends InputDecoration {
  const CustomSearchFieldDecoration({
    super.labelText,
    super.hintText,
    super.prefixIcon,
    super.suffixIcon,
    super.icon,
    super.iconColor,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed,
    super.isDense,
    super.contentPadding,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconConstraints,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.filled = true,
    super.fillColor = Colors.white,
    super.focusColor,
    super.hoverColor,
    super.errorBorder,
    super.focusedBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.enabledBorder,
    super.border,
    super.enabled,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
    super.error,
    super.label,
    super.hint,
    super.helper,
    super.hintFadeDuration,
    super.hintMaxLines,
    super.hintStyle,
    super.hintTextDirection,
    super.prefixIconColor,
    super.suffixIconColor,
    super.maintainHintSize,
    super.maintainLabelSize,
    super.visualDensity,
    this.actions,
  });

  final List<Widget>? actions;

  @override
  CustomSearchFieldDecoration copyWith({
    Widget? icon,
    Color? iconColor,
    Widget? label,
    String? labelText,
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    Widget? helper,
    String? helperText,
    TextStyle? helperStyle,
    int? helperMaxLines,
    String? hintText,
    Widget? hint,
    TextStyle? hintStyle,
    TextDirection? hintTextDirection,
    Duration? hintFadeDuration,
    int? hintMaxLines,
    bool? maintainHintHeight,
    bool? maintainHintSize,
    bool? maintainLabelSize,
    Widget? error,
    String? errorText,
    TextStyle? errorStyle,
    int? errorMaxLines,
    FloatingLabelBehavior? floatingLabelBehavior,
    FloatingLabelAlignment? floatingLabelAlignment,
    bool? isCollapsed,
    bool? isDense,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefixIcon,
    Widget? prefix,
    String? prefixText,
    BoxConstraints? prefixIconConstraints,
    TextStyle? prefixStyle,
    Color? prefixIconColor,
    Widget? suffixIcon,
    Widget? suffix,
    String? suffixText,
    TextStyle? suffixStyle,
    Color? suffixIconColor,
    BoxConstraints? suffixIconConstraints,
    Widget? counter,
    String? counterText,
    TextStyle? counterStyle,
    bool? filled,
    Color? fillColor,
    Color? focusColor,
    Color? hoverColor,
    InputBorder? errorBorder,
    InputBorder? focusedBorder,
    InputBorder? focusedErrorBorder,
    InputBorder? disabledBorder,
    InputBorder? enabledBorder,
    InputBorder? border,
    bool? enabled,
    String? semanticCounterText,
    bool? alignLabelWithHint,
    BoxConstraints? constraints,
    VisualDensity? visualDensity,
    SemanticsService? semanticsService,
    List<Widget>? actions,
  }) {
    return CustomSearchFieldDecoration(
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      label: label ?? this.label,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      helper: helper ?? this.helper,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      helperMaxLines: helperMaxLines ?? this.helperMaxLines,
      hintText: hintText ?? this.hintText,
      hint: hint ?? this.hint,
      hintStyle: hintStyle ?? this.hintStyle,
      hintTextDirection: hintTextDirection ?? this.hintTextDirection,
      hintFadeDuration: hintFadeDuration ?? this.hintFadeDuration,
      hintMaxLines: hintMaxLines ?? this.hintMaxLines,
      maintainHintSize: maintainHintSize ?? this.maintainHintSize,
      maintainLabelSize: maintainLabelSize ?? this.maintainLabelSize,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      errorStyle: errorStyle ?? this.errorStyle,
      errorMaxLines: errorMaxLines ?? this.errorMaxLines,
      floatingLabelBehavior: floatingLabelBehavior ?? this.floatingLabelBehavior,
      floatingLabelAlignment: floatingLabelAlignment ?? this.floatingLabelAlignment,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isDense: isDense ?? this.isDense,
      contentPadding: contentPadding ?? this.contentPadding,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefix: prefix ?? this.prefix,
      prefixText: prefixText ?? this.prefixText,
      prefixIconConstraints: prefixIconConstraints ?? this.prefixIconConstraints,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      suffix: suffix ?? this.suffix,
      suffixText: suffixText ?? this.suffixText,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      suffixIconConstraints: suffixIconConstraints ?? this.suffixIconConstraints,
      counter: counter ?? this.counter,
      counterText: counterText ?? this.counterText,
      counterStyle: counterStyle ?? this.counterStyle,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      errorBorder: errorBorder ?? this.errorBorder,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      border: border ?? this.border,
      enabled: enabled ?? this.enabled,
      semanticCounterText: semanticCounterText ?? this.semanticCounterText,
      alignLabelWithHint: alignLabelWithHint ?? this.alignLabelWithHint,
      constraints: constraints ?? this.constraints,
      visualDensity: visualDensity ?? this.visualDensity,
      actions: actions ?? this.actions,
    );
  }
}

class CustomSearchFieldActionButton extends StatelessWidget {
  const CustomSearchFieldActionButton._({
    super.key,
    required this.icon,
    this.onPressed,
    this.style,
    this.isFilled = false,
  });

  final Widget icon;
  final void Function()? onPressed;
  final ButtonStyle? style;
  final bool isFilled;

  CustomSearchFieldActionButton.pdf({
    Key? key,
    void Function()? onPressed,
    Color? iconColor,
    ButtonStyle? style,
  }) : this._(
         key: key,
         icon: Builder(
           builder: (context) {
             return UniversalImage(
               DAppSvgIcons.pdf.svgPath,
               colorFilter: ColorFilter.mode(iconColor ?? Theme.of(context).colorScheme.primary, BlendMode.srcIn),
             );
           },
         ),
         onPressed: onPressed,
         style: style,
       );

  CustomSearchFieldActionButton.print({
    Key? key,
    void Function()? onPressed,
    Color? iconColor,
    ButtonStyle? style,
  }) : this._(
         key: key,
         icon: Builder(
           builder: (context) {
             return UniversalImage(
               DAppSvgNavIcons.printingOption.svgPath,
               colorFilter: ColorFilter.mode(iconColor ?? Theme.of(context).colorScheme.primary, BlendMode.srcIn),
             );
           },
         ),
         onPressed: onPressed,
         style: style,
       );

  /*
  CustomSearchFieldActionButton.filter({
    Key? key,
    void Function()? onPressed,
    int? appliedFilters,
  }) : this._(
          key: key,
          icon: Builder(
            builder: (context) {
              final _theme = Theme.of(context);
              const _icon = Icon(Bootstrap.funnel);
              if (appliedFilters == null || appliedFilters <= 0) {
                return _icon;
              }
              final _showMore = appliedFilters > 9;

              return Badge(
                label: Text(
                  "${_showMore ? '9+' : appliedFilters}",
                  style: _theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _theme.scaffoldBackgroundColor,
                textColor: _theme.colorScheme.onPrimaryContainer,
                alignment: _showMore
                    ? const Alignment(0, -1)
                    : AlignmentDirectional.topEnd,
                child: _icon,
              );
            },
          ),
          onPressed: onPressed,
          isFilled: true,
        );
  */
  const CustomSearchFieldActionButton.barcodeScan({
    Key? key,
    void Function()? onPressed,
  }) : this._(
         key: key,
         icon: const Icon(IconlyBold.scan),
         onPressed: onPressed,
         isFilled: true,
       );

  const CustomSearchFieldActionButton.custom({
    Key? key,
    void Function()? onPressed,
    required Widget icon,
    ButtonStyle? style,
    bool filled = false,
  }) : this._(
         key: key,
         icon: icon,
         onPressed: onPressed,
         style: style,
         isFilled: filled,
       );

  static BorderRadiusGeometry defaultBorderRadius = BorderRadius.circular(4);
  static ButtonStyle defaultStyle(
    BuildContext context, {
    bool isFilled = false,
  }) {
    final _theme = Theme.of(context);
    return IconButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
      minimumSize: const Size.square(44),
      backgroundColor: isFilled ? _theme.colorScheme.primary : null,
      side: isFilled
          ? null
          : BorderSide(
              color: _theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
    );
  }

  static ButtonStyle themeColored(
    BuildContext context, {
    bool isFilled = false,
  }) {
    final _theme = Theme.of(context);

    return IconButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
      minimumSize: const Size.square(44),
      backgroundColor: isFilled ? _theme.colorScheme.primary : null,
      foregroundColor: isFilled ? _theme.colorScheme.onPrimary : _theme.colorScheme.primary,
      side: isFilled
          ? BorderSide.none
          : BorderSide(
              color: _theme.colorScheme.primary,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _buttonStyle = style ?? defaultStyle(context, isFilled: isFilled);

    if (isFilled) {
      return IconButton.filledTonal(
        onPressed: onPressed,
        style: _buttonStyle,
        icon: icon,
      );
    }

    return IconButton.outlined(
      onPressed: onPressed,
      style: _buttonStyle,
      icon: icon,
    );
  }
}
