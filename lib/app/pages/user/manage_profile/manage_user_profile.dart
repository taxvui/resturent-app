import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../i18n/strings.g.dart';
import '../../../widgets/widgets.dart';
import '../../../routes/app_routes.gr.dart';
import '../../../data/repository/repository.dart';

part 'pages/edit_profile/edit_profile_view.dart';
part 'pages/setup_profile/setup_profile_view.dart';
part '_manage_user_profile_provider.dart';

class BusinessProfileFormFields extends ConsumerWidget {
  const BusinessProfileFormFields({
    super.key,
    this.fromSetupProfile = false,
    this.enableEdit = true,
  });
  final bool enableEdit;
  final bool fromSetupProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(manageUserProfileProvider);
    final businessCategories = ref.watch(businessCategoriesProvider);

    return Column(
      children: [
        AsyncCustomDropdown<int, BusinessCategoryModel>(
          asyncData: businessCategories,
          onRefresh: () => ref.refresh(businessCategoriesProvider),
          isExpanded: true,
          showClearButton: enableEdit,
          decoration: InputDecoration(
            labelText: '${context.t.form.profile.businessCategory.label}*',
            hintText: context.t.form.profile.businessCategory.hint,
          ),
          value: controller.selectedBusinessCategory,
          items: businessCategories.when(
            data: (data) => [
              ...?data.data?.map((category) {
                return CustomDropdownMenuItem<int>(
                  value: category.id,
                  label: TextSpan(text: category.name ?? 'N/A'),
                );
              }),
            ],
            error: (e, st) => [],
            loading: () => [],
          ),
          onChanged: !enableEdit ? null : controller.selectBusinessCategory,
          validator: (value) {
            if (value == null || value <= 0) {
              return context.t.form.profile.businessCategory.errors.required;
            }
            return null;
          },
        ),
        const SizedBox.square(dimension: 20),

        // Shop/Store Name*
        TextFormField(
          enabled: enableEdit,
          controller: controller.shopNameController,
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.organizationName],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '${context.t.form.profile.shopOrStore.label}*',
            hintText: context.t.form.profile.shopOrStore.hint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.t.form.profile.shopOrStore.errors.required;
            }
            return null;
          },
        ),
        const SizedBox.square(dimension: 20),

        // Phone Number
        TextFormField(
          enabled: enableEdit,
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
          enabled: enableEdit,
          controller: controller.shopAddressController,
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.fullStreetAddress],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.t.form.address.label,
            hintText: context.t.form.address.hint,
          ),
        ),
        const SizedBox.square(dimension: 20),

        // Opening Balance
        NumberFormField(
          enabled: enableEdit,
          controller: controller.openingBalanceController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: context.t.form.profile.openingBalance.label,
            hintText: context.t.form.profile.openingBalance.hint,
          ),
        ),
        const SizedBox.square(dimension: 20),

        // VAT / GST
        if (!fromSetupProfile)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: enableEdit,
                  controller: controller.vatGstTitleController,
                  decoration: InputDecoration(
                    labelText: context.t.form.profile.vatGstTitle.label,
                    hintText: context.t.form.profile.vatGstTitle.hint,
                  ),
                  /*
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter VAT/GST title';
                  }
                  return null;
                },
                */
                ),
              ),
              const SizedBox.square(dimension: 16),
              Expanded(
                child: TextFormField(
                  enabled: enableEdit,
                  controller: controller.vatGstNumberController,
                  decoration: InputDecoration(
                    labelText: context.t.form.profile.vatGstNumber.label,
                    hintText: context.t.form.profile.vatGstNumber.hint,
                  ),
                  /*
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter VAT/GST number';
                  }
                  return null;
                },
                */
                ),
              ),
            ],
          ),
      ],
    );
  }
}
