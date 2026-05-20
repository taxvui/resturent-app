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
class ManageEmployeeView extends ConsumerStatefulWidget {
  const ManageEmployeeView({super.key, this.editModel});
  final EmployeeModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageEmployeeView> createState() => _ManageEmployeeViewState();
}

class _ManageEmployeeViewState extends _$ManageEmployeeViewState {
  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final designationDropdownAsync = ref.watch(designationDropdownProvider);
    final departmentDropdownAsync = ref.watch(departmentDropdownProvider);
    final shiftDropdownAsync = ref.watch(shiftDropdownProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.hrm.pageTitles.editEmployee : context.t.hrm.pageTitles.addEmployee,
            ),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Image Section
              Text(
                context.t.hrm.form.labels.image,
                style: _theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox.square(dimension: 12),
              Center(
                child: SizedBox.square(
                  dimension: 100,
                  child: ValueListenableBuilder(
                    valueListenable: avatarNotifier,
                    builder: (_, value, _) {
                      return UserAvatarPicker(
                        image: value,
                        onPickImage: (file) {
                          if (file != null) {
                            return avatarNotifier.set(DynamicFileType(local: file));
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox.square(dimension: 24),

              // Name
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.name}*',
                  hintText: context.t.hrm.form.hints.enterFullName,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterName,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Designation
              ValueListenableBuilder<int?>(
                valueListenable: selectedDesignationNotifier,
                builder: (_, value, _) {
                  return AsyncCustomDropdown<int?, DesignationListModel>(
                    asyncData: designationDropdownAsync,
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.designation}*',
                      hintText: context.t.hrm.form.hints.selectDesignation,
                    ),
                    value: value,
                    items: designationDropdownAsync.when(
                      data: (data) {
                        return [
                          CustomDropdownMenuItem.navigator(
                            label: context.t.hrm.form.hints.selectDesignation,
                            navLabel: context.t.hrm.dropdowns.addNew,
                            onNavTap: () async {
                              if (ref.canSnackbar(context, PMKeys.designation, action: PermissionAction.create)) {
                                final _result = await context.router.push<DesignationModel>(
                                  ManageDesignationRoute(),
                                );
                                if (_result != null) {
                                  selectedDesignationNotifier.set(_result.id);
                                }
                              }
                            },
                          ),

                          ...?data.data?.data?.map(
                            (designation) {
                              return CustomDropdownMenuItem(
                                value: designation.id,
                                label: TextSpan(text: designation.name ?? "N/A"),
                              );
                            },
                          ),
                        ];
                      },
                      error: (_, _) => [],
                      loading: () => [],
                    ),
                    onChanged: selectedDesignationNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectDesignation,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Department
              ValueListenableBuilder<int?>(
                valueListenable: selectedDepartmentNotifier,
                builder: (_, value, _) {
                  return AsyncCustomDropdown<int?, DepartmentListModel>(
                    asyncData: departmentDropdownAsync,
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.department}*',
                      hintText: context.t.hrm.form.hints.selectDepartment,
                    ),
                    value: value,
                    items: departmentDropdownAsync.when(
                      data: (data) {
                        return [
                          CustomDropdownMenuItem.navigator(
                            label: context.t.hrm.form.hints.selectDepartment,
                            navLabel: context.t.hrm.dropdowns.addNew,
                            onNavTap: () async {
                              if (ref.canSnackbar(context, PMKeys.department, action: PermissionAction.create)) {
                                final _result = await context.router.push<DepartmentModel>(
                                  ManageDepartmentRoute(),
                                );
                                if (_result != null) {
                                  return selectedDepartmentNotifier.set(_result.id);
                                }
                              }
                            },
                          ),

                          ...?data.data?.data?.map(
                            (department) {
                              return CustomDropdownMenuItem(
                                value: department.id,
                                label: TextSpan(text: department.name ?? "N/A"),
                              );
                            },
                          ),
                        ];
                      },
                      error: (_, _) => [],
                      loading: () => [],
                    ),
                    onChanged: selectedDepartmentNotifier.set,
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectDepartment,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Email
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '${context.t.common.email}*',
                  hintText: context.t.form.email.hint,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: context.t.hrm.validation.enterEmail,
                  ),
                  FormBuilderValidators.email(
                    errorText: context.t.hrm.validation.enterValidEmail,
                  ),
                ]),
              ),
              const SizedBox.square(dimension: 16),

              // Phone
              TextFormField(
                controller: phoneController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '${context.t.form.phone.label}*',
                  hintText: context.t.form.phone.hint,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterPhoneNumber,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Country
              TextFormField(
                controller: countryController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.country}*',
                  hintText: context.t.hrm.form.hints.enterCountry,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterCountry,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Salary
              NumberFormField(
                controller: salaryController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.salary}*',
                  hintText: context.t.hrm.form.hints.enterSalary,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterSalary,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Gender + Shift
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: selectedGenderNotifier,
                      builder: (_, value, _) {
                        return CustomDropdown<String?>(
                          showClearButton: false,
                          decoration: InputDecoration(
                            labelText: '${context.t.hrm.form.labels.gender}*',
                            hintText: context.t.hrm.form.hints.selectGender,
                          ),
                          value: value,
                          items: [
                            CustomDropdownMenuItem(
                              value: 'male',
                              label: TextSpan(text: context.t.hrm.dropdowns.male),
                            ),
                            CustomDropdownMenuItem(
                              value: 'female',
                              label: TextSpan(text: context.t.hrm.dropdowns.female),
                            ),
                          ],
                          onChanged: selectedGenderNotifier.set,
                          validator: FormBuilderValidators.required(
                            errorText: context.t.hrm.validation.selectGender,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox.square(dimension: 16),
                  Expanded(
                    child: ValueListenableBuilder<int?>(
                      valueListenable: selectedShiftNotifier,
                      builder: (_, value, _) {
                        return AsyncCustomDropdown<int?, ShiftListModel>(
                          asyncData: shiftDropdownAsync,
                          showClearButton: false,
                          decoration: InputDecoration(
                            labelText: '${context.t.hrm.shift}*',
                            hintText: context.t.hrm.form.hints.selectShift,
                          ),
                          value: value,
                          items: shiftDropdownAsync.when(
                            data: (data) {
                              return [
                                CustomDropdownMenuItem.navigator(
                                  label: context.t.hrm.dropdowns.addNew,
                                  navLabel: context.t.hrm.dropdowns.addNew,
                                  onNavTap: () async {
                                    if (ref.canSnackbar(context, PMKeys.shift, action: PermissionAction.create)) {
                                      final _result = await context.router.push<ShiftModel>(ManageShiftRoute());
                                      if (_result != null) {
                                        selectedShiftNotifier.set(_result.id);
                                      }
                                    }
                                  },
                                ),

                                ...?data.data?.data?.map((shift) {
                                  return CustomDropdownMenuItem(
                                    value: shift.id,
                                    label: TextSpan(text: shift.name ?? "N/A"),
                                  );
                                }),
                              ];
                            },
                            error: (_, _) => [],
                            loading: () => [],
                          ),
                          onChanged: selectedShiftNotifier.set,
                          validator: FormBuilderValidators.required(
                            errorText: context.t.hrm.validation.selectShift,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Birth Date + Join Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DateFormField(
                      controller: birthDateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.birthDate}*',
                        hintText: context.t.hrm.form.hints.selectBirthDate,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectBirthDate,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 16),
                  Expanded(
                    child: DateFormField(
                      controller: joinDateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.joinDate}*',
                        hintText: context.t.hrm.form.hints.selectJoinDate,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectJoinDate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Status
              ValueListenableBuilder(
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
                          (label: context.t.hrm.dropdowns.active, value: 'active'),
                          (label: context.t.hrm.dropdowns.terminated, value: 'terminated'),
                          (label: context.t.hrm.dropdowns.suspended, value: 'suspended'),
                        ].map((status) {
                          return CustomDropdownMenuItem<String>(
                            value: status.value,
                            label: TextSpan(text: status.label),
                          );
                        }).toList(),
                    onChanged: (v) => selectedStatusNotifier.set(v!),
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectStatus,
                    ),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              final _action = widget.isEditMode ? PermissionAction.update : PermissionAction.create;
              if (ref.canSnackbar(context, PMKeys.employee, action: _action)) {
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

abstract class _$ManageEmployeeViewState extends ConsumerState<ManageEmployeeView> {
  //----------------------Form Field Props----------------------//
  late final avatarNotifier = ValueNotifier<DynamicFileType?>(null),
      nameController = TextEditingController(),
      selectedDesignationNotifier = ValueNotifier<int?>(null),
      selectedDepartmentNotifier = ValueNotifier<int?>(null),
      emailController = TextEditingController(),
      phoneController = TextEditingController(),
      countryController = TextEditingController(),
      salaryController = TextEditingController(),
      selectedGenderNotifier = ValueNotifier<String?>(null),
      selectedShiftNotifier = ValueNotifier<int?>(null),
      birthDateController = TextEditingController(),
      joinDateController = TextEditingController(),
      selectedStatusNotifier = ValueNotifier<String>('active');
  //----------------------Form Field Props----------------------//

  void initEdit(EmployeeModel data) {
    avatarNotifier.value = data.image;
    nameController.text = data.name ?? '';
    selectedDesignationNotifier.value = data.designation?.id;
    selectedDepartmentNotifier.value = data.department?.id;
    emailController.text = data.email ?? '';
    phoneController.text = data.phone ?? '';
    countryController.text = data.country ?? '';
    salaryController.text = data.salary?.toString() ?? '';
    selectedGenderNotifier.value = data.gender;
    selectedShiftNotifier.value = data.shift?.id;
    birthDateController.text = data.dateOfBirth?.backSlashDateFormat ?? '';
    joinDateController.text = data.joiningDate?.backSlashDateFormat ?? '';
    selectedStatusNotifier.value = data.status ?? 'active';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? EmployeeModel()).copyWith(
        image: avatarNotifier.value,
        name: nameController.text,
        designation: DesignationModel(id: selectedDesignationNotifier.value),
        department: DepartmentModel(id: selectedDepartmentNotifier.value),
        email: emailController.text,
        phone: phoneController.text,
        country: countryController.text,
        salary: salaryController.text.plainNumber,
        gender: selectedGenderNotifier.value,
        shift: ShiftModel(id: selectedShiftNotifier.value),
        dateOfBirth: birthDateController.text.parseDate,
        joiningDate: joinDateController.text.parseDate,
        status: selectedStatusNotifier.value,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(employeeRepoProvider).manageEmployee(_data),
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
