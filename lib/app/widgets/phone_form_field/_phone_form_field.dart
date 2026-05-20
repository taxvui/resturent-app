import 'package:flutter/material.dart';

import 'package:country_code_picker/country_code_picker.dart' show codes, CountryCode;
import 'package:fdevs_fitkit/fdevs_fitkit.dart';

export 'package:country_code_picker/country_code_picker.dart' show CountryCode;

class PhoneFormField extends TextFormField {
  PhoneFormField({
    super.key,
    super.autocorrect,
    super.autofillHints,
    super.autofocus,
    super.autovalidateMode,
    super.buildCounter,
    super.canRequestFocus,
    super.clipBehavior,
    super.contentInsertionConfiguration,
    super.contextMenuBuilder,
    super.controller,
    super.cursorColor,
    super.cursorErrorColor,
    super.cursorHeight,
    super.cursorOpacityAnimates,
    super.cursorRadius,
    super.cursorWidth,
    super.dragStartBehavior,
    super.enableIMEPersonalizedLearning,
    super.enableInteractiveSelection,
    super.enableSuggestions,
    super.enabled,
    super.expands,
    super.focusNode,
    super.forceErrorText,
    super.groupId,
    super.ignorePointers,
    super.initialValue,
    super.inputFormatters,
    super.keyboardAppearance,
    super.keyboardType,
    super.magnifierConfiguration,
    super.maxLength,
    super.maxLengthEnforcement,
    super.maxLines,
    super.minLines,
    super.mouseCursor,
    super.obscureText,
    super.obscuringCharacter,
    super.onAppPrivateCommand,
    super.onChanged,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onSaved,
    super.onTap,
    super.onTapAlwaysCalled,
    super.onTapOutside,
    super.readOnly,
    super.restorationId,
    super.stylusHandwritingEnabled,
    super.scrollController,
    super.scrollPadding,
    super.scrollPhysics,
    super.selectionControls,
    super.selectionHeightStyle,
    super.selectionWidthStyle,
    super.showCursor,
    super.smartDashesType,
    super.smartQuotesType,
    super.spellCheckConfiguration,
    super.statesController,
    super.strutStyle,
    super.style,
    super.textAlign,
    super.textAlignVertical,
    super.textCapitalization,
    super.textDirection,
    super.textInputAction,

    super.undoController,
    super.validator,
    InputDecoration? decoration,
    CountryCode? selectedCountry,
    void Function(CountryCode value)? onCountrySelect,
  }) : super(
         decoration: (decoration ?? const InputDecoration()).copyWith(
           prefixIcon: _CountryCodePicker(
             selectedCountry: selectedCountry,
             onSelect: onCountrySelect,
           ),
         ),
       );
}

class _CountryCodePicker extends StatelessWidget {
  const _CountryCodePicker({
    // ignore: unused_element_parameter
    super.key,
    this.selectedCountry,
    this.onSelect,
  });
  final CountryCode? selectedCountry;
  final void Function(CountryCode value)? onSelect;

  List<CountryCode> get elements {
    return codes.map((e) => CountryCode.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _country = selectedCountry ?? elements.firstOrNull;

    return InkWell(
      onTap: () async => await _handleBottomSheet(context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: _theme.colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(dimension: 10),
            if (_country?.flagUri != null)
              SizedBox.fromSize(
                size: const Size(32, 20),
                child: Image.asset(
                  _country!.flagUri!,
                  package: 'country_code_picker',
                ),
              ),
            if (_country?.dialCode != null) ...[const SizedBox.square(dimension: 4), Text(_country!.dialCode!)],
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ).fMarginLTRB(0, 12, 12, 12),
    );
  }

  Future<void> _handleBottomSheet(BuildContext context) async {
    final _result = await showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (popContext) {
        List<CountryCode> _filteredItems = elements;

        return StatefulBuilder(
          builder: (_, setState) {
            return Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _filteredItems = elements
                          .where(
                            (country) => country.name?.toLowerCase().contains(value.toLowerCase()) ?? false,
                          )
                          .toList();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Search Country",
                    prefixIcon: Icon(Icons.search),
                  ),
                ).fMarginSymmetric(horizontal: 16, vertical: 12),

                // Result List
                if (_filteredItems.isEmpty)
                  const Center(child: Text('No country found!'))
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (_, index) {
                        final _country = _filteredItems[index];
                        return ListTile(
                          leading: Image.asset(
                            _country.flagUri!,
                            package: 'country_code_picker',
                          ),
                          title: Text(_country.dialCode ?? ''),
                          subtitle: Text(
                            _country.toCountryStringOnly(),
                            style: Theme.of(popContext).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => Navigator.of(popContext).pop(_country),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
    if (_result != null) onSelect?.call(_result);
  }
}
