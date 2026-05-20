import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../core/core.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../common/widgets/widgets.dart';
import '../components/components.dart';
import '../../../../widgets/widgets.dart';

part '_manage_party_view_provider.dart';

@RoutePage()
class ManagePartyView extends ConsumerStatefulWidget {
  const ManagePartyView({super.key, this.editModel});
  final Party? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManagePartyView> createState() => _ManagePartyViewState();
}

class _ManagePartyViewState extends ConsumerState<ManagePartyView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(managePartyViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(managePartyViewProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(widget.isEditMode ? context.t.pages.parties.editParties : context.t.pages.parties.addParties),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Party Image & Party Type
                Row(
                  children: [
                    // Party Image
                    Expanded(
                      child: ImageFormField(
                        initialValue: controller.avatarImage,
                        previewSize: const Size.square(70),
                        decoration: ImageFieldDecoration(
                          // hintText: TextSpan(text: 'Upload'),
                          hintText: TextSpan(text: context.t.common.upload),
                        ),
                        onSelectImage: controller.handleAvatarImage,
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          ...PartyType.values.map(
                            (type) {
                              final _isSelected = controller.selectedPartyType == type;
                              return Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: SizedBox.square(
                                        dimension: 16,
                                        child: Checkbox(
                                          value: _isSelected,
                                          onChanged: (_) => controller.handleChangingPartyType(type),
                                        ),
                                      ).fMarginOnly(right: 8),
                                    ),
                                    TextSpan(
                                      text: type.label(context),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => controller.handleChangingPartyType(type),
                                    ),
                                  ],
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    color: _isSelected ? null : _theme.paragraphColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20),

                // Party Name
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.parties.partyName.label,
                    hintText: context.t.form.parties.partyName.hint,
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.form.parties.partyName.error.required,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Party Phone
                TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.parties.partyPhone.label,
                    hintText: context.t.form.parties.partyPhone.hint,
                  ),
                  validator: FormBuilderValidators.phoneNumber(
                    errorText: context.t.form.parties.partyPhone.error.required,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Opening Balance
                if (controller.selectedPartyType == PartyType.supplier) ...[
                  NumberFormField(
                    controller: controller.openingBalanceController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.t.form.profile.openingBalance.label,
                      hintText: context.t.form.profile.openingBalance.hint,
                    ),
                  ),
                  const SizedBox.square(dimension: 20),
                ],

                // Email Address
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.email.label,
                    hintText: context.t.form.email.hint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;

                    return FormBuilderValidators.email()(value);
                  },
                ),
                const SizedBox.square(dimension: 20),

                // Address
                TextFormField(
                  controller: controller.addressController,
                  keyboardType: TextInputType.streetAddress,
                  autofillHints: const [AutofillHints.fullStreetAddress],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.t.form.address.label,
                    hintText: context.t.form.address.hint,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Delivery Addresss
                if (controller.selectedPartyType == PartyType.customer) ...[
                  // Header
                  Row(
                    children: [
                      Icon(
                        HugeIconsStroke.building06,
                        size: 20,
                        color: _theme.colorScheme.primary,
                      ),
                      const SizedBox.square(dimension: 6),
                      Expanded(
                        child: Text(
                          'Delivery Address',
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          return showManageCustomerAddressModal(
                            context,
                            onSave: (context, data) {
                              Navigator.of(context).pop();
                              return controller.handleCustomerAddress(data);
                            },
                          );
                        },
                        padding: EdgeInsets.zero,
                        child: Text(
                          // '+ Add New',
                          "+ ${context.t.common.addNew}",
                          style: _theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Address List
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: List.generate(controller.customerAddressList.length, (index) {
                      final _data = controller.customerAddressList[index];

                      return CustomerAddressCard.action(
                        data: _data,
                        onEdit: () async {
                          return showManageCustomerAddressModal(
                            context,
                            editModel: _data,
                            onSave: (context, data) {
                              Navigator.of(context).pop();
                              return controller.handleCustomerAddress(data, index);
                            },
                          );
                        },
                        onDelete: () {
                          return controller.handleCustomerAddress(
                            null,
                            index,
                          );
                        },
                      );
                    }),
                  ),
                ],
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
      asyncFunction: () => ref
          .read(managePartyViewProvider)
          .handleManageParty(
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
