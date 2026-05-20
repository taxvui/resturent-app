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
class ManageAttendanceView extends ConsumerStatefulWidget {
  const ManageAttendanceView({super.key, this.editModel});
  final AttendanceModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageAttendanceView> createState() => _ManageAttendanceViewState();
}

class _ManageAttendanceViewState extends _$ManageAttendanceViewState {
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

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.hrm.pageTitles.editAttendance : context.t.hrm.pageTitles.addAttendance,
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
                                label: TextSpan(text: employee.name ?? context.t.common.notAvailable),
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

              // Shift (Read-only, from selected employee)
              ValueListenableBuilder(
                valueListenable: selectedEmployeeNotifier,
                builder: (_, employee, _) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.shift}*',
                      hintText: context.t.hrm.form.hints.selectEmployeeFirst,
                    ),
                    child: Text(
                      employee?.shift?.name ?? context.t.hrm.form.hints.selectEmployeeFirst,
                      style: _theme.inputDecorationTheme.hintStyle?.copyWith(
                        color: employee?.shift != null ? Colors.black : null,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Date / Month
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

              // Time In / Time Out
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TimeFormField(
                      controller: timeInController,
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.timeIn}*',
                        hintText: context.t.hrm.form.hints.selectTimeIn,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectTimeIn,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),
                  Expanded(
                    child: TimeFormField(
                      controller: timeOutController,
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.timeOut}*',
                        hintText: context.t.hrm.form.hints.selectTimeOut,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectTimeOut,
                      ),
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
              if (ref.canSnackbar(context, PMKeys.attendance, action: _action)) {
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

abstract class _$ManageAttendanceViewState extends ConsumerState<ManageAttendanceView> {
  //----------------------Form Field Props----------------------//
  late final selectedEmployeeNotifier = ValueNotifier<EmployeeModel?>(null),
      dateController = TextEditingController(),
      timeInController = TextEditingController(),
      timeOutController = TextEditingController(),
      noteController = TextEditingController();
  //----------------------Form Field Props----------------------//

  void initEdit(AttendanceModel data) {
    selectedEmployeeNotifier.value = data.employee?.copyWith(shift: data.shift);
    dateController.text = data.date?.backSlashDateFormat ?? '';
    timeInController.text = data.timeIn?.timeFormat12Hour ?? '';
    timeOutController.text = data.timeOut?.timeFormat12Hour ?? '';
    noteController.text = data.note ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _date = dateController.text.parseDate;
      final _data = (widget.editModel ?? AttendanceModel()).copyWith(
        employee: selectedEmployeeNotifier.value,
        shift: selectedEmployeeNotifier.value?.shift,
        date: _date,
        month: _date?.getFormatedString(pattern: 'MMMM').toLowerCase(),
        timeIn: timeInController.text.parseDate,
        timeOut: timeOutController.text.parseDate,
        note: noteController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(attendanceRepoProvider).manageAttendance(_data),
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
