import 'package:flutter/material.dart';

class YearFormField extends FormField<int> {
  YearFormField({
    super.key,
    this.decoration,
    this.firstYear = 1950,
    this.lastYear = 2050,
    super.validator,
    super.initialValue,
    this.onChanged,
  }) : super(
         builder: (field) {
           return Builder(
             builder: (context) {
               final _theme = Theme.of(context);
               return GestureDetector(
                 onTap: () => _showYearPicker(context, field),
                 child: InputDecorator(
                   decoration: (decoration ?? const InputDecoration()).copyWith(
                     errorText: decoration?.errorText ?? field.errorText,
                   ),
                   child: Text(
                     field.value?.toString() ?? (decoration?.hintText ?? 'Select Year'),
                     style: _theme.textTheme.bodyLarge?.copyWith(
                       color: field.value == null ? _theme.hintColor : null,
                     ),
                   ),
                 ),
               );
             },
           );
         },
       );

  final InputDecoration? decoration;
  final int firstYear;
  final int lastYear;
  final ValueChanged<int>? onChanged;

  static Future<void> _showYearPicker(BuildContext context, FormFieldState<int> field) async {
    final _yearFormField = field.widget as YearFormField;

    final _selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext popContext) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox.fromSize(
            size: const Size.square(300),
            child: YearPicker(
              firstDate: DateTime(_yearFormField.firstYear),
              lastDate: DateTime(_yearFormField.lastYear),
              selectedDate: DateTime(field.value ?? DateTime.now().year),
              onChanged: (value) => Navigator.of(popContext).pop(value.year),
            ),
          ),
        );
      },
    );

    if (_selectedYear != null) {
      field.didChange(_selectedYear);
      _yearFormField.onChanged?.call(_selectedYear);
    }
  }
}
