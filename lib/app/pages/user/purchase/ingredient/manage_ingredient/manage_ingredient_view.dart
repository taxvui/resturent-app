import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

part '_manage_ingredient_view_provider.dart';

@RoutePage()
class ManageIngredientView extends ConsumerStatefulWidget {
  const ManageIngredientView({super.key, this.editModel});
  final Ingredient? editModel;

  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageIngredientView> createState() => _ManageIngredientViewState();
}

class _ManageIngredientViewState extends ConsumerState<ManageIngredientView> {
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      ref.read(ingredientViewProvider).initEdit(widget.editModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(ingredientViewProvider);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              // widget.isEditMode ? 'Edit Ingredient' : 'Add New Ingredient',
              widget.isEditMode
                  ? context.t.pages.ingredient.manageIngredient.title2
                  : context.t.pages.ingredient.manageIngredient.title1,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
            child: Column(
              children: [
                // Ingredient Name
                TextFormField(
                  controller: controller.ingredientViewNameController,
                  decoration: InputDecoration(
                    // labelText: 'Ingredient Name',
                    labelText: context.t.form.ingredientName.label,
                    // hintText: 'Enter ingredient name',
                    hintText: context.t.form.ingredientName.hint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      // return 'Please enter ingredient name';
                      return context.t.form.ingredientName.errors.required;
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
                  // child: const Text('Save'),
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
      asyncFunction: () => ref.read(ingredientViewProvider).handlemanageIngredient(widget.editModel),
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
