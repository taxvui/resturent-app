import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/core.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

part '_manage_expense_view_provider.dart';

@RoutePage()
class ManageExpenseView extends ConsumerStatefulWidget {
  const ManageExpenseView({super.key, this.editModel});
  final Expense? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageExpenseView> createState() => _ManageExpenseViewState();
}

class _ManageExpenseViewState extends ConsumerState<ManageExpenseView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageExpenseViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageExpenseViewProvider);
    final _expenseCategory = ref.watch(expenseCategoryDropdownProvider);

    final _paymentMethodAsync = ref.watch(
      businessPaymentMethodDropdownProvider,
    );

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.pages.expense.editExpense : context.t.pages.expense.addNewExpense,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Expense Title
                TextFormField(
                  controller: controller.expenseTitleController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.expense.expenseTitle.label,
                    hintText: context.t.pages.expense.expenseTitle.hint,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                  ]),
                ),
                const SizedBox.square(dimension: 20),

                // Expense Category
                AsyncCustomDropdown<int, ExpenseCategoryList>(
                  asyncData: _expenseCategory,
                  decoration: InputDecoration(
                    labelText: context.t.pages.expense.expenseCategory,
                    hintText: context.t.pages.expense.selectCategory,
                  ),
                  value: controller.dropdownValues['expense_category'],
                  items: _expenseCategory.when(
                    data: (data) => [
                      // Navigator
                      CustomDropdownMenuItem.navigator(
                        label: context.t.pages.expense.selectCategory,
                        navLabel: '+ ${context.t.common.addNew}',
                        onNavTap: () async {
                          return await context.router.push<ExpenseCategory>(ManageExpenseCategoryRoute()).then(
                            (value) {
                              if (value != null) {
                                controller.handleDropdownChange(
                                  MapEntry('expense_category', value.id),
                                );
                              }
                            },
                          );
                        },
                      ),

                      ...?data.data?.data?.map(
                        (category) => CustomDropdownMenuItem<int>(
                          value: category.id,
                          label: TextSpan(text: category.categoryName ?? ''),
                        ),
                      ),
                    ],
                    error: (e, s) => [],
                    loading: () => [],
                  ),
                  onChanged: (value) => controller.handleDropdownChange(
                    MapEntry('expense_category', value),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.pages.expense.pleaseSelectACategory,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Expense Amount
                TextFormField(
                  controller: controller.paymentAmountController,
                  keyboardType: const TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.expense.payment,
                    hintText: context.t.common.commonHint,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.notZeroNumber(),
                  ]),
                ),
                const SizedBox.square(dimension: 20),

                // Payment Method
                AsyncCustomDropdown<int, BusinessPaymentMethodList>(
                  asyncData: _paymentMethodAsync,
                  decoration: InputDecoration(
                    labelText: context.t.common.paymentMethod,
                    hintText: context.t.common.selectOne,
                  ),
                  value: controller.dropdownValues['payment_id'],
                  items: _paymentMethodAsync.when(
                    data: (data) => [
                      // Navigator
                      CustomDropdownMenuItem.navigator(
                        label: context.t.pages.payment.selectPaymentMethod,
                        navLabel: '+ ${context.t.common.addNew}',
                        onNavTap: () async {
                          if (ref.canSnackbar(context, PMKeys.paymentMethod, action: PermissionAction.create)) {
                            return await context.router
                                .push<BusinessPaymentMethod>(
                                  ManageBusinessPaymentMethodRoute(),
                                )
                                .then(
                                  (value) {
                                    if (value != null) {
                                      controller.handleDropdownChange(
                                        MapEntry('payment_id', value.id),
                                      );
                                    }
                                  },
                                );
                          }
                        },
                      ),

                      ...?data.data?.data?.map(
                        (paymentMethod) => CustomDropdownMenuItem<int>(
                          value: paymentMethod.id,
                          label: TextSpan(text: paymentMethod.name ?? 'N/A'),
                        ),
                      ),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (value) => controller.handleDropdownChange(
                    MapEntry('payment_id', value),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.pages.payment.pleaseSelectAPaymentMethod,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Note
                TextFormField(
                  controller: controller.noteController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.t.form.note.label,
                    hintText: context.t.form.note.hint,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (FormWrapper.validate(formContext)) {
                return await _handleFormSubmit(context);
              }
            },
            child: Text(context.t.action.save),
          ).fMarginSymmetric(horizontal: 16, vertical: 12),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref.read(manageExpenseViewProvider).handleManageExpense(widget.editModel),
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

      context.router.maybePop();
      return;
    }
  }
}
