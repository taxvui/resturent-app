import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_manage_expense_category_view_provider.dart';

@RoutePage()
class ManageExpenseCategoryView extends ConsumerStatefulWidget {
  const ManageExpenseCategoryView({
    super.key,
    this.editModel,
  });
  final ExpenseCategory? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageExpenseCategoryView> createState() => _ManageExpenseCategoryViewState();
}

class _ManageExpenseCategoryViewState extends ConsumerState<ManageExpenseCategoryView> {
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      ref.read(manageExpenseCategoryViewProvider).initEdit(widget.editModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageExpenseCategoryViewProvider);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode
                  ? context.t.pages.expense.editExpenseCategory
                  : context.t.pages.expense.addNewExpenseCategory,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Name
                TextFormField(
                  controller: controller.categoryNameController,
                  decoration: InputDecoration(
                    labelText: context.t.form.expense.label,
                    hintText: context.t.form.income.hint,
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.form.income.error.required,
                  ),
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
      asyncFunction: () => ref.read(manageExpenseCategoryViewProvider).handleManageCategory(widget.editModel),
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
