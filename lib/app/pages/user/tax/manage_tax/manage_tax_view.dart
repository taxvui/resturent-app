import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_manage_tax_view_provider.dart';

@RoutePage()
class ManageTaxView extends ConsumerStatefulWidget {
  const ManageTaxView({super.key, this.editModel});
  final TaxModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageTaxView> createState() => _ManageTaxViewState();
}

class _ManageTaxViewState extends ConsumerState<ManageTaxView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageTaxViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageTaxViewProvider);
    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(widget.isEditMode ? context.t.pages.vat.editVat : context.t.pages.vat.addNewVat),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '${context.t.form.vat.name.label} *',
                    hintText: context.t.form.vat.name.hint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.t.form.vat.name.error.required;
                    }
                    return null;
                  },
                ),
                const SizedBox.square(dimension: 20),

                // VAT Rate
                NumberFormField(
                  controller: controller.rateController,
                  decoration: InputDecoration(
                    labelText: '${context.t.form.vat.rate.label} *',
                    hintText: context.t.form.vat.rate.hint,
                  ),
                  validator: NumberFormField.nonZeroRequired,
                ),
                const SizedBox.square(dimension: 14),

                // Status
                Row(
                  children: [
                    // Status
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: context.t.common.status,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Tooltip(
                                message: context.t.common.statusIsCannotInActive,
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                child: Icon(
                                  Icons.info,
                                  size: 16,
                                  color: _theme.colorScheme.secondary,
                                ).fMarginOnly(left: 4),
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: SizedBox.fromSize(
                                size: const Size(44, 24),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Switch.adaptive(
                                    value: controller.isVATOnSales == true ? true : controller.isActive,
                                    onChanged: controller.toggleIsActive,
                                  ),
                                ),
                              ).fMarginOnly(left: 12),
                            ),
                          ],
                        ),
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          color: _theme.colorScheme.secondary,
                        ),
                      ),
                    ),

                    // VAT On Sales
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: context.t.common.vatOnSales,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Checkbox(
                                value: controller.isVATOnSales,
                                onChanged: (value) {
                                  return controller.toggleIsVATOnSales(value!);
                                },
                                activeColor: Colors.green,
                                side: BorderSide(
                                  color: _theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.end,
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          color: _theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
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
          ).fMarginLTRB(16, 12, 16, 16),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref
          .read(manageTaxViewProvider)
          .handleManageTax(
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
