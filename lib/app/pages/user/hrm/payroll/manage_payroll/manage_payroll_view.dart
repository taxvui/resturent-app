import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ManagePayrollView extends ConsumerStatefulWidget {
  const ManagePayrollView({super.key, this.editModel});
  final PayrollModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManagePayrollView> createState() => _ManagePayrollViewState();
}

class _ManagePayrollViewState extends _$ManagePayrollViewState {
  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final employeeDropdownAsync = ref.watch(employeeDropdownProvider);
    final paymentMethodAsync = ref.watch(businessPaymentMethodDropdownProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.hrm.pageTitles.editPayroll : context.t.hrm.pageTitles.addPayroll,
            ),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Employee
              ValueListenableBuilder<EmployeeModel?>(
                valueListenable: selectedEmployeeNotifier,
                builder: (_, value, _) {
                  return AsyncCustomDropdown<EmployeeModel?, EmployeeListModel>(
                    asyncData: employeeDropdownAsync,
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.employee}*',
                      hintText: context.t.hrm.form.hints.selectEmployee,
                    ),
                    value: value,
                    items: employeeDropdownAsync.when(
                      data: (data) {
                        return [
                          CustomDropdownMenuItem.navigator(
                            label: context.t.hrm.form.hints.selectEmployee,
                            navLabel: context.t.hrm.dropdowns.addNew,
                            onNavTap: () async {
                              if (ref.canSnackbar(context, PMKeys.employee, action: PermissionAction.create)) {
                                final _result = await context.router.push<EmployeeModel>(
                                  ManageEmployeeRoute(),
                                );
                                if (_result != null) {
                                  return selectedEmployeeNotifier.set(_result);
                                }
                              }
                            },
                          ),
                          ...?data.data?.data?.map(
                            (employee) {
                              return CustomDropdownMenuItem(
                                value: employee,
                                label: TextSpan(text: employee.name ?? "N/A"),
                              );
                            },
                          ),
                        ];
                      },
                      error: (_, _) => [],
                      loading: () => [],
                    ),
                    onChanged: selectedEmployeeNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectEmployee,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Payment Year
              ValueListenableBuilder<int?>(
                valueListenable: selectedYearNotifier,
                builder: (_, value, _) {
                  return YearFormField(
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.paymentYear}*',
                      hintText: context.t.hrm.form.hints.selectYear,
                    ),
                    initialValue: value,
                    onChanged: selectedYearNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectPaymentYear,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Month / Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DateFormField(
                      controller: dateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.common.date}*',
                        hintText: context.t.hrm.form.hints.selectDate,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectDate,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: dateController,
                      builder: (_, value, _) {
                        final _date = value.text.parseDate;
                        return InputDecorator(
                          decoration: InputDecoration(labelText: '${context.t.hrm.form.labels.month}*'),
                          child: Text(
                            _date?.getFormatedString(pattern: 'MMMM') ?? context.t.hrm.form.hints.selectMonth,
                            style: _theme.inputDecorationTheme.hintStyle?.copyWith(
                              color: _date == null ? null : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Amount / Payment Type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: selectedEmployeeNotifier,
                      builder: (_, selectedEmployee, _) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: '${context.t.hrm.form.labels.amount}*',
                          ),
                          child: Text(
                            selectedEmployee?.salary?.quickCurrency() ?? context.t.hrm.form.hints.enterSalary,
                            style: _theme.inputDecorationTheme.hintStyle?.copyWith(
                              color: selectedEmployee == null ? null : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox.square(dimension: 12),
                  Expanded(
                    child: ValueListenableBuilder<BusinessPaymentMethod?>(
                      valueListenable: selectedPaymentTypeNotifier,
                      builder: (_, value, _) {
                        return AsyncCustomDropdown<BusinessPaymentMethod?, BusinessPaymentMethodList>(
                          asyncData: paymentMethodAsync,
                          showClearButton: false,
                          decoration: InputDecoration(
                            labelText: '${context.t.hrm.form.labels.paymentType}*',
                            hintText: context.t.hrm.form.hints.selectPaymentType,
                          ),
                          value: value,
                          items: paymentMethodAsync.when(
                            data: (data) {
                              return [
                                ...?data.data?.data?.map(
                                  (method) {
                                    return CustomDropdownMenuItem(
                                      value: method,
                                      label: TextSpan(text: method.name ?? "N/A"),
                                    );
                                  },
                                ),
                              ];
                            },
                            error: (_, _) => [],
                            loading: () => [],
                          ),
                          onChanged: selectedPaymentTypeNotifier.set,
                          validator: FormBuilderValidators.required(
                            errorText: context.t.hrm.validation.selectPaymentType,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Note
              TextFormField(
                controller: noteController,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  labelText: context.t.common.note,
                  hintText: context.t.hrm.form.hints.enterDescription,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              final _action = widget.isEditMode ? PermissionAction.update : PermissionAction.create;
              if (ref.canSnackbar(context, PMKeys.payroll, action: _action)) {
                if (FormWrapper.validate(formContext)) {
                  return handleFormSubmit(context);
                }
              }
            },
            child: Text(context.t.action.save),
          ).fMarginLTRB(16, 12, 16, 16),
        );
      },
    ).unfocusPrimary();
  }
}

abstract class _$ManagePayrollViewState extends ConsumerState<ManagePayrollView> {
  //----------------------Form Field Props----------------------//
  late final selectedEmployeeNotifier = ValueNotifier<EmployeeModel?>(null),
      selectedYearNotifier = ValueNotifier<int?>(null),
      dateController = TextEditingController(),
      selectedPaymentTypeNotifier = ValueNotifier<BusinessPaymentMethod?>(null),
      noteController = TextEditingController();
  //----------------------Form Field Props----------------------//

  void initEdit(PayrollModel data) {
    selectedEmployeeNotifier.value = data.employee?.copyWith(salary: data.amount);
    selectedYearNotifier.value = int.tryParse(data.paymentYear ?? '');
    dateController.text = data.date?.backSlashDateFormat ?? '';
    selectedPaymentTypeNotifier.value = data.paymentType;
    noteController.text = data.note ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _date = dateController.text.parseDate;
      final _data = (widget.editModel ?? PayrollModel()).copyWith(
        employee: selectedEmployeeNotifier.value,
        paymentYear: selectedYearNotifier.value?.toString(),
        date: _date,
        month: _date?.getFormatedString(pattern: 'MMMM').toLowerCase(),
        amount: selectedEmployeeNotifier.value?.salary,
        paymentType: selectedPaymentTypeNotifier.value,
        note: noteController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(payrollRepoProvider).managePayroll(_data),
        ),
      );

      if (context.mounted) {
        context.router.maybePop(_result);
        return;
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }
}
