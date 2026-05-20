import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_manage_tax_group_view_provider.dart';

@RoutePage()
class ManageTaxGroupView extends ConsumerStatefulWidget {
  const ManageTaxGroupView({super.key, this.editModel});
  final TaxModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageTaxGroupView> createState() => _ManageTaxGroupViewState();
}

class _ManageTaxGroupViewState extends ConsumerState<ManageTaxGroupView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageTaxGroupViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageTaxGroupViewProvider);
    final _taxList = ref.watch(taxListProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.pages.vat.editVatGroup : context.t.pages.vat.addNewVatGroup,
            ),
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
                MultiSelectFormField<TaxModel, TaxModelResponse>.bottomModal(
                  asyncData: _taxList,
                  decoration: InputDecoration(
                    // labelText: 'Sub VAT *',
                    labelText: '${context.t.form.vat.subVat.label} *',
                    // hintText: 'Select sub VAT',
                    hintText: context.t.form.vat.subVat.hint,
                  ),
                  listBuilder: (context, item, isSelected) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -1,
                      ),
                      title: Text(item.value?.name ?? "N.A"),
                      subtitle: Text(
                        // 'VAT Percent: ${item.value?.rate?.commaSeparated() ?? "N/A"}%',
                        '${context.t.common.vatRate}: ${item.value?.rate?.commaSeparated() ?? "N/A"}%',
                      ),
                      subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: DAppColors.kSuccess,
                            )
                          : null,
                    );
                  },
                  selectedItemBuilder: (context, item, onRemove) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: onRemove,
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ).fMarginOnly(right: 2),
                            ),
                            item.label,
                          ],
                        ),
                        style: TextStyle(color: _theme.colorScheme.onPrimary),
                      ),
                    );
                  },
                  value: controller.selectedSubTaxes,
                  items: _taxList.when(
                    data: (data) {
                      return [
                        ...?data.data?.map((subTax) {
                          return CustomDropdownMenuItem(
                            value: subTax,
                            label: TextSpan(text: subTax.name ?? "N/A"),
                          );
                        }),
                      ];
                    },
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: controller.handleSelectSubTaxes,
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select sub VAT',
                  ),
                ),
                const SizedBox.square(dimension: 14),

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
                                message: 'Status cannot be inactive if VAT is on sales.',
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
                          text: 'VAT On Sales',
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Checkbox(
                                visualDensity: VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
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
          .read(manageTaxGroupViewProvider)
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

      context.router.maybePop();
      return;
    }
  }
}
