import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_printint_option_view_provider.dart';

@RoutePage()
class PrintingOptionView extends ConsumerStatefulWidget {
  const PrintingOptionView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrintingOptionViewState();
}

class _PrintingOptionViewState extends ConsumerState<PrintingOptionView> {
  @override
  void initState() {
    ref.read(printingOptionViewProvider).initEdit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(printingOptionViewProvider);
    final printerProfileAsync = ref.watch(printerProfileProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(context.t.pages.printingOption.title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Business Logo
                Center(
                  child: SizedBox.square(
                    dimension: 72,
                    child: UserAvatarPicker(
                      image: controller.avatarImage,
                      onPickImage: controller.handleAvatarImage,
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Business Name
                TextFormField(
                  controller: controller.shopNameController,
                  keyboardType: TextInputType.text,
                  autofillHints: const [AutofillHints.organizationName],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.profile.shopOrStore.label,
                    hintText: context.t.form.profile.shopOrStore.hint,
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.form.profile.shopOrStore.errors.required,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Phone Number
                TextFormField(
                  controller: controller.businessPhoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.phone.label,
                    hintText: context.t.form.phone.hint,
                  ),
                  validator: FormBuilderValidators.phoneNumber(
                    errorText: context.t.form.phone.errors.required,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Company Address
                TextFormField(
                  controller: controller.shopAddressController,
                  keyboardType: TextInputType.text,
                  autofillHints: const [AutofillHints.fullStreetAddress],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.companyAddress.label,
                    hintText: context.t.pages.printingOption.form.companyAddress.hint,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Note Label
                TextFormField(
                  controller: controller.noteLabelController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.noteLabel.label,
                    hintText: context.t.pages.printingOption.form.noteLabel.hint,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Note
                TextFormField(
                  controller: controller.noteController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.note.label,
                    hintText: context.t.pages.printingOption.form.note.hint,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Post Sale Message
                TextFormField(
                  controller: controller.postSaleMessage,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.postSaleMessage.label,
                    hintText: context.t.pages.printingOption.form.postSaleMessage.hint,
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Printing Options
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.t.common.printingOption,
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox.fromSize(
                      size: const Size(40, 22),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Switch(
                          value: controller.printerSettings.autoPrint,
                          onChanged: controller.toggleAutoPrint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20),

                // Printing Method
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomDropdown<ThermalPrinterPrintingMethod>(
                        showClearButton: false,
                        decoration: InputDecoration(
                          labelText: context.t.pages.printingOption.form.printingMethod.label,
                          hintText: context.t.pages.printingOption.form.printingMethod.hint,
                        ),
                        value: controller.printerSettings.printingMethod,
                        items: [
                          ...ThermalPrinterPrintingMethod.values.map((method) {
                            return CustomDropdownMenuItem(
                              value: method,
                              label: TextSpan(text: method.label(context)),
                            );
                          }),
                        ],
                        onChanged: controller.handleSelectPrintingMethod,
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                    const SizedBox.square(dimension: 8),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      constraints: BoxConstraints.tightFor(width: MediaQuery.sizeOf(context).width - 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                        boxShadow: [
                          DAppBoxShadowStyles.boxShadow1,
                          DAppBoxShadowStyles.boxShadow1,
                          DAppBoxShadowStyles.boxShadow1,
                          DAppBoxShadowStyles.boxShadow2,
                        ],
                      ),
                      textStyle: _theme.textTheme.bodyMedium,
                      richMessage: TextSpan(
                        text: context.t.pages.printingOption.tooltip.printingMethod.title,
                        children: [
                          TextSpan(text: '\n${context.t.pages.printingOption.tooltip.printingMethod.kDefault}\n'),
                          TextSpan(text: context.t.pages.printingOption.tooltip.printingMethod.image),
                        ],
                      ),
                      waitDuration: Durations.extralong4,
                      child: Icon(Icons.info, color: _theme.colorScheme.secondary),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20),

                // Printer Profile
                AsyncCustomDropdown<PrinterProfile, List<PrinterProfile>>(
                  asyncData: printerProfileAsync,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.printerProfile.label,
                    hintText: context.t.pages.printingOption.form.printerProfile.hint,
                  ),
                  value: controller.printerSettings.profile,
                  items: printerProfileAsync.when(
                    data: (data) {
                      return [
                        ...data.map((profile) {
                          return CustomDropdownMenuItem(
                            value: profile,
                            label: TextSpan(text: profile.name),
                          );
                        }),
                      ];
                    },
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: controller.handleSelectPrinterProfile,
                  validator: FormBuilderValidators.required(),
                  onRefresh: () => ref.refresh(printerProfileProvider.future),
                ),
                const SizedBox.square(dimension: 20),

                // Thermal Printer Paper Size
                CustomDropdown<ThermalPrinterPaperSize>(
                  showClearButton: false,
                  decoration: InputDecoration(
                    labelText: context.t.pages.printingOption.form.paperSize.label,
                    hintText: context.t.pages.printingOption.form.paperSize.hint,
                  ),
                  value: controller.printerSettings.paperSize,
                  items: [
                    ...ThermalPrinterPaperSize.values.map((paperSize) {
                      return CustomDropdownMenuItem(
                        value: paperSize,
                        label: TextSpan(text: paperSize.label(context)),
                      );
                    }),
                  ],
                  onChanged: controller.handleSelectPrinterPaperSize,
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox.square(dimension: 20),

                /// Only Available for [ThermalPrinterPrintingMethod.image]
                if (controller.printerSettings.printingMethod == ThermalPrinterPrintingMethod.image) ...[
                  // Printer DPI
                  NumberFormField(
                    controller: controller.printerDpiController,
                    decimalDigits: 0,
                    decoration: InputDecoration(
                      labelText: context.t.pages.printingOption.form.printerDpi.label,
                      hintText: context.t.pages.printingOption.form.printerDpi.hint,
                    ),
                  ),
                  const SizedBox.square(dimension: 20),

                  // Printing Margin (MM)
                  NumberFormField(
                    controller: controller.printerMarginController,
                    decoration: InputDecoration(
                      label: Text.rich(
                        TextSpan(
                          text: context.t.pages.printingOption.form.printingMargin.label,
                          children: [
                            TextSpan(
                              text: '(MM)',
                              style: TextStyle(
                                color: _theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      hintText: context.t.pages.printingOption.form.printingMargin.hint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (ref.canSnackbar(context, PMKeys.printingOption, action: PermissionAction.update)) {
                if (FormWrapper.validate(formContext)) {
                  return _handleFormSubmit(context);
                }
              }
            },
            child: Text(context.t.pages.printingOption.action.save),
          ).fMarginLTRB(24, 12, 24, 16),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    try {
      await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => ref.read(printingOptionViewProvider).handleManagePrintingOption(),
      );

      if (context.mounted) {
        return context.router.pop();
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }
    }
  }
}

final printerProfileProvider = FutureProvider(
  (ref) => PrinterProfile.loadProfiles(),
);
