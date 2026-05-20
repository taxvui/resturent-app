part of '_date_filter_dropdown.dart';

class MonthFilterDropdown extends StatelessWidget {
  const MonthFilterDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.decoration,
    this.hintText,
    this.showAllMonthsOption = true,
    this.validator,
  });

  final String? value;
  final void Function(String? value)? onChanged;
  final InputDecoration? decoration;
  final String? hintText;
  final bool showAllMonthsOption;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: value,
      decoration: decoration ?? InputDecoration(hintText: hintText ?? context.t.$wip('Select Month')),
      items: [
        if (showAllMonthsOption) ...[
          CustomDropdownMenuItem<String>(
            value: null,
            label: TextSpan(text: context.t.$wip('All Months')),
          ),
        ],

        ...intl.DateFormat('MMMM').dateSymbols.MONTHS.map((month) {
          return CustomDropdownMenuItem<String>(
            value: month.trim().toLowerCase(),
            label: TextSpan(text: month),
          );
        }),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
