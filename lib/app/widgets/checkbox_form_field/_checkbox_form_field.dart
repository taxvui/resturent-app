import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    required Widget title,
    required bool super.initialValue,
    super.onSaved,
    super.validator,
    bool autovalidate = false,
    bool tristate = false,
  }) : super(
          autovalidateMode: autovalidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          builder: (field) {
            return Builder(
              builder: (context) {
                final _theme = Theme.of(context);
                return CheckboxListTile(
                  value: field.value,
                  tristate: tristate,
                  onChanged: field.didChange,
                  title: title,
                  subtitle: field.hasError
                      ? Text(
                          field.errorText ?? '',
                          style: _theme.inputDecorationTheme.errorStyle,
                        )
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            );
          },
        );
}
