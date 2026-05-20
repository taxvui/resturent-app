import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ManageLeaveTypeView extends ConsumerStatefulWidget {
  const ManageLeaveTypeView({super.key, this.editModel});
  final LeaveTypeModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageLeaveTypeView> createState() => _ManageLeaveTypeViewState();
}

class _ManageLeaveTypeViewState extends _$ManageLeaveTypeViewState {
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
            title: Text(
              widget.isEditMode ? context.t.hrm.pageTitles.editLeaveType : context.t.hrm.pageTitles.addLeaveType,
            ),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Leave Type Name
              TextFormField(
                controller: leaveTypeNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.leaveType}*',
                  hintText: context.t.hrm.form.hints.enterLeaveTypeName,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterLeaveTypeName,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Status
              ValueListenableBuilder(
                valueListenable: selectedStatusNotifier,
                builder: (_, value, _) {
                  return CustomDropdown<String>(
                    showClearButton: false,
                    decoration: InputDecoration(
                      labelText: "${context.t.hrm.form.labels.status}*",
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
              const SizedBox.square(dimension: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsetsDirectional.all(10),
                  labelText: context.t.hrm.form.labels.description,
                  hintText: context.t.hrm.form.hints.enterDescription,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  final _action = widget.isEditMode ? PermissionAction.update : PermissionAction.create;
                  if (ref.canSnackbar(context, PMKeys.leaveType, action: _action)) {
                    if (FormWrapper.validate(formContext)) {
                      return handleFormSubmit(context);
                    }
                  }
                },
                child: Text(context.t.action.save),
              ),
            ],
          ),
        );
      },
    ).unfocusPrimary();
  }
}

abstract class _$ManageLeaveTypeViewState extends ConsumerState<ManageLeaveTypeView> {
  //----------------------Form Field Props----------------------//
  late final leaveTypeNameController = TextEditingController(),
      selectedStatusNotifier = ValueNotifier<String>('active'),
      descriptionController = TextEditingController();
  //----------------------Form Field Props----------------------//

  void initEdit(LeaveTypeModel data) {
    leaveTypeNameController.text = data.name ?? '';
    selectedStatusNotifier.value = data.status ? 'active' : 'inactive';
    descriptionController.text = data.description ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? LeaveTypeModel()).copyWith(
        name: leaveTypeNameController.text,
        status: selectedStatusNotifier.value == 'active',
        description: descriptionController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(leaveTypeRepoProvider).manageLeaveType(_data),
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
