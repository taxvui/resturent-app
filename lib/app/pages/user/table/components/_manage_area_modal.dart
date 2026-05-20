import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

class ManageAreaModal extends ConsumerStatefulWidget {
  const ManageAreaModal({super.key, this.editModel});
  final AreaModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageAreaModalState();
}

class _ManageAreaModalState extends ConsumerState<ManageAreaModal> {
  //-------------------------Form Field Props-------------------------//
  late final areaNameController = TextEditingController();
  //-------------------------Form Field Props-------------------------//

  @override
  void initState() {
    if (widget.isEditMode) {
      areaNameController.text = widget.editModel?.name ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: widget.isEditMode ? 'Edit Area' : 'Add New Area'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Area Name
                TextFormField(
                  controller: areaNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Area Name',
                    hintText: 'Enter area name',
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Please enter area name',
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return handleFormSubmit(context);
                    }
                  },
                  child: Text(widget.isEditMode ? 'Update' : 'Save'),
                ),

                // Keyboard Spacer
                SizedBox.square(
                  dimension: MediaQuery.viewInsetsOf(context).bottom,
                )
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? AreaModel()).copyWith(
        name: areaNameController.text,
      );

      await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(tableRepoProvider).manageArea(_data),
        ),
      );

      if (context.mounted) {
        return Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return Navigator.of(context).pop();
      }
    }
  }
}

Future<void> showManageAreaModal(BuildContext context, {AreaModel? editModel}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    builder: (_) => ManageAreaModal(editModel: editModel),
  );
}
