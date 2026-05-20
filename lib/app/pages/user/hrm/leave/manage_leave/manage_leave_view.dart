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
class ManageLeaveView extends ConsumerStatefulWidget {
  const ManageLeaveView({super.key, this.editModel});
  final LeaveModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageLeaveView> createState() => _ManageLeaveViewState();
}

class _ManageLeaveViewState extends _$ManageLeaveViewState {
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
    final leaveTypeAsync = ref.watch(leaveTypeDropdownProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.hrm.pageTitles.editLeave : context.t.hrm.pageTitles.addLeave,
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
                            (employee) => CustomDropdownMenuItem(
                              value: employee,
                              label: TextSpan(text: employee.name ?? context.t.common.notAvailable),
                            ),
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

              // Department (Read-only, auto-populated)
              ValueListenableBuilder(
                valueListenable: selectedEmployeeNotifier,
                builder: (_, employee, _) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.department}*',
                      hintText: context.t.hrm.form.hints.selectEmployeeFirst,
                    ),
                    child: Text(
                      employee?.department?.name ?? context.t.hrm.form.hints.selectEmployeeFirst,
                      style: _theme.inputDecorationTheme.hintStyle?.copyWith(
                        color: employee?.department != null ? Colors.black : null,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Leave Type
              ValueListenableBuilder<LeaveTypeModel?>(
                valueListenable: selectedLeaveTypeNotifier,
                builder: (_, value, _) {
                  return AsyncCustomDropdown<LeaveTypeModel?, LeaveTypeListModel>(
                    asyncData: leaveTypeAsync,
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.leaveType}*',
                      hintText: context.t.hrm.form.hints.selectLeaveType,
                    ),
                    value: value,
                    items: leaveTypeAsync.when(
                      data: (data) {
                        return [
                          CustomDropdownMenuItem.navigator(
                            label: context.t.hrm.form.hints.selectLeaveType,
                            navLabel: context.t.hrm.dropdowns.addNew,
                            onNavTap: () async {
                              if (ref.canSnackbar(context, PMKeys.leaveType, action: PermissionAction.create)) {
                                final _result = await context.router.push<LeaveTypeModel>(
                                  ManageLeaveTypeRoute(),
                                );
                                if (_result != null) {
                                  return selectedLeaveTypeNotifier.set(_result);
                                }
                              }
                            },
                          ),
                          ...?data.data?.data?.map(
                            (leaveType) => CustomDropdownMenuItem(
                              value: leaveType,
                              label: TextSpan(text: leaveType.name ?? context.t.common.notAvailable),
                            ),
                          ),
                        ];
                      },
                      error: (_, _) => [],
                      loading: () => [],
                    ),
                    onChanged: selectedLeaveTypeNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectLeaveType,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Month
              ValueListenableBuilder<String?>(
                valueListenable: selectedMonthNotifier,
                builder: (_, value, _) {
                  return MonthFilterDropdown(
                    showAllMonthsOption: false,
                    value: value,
                    onChanged: selectedMonthNotifier.set,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.month}*',
                      hintText: context.t.hrm.form.hints.selectMonth,
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectMonth,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date
                  Expanded(
                    child: DateFormField(
                      controller: startDateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.startDate}*',
                        hintText: context.t.hrm.form.hints.selectStartDate,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectStartDate,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),

                  // End Date
                  Expanded(
                    child: DateFormField(
                      controller: endDateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.endDate}*',
                        hintText: context.t.hrm.form.hints.selectEndDate,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return context.t.hrm.validation.selectEndDate;
                        }
                        final start = startDateController.text.parseDate;
                        final end = value?.parseDate;
                        if (start != null && end != null && end.isBefore(start)) {
                          return context.t.hrm.validation.endDateAfterStart;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leave Duration (Read-only, auto-calculated)
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: startDateController,
                      builder: (_, _, _) {
                        return ValueListenableBuilder(
                          valueListenable: endDateController,
                          builder: (_, _, _) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: '${context.t.hrm.form.labels.leaveDuration}*',
                                hintText: context.t.hrm.form.hints.autoCalculated,
                              ),
                              child: Text(
                                leaveDuration != null && leaveDuration! > 0
                                    ? '$leaveDuration ${context.t.hrm.units.days}'
                                    : context.t.hrm.form.hints.selectDatesFirst,
                                style: _theme.inputDecorationTheme.hintStyle?.copyWith(
                                  color: leaveDuration != null ? Colors.black : null,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox.square(dimension: 12),

                  // Status
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: selectedStatusNotifier,
                      builder: (_, value, _) {
                        return CustomDropdown<String>(
                          showClearButton: false,
                          decoration: InputDecoration(
                            labelText: '${context.t.hrm.form.labels.status}*',
                            hintText: context.t.hrm.form.hints.selectStatus,
                          ),
                          value: value,
                          items:
                              [
                                (label: context.t.hrm.dropdowns.pending, value: "pending"),
                                (label: context.t.hrm.dropdowns.approved, value: "approved"),
                                (label: context.t.hrm.dropdowns.rejected, value: "rejected"),
                              ].map((entry) {
                                return CustomDropdownMenuItem(
                                  value: entry.value,
                                  label: TextSpan(text: entry.label),
                                );
                              }).toList(),
                          onChanged: (v) => selectedStatusNotifier.set(v!),
                          validator: FormBuilderValidators.required(
                            errorText: context.t.hrm.validation.selectStatus,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  labelText: context.t.hrm.form.labels.description,
                  hintText: context.t.hrm.form.hints.enterDescription,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              final _action = widget.isEditMode ? PermissionAction.update : PermissionAction.create;
              if (ref.canSnackbar(context, PMKeys.leave, action: _action)) {
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

abstract class _$ManageLeaveViewState extends ConsumerState<ManageLeaveView> {
  //----------------------Form Field Props----------------------//
  late final selectedEmployeeNotifier = ValueNotifier<EmployeeModel?>(null),
      selectedLeaveTypeNotifier = ValueNotifier<LeaveTypeModel?>(null),
      selectedMonthNotifier = ValueNotifier<String?>(null),
      startDateController = TextEditingController(),
      endDateController = TextEditingController(),
      selectedStatusNotifier = ValueNotifier<String>('pending'),
      descriptionController = TextEditingController();

  int? get leaveDuration {
    final _startDate = startDateController.text.parseDate;
    final _endDate = endDateController.text.parseDate;
    return (_startDate != null && _endDate != null) ? _endDate.difference(_startDate).inDays + 1 : null;
  }
  //----------------------Form Field Props----------------------//

  void initEdit(LeaveModel data) {
    selectedEmployeeNotifier.value = data.employee;
    selectedLeaveTypeNotifier.value = data.leaveType;
    selectedMonthNotifier.value = data.month?.trim().toLowerCase();
    startDateController.text = data.startDate?.backSlashDateFormat ?? '';
    endDateController.text = data.endDate?.backSlashDateFormat ?? '';
    selectedStatusNotifier.value = data.status ?? 'pending';
    descriptionController.text = data.description ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? LeaveModel()).copyWith(
        employee: selectedEmployeeNotifier.value,
        leaveType: selectedLeaveTypeNotifier.value,
        month: selectedMonthNotifier.value?.toLowerCase(),
        startDate: startDateController.text.parseDate,
        endDate: endDateController.text.parseDate,
        leaveDuration: leaveDuration,
        status: selectedStatusNotifier.value.toLowerCase(),
        description: descriptionController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(leaveRepoProvider).manageLeave(_data),
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
