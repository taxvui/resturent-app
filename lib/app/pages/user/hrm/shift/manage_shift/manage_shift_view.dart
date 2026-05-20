import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ManageShiftView extends ConsumerStatefulWidget {
  const ManageShiftView({super.key, this.editModel});
  final ShiftModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageShiftView> createState() => _ManageShiftViewState();
}

class _ManageShiftViewState extends _$ManageShiftViewState {
  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(widget.isEditMode ? 'Edit Shift' : 'Add Shift'),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Shift Name
              ValueListenableBuilder<String?>(
                valueListenable: selectedShiftNotifier,
                builder: (_, value, _) {
                  return CustomDropdown<String>(
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.shift}*',
                      hintText: context.t.hrm.form.hints.selectShift,
                    ),
                    value: value,
                    items: [
                      ...[
                        (label: context.t.hrm.dropdowns.morning, value: "Morning"),
                        (label: context.t.hrm.dropdowns.day, value: "Day"),
                        (label: context.t.hrm.dropdowns.evening, value: "Evening"),
                        (label: context.t.hrm.dropdowns.night, value: "Night"),
                      ].map((entry) {
                        return CustomDropdownMenuItem(
                          value: entry.value,
                          label: TextSpan(text: entry.label),
                        );
                      }),
                    ],
                    onChanged: (v) => selectedShiftNotifier.set(v!),
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectShift,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Break Status
              ValueListenableBuilder(
                valueListenable: selectedBreakNotifier,
                builder: (_, value, _) {
                  return CustomDropdown<String>(
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.breakStatus}*',
                      hintText: context.t.hrm.form.hints.selectBreakStatus,
                    ),
                    value: value,
                    items: [
                      ...[
                        (label: context.t.hrm.dropdowns.yes, value: "yes"),
                        (label: context.t.hrm.dropdowns.no, value: "no"),
                      ].map((entry) {
                        return CustomDropdownMenuItem(
                          value: entry.value,
                          label: TextSpan(text: entry.label),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      selectedBreakNotifier.set(v!);
                      if (v == 'no') {
                        startBreakTimeController.clear();
                        endBreakTimeController.clear();
                      }
                    },
                    validator: FormBuilderValidators.required(
                      errorText: context.t.hrm.validation.selectBreakStatus,
                    ),
                  );
                },
              ),
              const SizedBox.square(dimension: 16),

              // Start Time / End Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TimeFormField(
                      controller: startTimeController,
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.startTime}*',
                        hintText: context.t.hrm.form.hints.selectStartTime,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectStartTime,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),
                  Expanded(
                    child: TimeFormField(
                      controller: endTimeController,
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.endTime}*',
                        hintText: context.t.hrm.form.hints.selectEndTime,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectEndTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Break Time (Conditional)
              ValueListenableBuilder(
                valueListenable: selectedBreakNotifier,
                builder: (_, value, child) {
                  if (value != 'yes') return const SizedBox.shrink();
                  return child!;
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TimeFormField(
                            controller: startBreakTimeController,
                            decoration: InputDecoration(
                              labelText: '${context.t.hrm.form.labels.startBreakTime}*',
                              hintText: context.t.hrm.form.hints.selectStartTime,
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: context.t.hrm.validation.selectStartBreakTime,
                            ),
                          ),
                        ),
                        const SizedBox.square(dimension: 12),
                        Expanded(
                          child: TimeFormField(
                            controller: endBreakTimeController,
                            decoration: InputDecoration(
                              labelText: '${context.t.hrm.form.labels.endBreakTime}*',
                              hintText: context.t.hrm.form.hints.selectEndTime,
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: context.t.hrm.validation.selectEndBreakTime,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox.square(dimension: 16),
                  ],
                ),
              ),

              // Status
              ValueListenableBuilder<String?>(
                valueListenable: selectedStatusNotifier,
                builder: (_, value, _) {
                  return CustomDropdown<String>(
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: '${context.t.hrm.form.labels.status}*',
                      hintText: context.t.hrm.form.hints.selectStatus,
                    ),
                    value: value,
                    items: [
                      ...[
                        (label: context.t.hrm.dropdowns.active, value: "active"),
                        (label: context.t.hrm.dropdowns.inactive, value: "inactive"),
                      ].map((entry) {
                        return CustomDropdownMenuItem(
                          value: entry.value,
                          label: TextSpan(text: entry.label),
                        );
                      }),
                    ],
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
              if (ref.canSnackbar(context, PMKeys.shift, action: _action)) {
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

abstract class _$ManageShiftViewState extends ConsumerState<ManageShiftView> {
  //----------------------Form Field Props----------------------//
  late final selectedShiftNotifier = ValueNotifier<String?>(null),
      selectedBreakNotifier = ValueNotifier<String?>(null),
      startTimeController = TextEditingController(),
      endTimeController = TextEditingController(),
      startBreakTimeController = TextEditingController(),
      endBreakTimeController = TextEditingController(),
      selectedStatusNotifier = ValueNotifier<String>('active');

  //----------------------Form Field Props----------------------//

  void initEdit(ShiftModel data) {
    selectedShiftNotifier.value = data.name?.toLowerCase();
    selectedBreakNotifier.value = data.breakStatus?.toLowerCase();
    startTimeController.text = data.startTime?.timeFormat12Hour ?? '';
    endTimeController.text = data.endTime?.timeFormat12Hour ?? '';
    startBreakTimeController.text = data.startBreakTime?.timeFormat12Hour ?? '';
    endBreakTimeController.text = data.endBreakTime?.timeFormat12Hour ?? '';
    selectedStatusNotifier.value = data.status ? 'active' : 'inactive';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? ShiftModel()).copyWith(
        name: selectedShiftNotifier.value,
        breakStatus: selectedBreakNotifier.value,
        startTime: startTimeController.text.parseDate,
        endTime: endTimeController.text.parseDate,
        startBreakTime: startBreakTimeController.text.parseDate,
        endBreakTime: endBreakTimeController.text.parseDate,
        status: selectedStatusNotifier.value == 'active',
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(shiftRepoProvider).manageShift(_data),
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
