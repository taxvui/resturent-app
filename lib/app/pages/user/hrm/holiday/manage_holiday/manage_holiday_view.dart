import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ManageHolidayView extends ConsumerStatefulWidget {
  const ManageHolidayView({super.key, this.editModel});
  final HolidayModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageHolidayView> createState() => _ManageHolidayViewState();
}

class _ManageHolidayViewState extends _$ManageHolidayViewState {
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
              widget.isEditMode ? context.t.hrm.pageTitles.editHoliday : context.t.hrm.pageTitles.addHoliday,
            ),
          ),
          body: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Holiday Name
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${context.t.hrm.form.labels.name}*',
                  hintText: context.t.hrm.form.hints.enterHolidayName,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.hrm.validation.enterHolidayName,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Start Date / End Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Expanded(
                    child: DateFormField(
                      controller: endDateController,
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      decoration: InputDecoration(
                        labelText: '${context.t.hrm.form.labels.endDate}*',
                        hintText: context.t.hrm.form.hints.selectEndDate,
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: context.t.hrm.validation.selectEndDate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                textInputAction: TextInputAction.done,
                maxLines: 3,
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
              if (ref.canSnackbar(context, PMKeys.holiday, action: _action)) {
                if (FormWrapper.validate(formContext)) {
                  return handleSubmit(context);
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

abstract class _$ManageHolidayViewState extends ConsumerState<ManageHolidayView> {
  //----------------------Form Field Props----------------------//
  late final nameController = TextEditingController(),
      startDateController = TextEditingController(),
      endDateController = TextEditingController(),
      descriptionController = TextEditingController();
  //----------------------Form Field Props----------------------//

  void initEdit(HolidayModel data) {
    nameController.text = data.name ?? '';
    startDateController.text = data.startDate?.backSlashDateFormat ?? '';
    endDateController.text = data.endDate?.backSlashDateFormat ?? '';
    descriptionController.text = data.description ?? '';
  }

  Future<void> handleSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? HolidayModel()).copyWith(
        name: nameController.text,
        startDate: startDateController.text.parseDate,
        endDate: endDateController.text.parseDate,
        description: descriptionController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(holidayRepoProvider).manageHoliday(_data),
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
