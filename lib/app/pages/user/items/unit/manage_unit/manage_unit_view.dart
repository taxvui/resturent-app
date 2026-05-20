import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

part '_manage_unit_view_provider.dart';

@RoutePage()
class ManageUnitView extends ConsumerStatefulWidget {
  const ManageUnitView({super.key, this.editModel});
  final ItemUnit? editModel;

  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageUnitView> createState() => _ManageUnitViewState();
}

class _ManageUnitViewState extends ConsumerState<ManageUnitView> {
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      ref.read(manageUnitProvider).initEdit(widget.editModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageUnitProvider);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(widget.isEditMode ? context.t.pages.unit.editUnit : context.t.pages.unit.addNewUnit),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
            child: Column(
              children: [
                // Unit Name
                TextFormField(
                  controller: controller.unitNameController,
                  decoration: InputDecoration(
                    labelText: context.t.form.items.unit.label,
                    hintText: context.t.form.items.unit.hint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.t.form.items.unit.error.required;
                    }
                    return null;
                  },
                ),
                const SizedBox.square(dimension: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return await _handleFormSubmit(context);
                    }
                  },
                  child: Text(context.t.action.save),
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref
          .read(manageUnitProvider)
          .handleManageUnit(
            widget.editModel,
          ),
    );

    if (context.mounted) {
      if (_result.isFailure) {
        showCustomSnackBar(
          context,
          content: Text(_result.left!),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }

      context.router.maybePop(_result.right);
      return;
    }
  }
}
