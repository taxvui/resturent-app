import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ManageDesignationView extends ConsumerStatefulWidget {
  const ManageDesignationView({super.key, this.editModel});
  final DesignationModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageDesignationView> createState() => _ManageDesignationViewState();
}

class _ManageDesignationViewState extends _$ManageDesignationViewState {
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
              widget.isEditMode ? context.t.hrm.pageTitles.editDesignation : context.t.hrm.pageTitles.addDesignation,
            ),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Designation Name
              TextFormField(
                controller: designationNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.designationName}*',
                  hintText: context.t.hrm.form.hints.enterDesignationName,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterDesignationName,
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
              const SizedBox.square(dimension: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                maxLines: 2,
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
                  if (ref.canSnackbar(context, PMKeys.designation, action: _action)) {
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

abstract class _$ManageDesignationViewState extends ConsumerState<ManageDesignationView> {
  //----------------------Form Field Props----------------------//
  late final designationNameController = TextEditingController(),
      selectedStatusNotifier = ValueNotifier<String>('active'),
      descriptionController = TextEditingController();
  //----------------------Form Field Props----------------------//

  void initEdit(DesignationModel data) {
    designationNameController.text = data.name ?? '';
    selectedStatusNotifier.value = data.status ? 'active' : 'inactive';
    descriptionController.text = data.description ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? DesignationModel()).copyWith(
        name: designationNameController.text,
        status: selectedStatusNotifier.value == 'active',
        description: descriptionController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(designationRepoProvider).manageDesignation(_data),
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
