import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

part '_manage_coupon_view_provider.dart';

@RoutePage()
class ManageCouponView extends ConsumerStatefulWidget {
  const ManageCouponView({super.key, this.editModel});

  final CouponModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageCouponViewState();
}

class _ManageCouponViewState extends ConsumerState<ManageCouponView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageCouponViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageCouponViewProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? 'Edit Coupon' : 'Add Coupon',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Text(
                  'Image',
                  style: _theme.textTheme.bodyLarge,
                ),
                const SizedBox.square(dimension: 8),
                ImageFormField(
                  initialValue: controller.image,
                  previewSize: const Size.square(70),
                  decoration: ImageFieldDecoration(
                    hintText: const TextSpan(text: 'Upload'),
                  ),
                  onSelectImage: controller.handleImage,
                ),
                const SizedBox.square(dimension: 24),

                // Name
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter name',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox.square(dimension: 16),

                // Code
                TextFormField(
                  controller: controller.codeController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'Enter code',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox.square(dimension: 16),

                // Discount
                NumberFormField(
                  controller: controller.discountController,
                  decoration: InputDecoration(
                    labelText: 'Discount',
                    hintText: controller.discountModifier == RateModifierEnum.flat ? 'Ex: \$200' : 'Ex: 20%',
                    suffixIconConstraints: BoxConstraints.tightFor(width: 145),
                    suffixIcon: Container(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.horizontal(
                          end: const Radius.circular(4),
                        ),
                      ),
                      child: CustomDropdown<RateModifierEnum>(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          fillColor: _theme.colorScheme.surface,
                          filled: true,
                        ),
                        showClearButton: false,
                        value: controller.discountModifier,
                        items: [
                          ...RateModifierEnum.values.map((type) {
                            return CustomDropdownMenuItem(
                              value: type,
                              label: TextSpan(
                                text: type.labelExt(context),
                                style: _theme.textTheme.bodyMedium,
                              ),
                            );
                          }),
                        ],
                        onChanged: controller.handleDiscountModifierChange,
                      ),
                    ),
                  ),
                  inputFormatters: [
                    if (controller.discountModifier == RateModifierEnum.flat) NumberFormField.defaultFormatter(),
                    if (controller.discountModifier == RateModifierEnum.percent)
                      RateSelectorFormField.percentFormatter(),
                  ],
                  validator: FormBuilderValidators.required(
                    errorText: 'Please enter a discount.',
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Start Date
                DateFormField(
                  controller: controller.startDateController,
                  dateFormat: CustomDateFormat('dd/MM/yyyy'),
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    hintText: 'dd/mm/yyyy',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox.square(dimension: 16),

                // End Date
                DateFormField(
                  controller: controller.endDateController,
                  dateFormat: CustomDateFormat('dd/MM/yyyy'),
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    hintText: 'dd/mm/yyyy',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox.square(dimension: 16),

                // Description
                TextFormField(
                  controller: controller.descriptionController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (FormWrapper.validate(formContext)) {
                return _handleFormSubmit(context);
              }
            },
            child: const Text('Save'),
          ).fMarginSymmetric(horizontal: 16, vertical: 12),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => Future.microtask(
        () => ref.read(manageCouponViewProvider).handleManageCoupon(widget.editModel),
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
