import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';

part '_customer_address_card.dart';

class ManageCustomerAddressModal extends StatefulWidget {
  const ManageCustomerAddressModal({
    super.key,
    this.editModel,
    this.onSave,
  });

  final CustomerAddressData? editModel;
  final void Function(BuildContext context, CustomerAddressData data)? onSave;

  bool get isEditMode => editModel != null;

  @override
  State<ManageCustomerAddressModal> createState() => _ManageCustomerAddressModalState();
}

class _ManageCustomerAddressModalState extends State<ManageCustomerAddressModal> {
  late final fullNameController = TextEditingController();
  late final phoneController = TextEditingController();
  late final addressController = TextEditingController();

  @override
  void initState() {
    if (widget.isEditMode) {
      fullNameController.text = widget.editModel?.name ?? '';
      phoneController.text = widget.editModel?.phone ?? '';
      addressController.text = widget.editModel?.address ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      backgroundColor: _theme.colorScheme.surface,
      child: FormWrapper(
        builder: (formContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.isEditMode ? 'Update' : 'Add New'} Address',
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const CloseButton(),
                ],
              ).fMarginOnly(left: 16),

              Flexible(
                child: BottomNavWrapper(
                  backgroundColor: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        TextFormField(
                          controller: fullNameController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full Name*',
                            hintText: 'Enter full name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter full name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox.square(dimension: 16),

                        // Phone Number
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number*',
                            hintText: 'Enter phone number',
                          ),
                          validator: FormBuilderValidators.phoneNumber(
                            errorText: 'Please enter phone number.',
                          ),
                        ),
                        const SizedBox.square(dimension: 16),

                        // Addresses
                        TextFormField(
                          controller: addressController,
                          keyboardType: TextInputType.streetAddress,
                          autofillHints: const [AutofillHints.fullStreetAddress],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter address',
                          ),
                          validator: FormBuilderValidators.required(
                            errorText: 'Please enter your address.',
                          ),
                        ),
                        const SizedBox.square(dimension: 10),
                      ],
                    ),
                  ),
                ),
              ),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: Navigator.of(context).pop,
                        style: CustomButtonStyles.destructiveOutline(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (FormWrapper.validate(formContext)) {
                            final _data = (widget.editModel ?? CustomerAddressData()).copyWith(
                              name: fullNameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                            );
                            return widget.onSave?.call(context, _data);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ).fMarginLTRB(16, 0, 16, 16),
            ],
          );
        },
      ),
    );
  }
}

Future<void> showManageCustomerAddressModal(
  BuildContext context, {
  CustomerAddressData? editModel,
  void Function(BuildContext context, CustomerAddressData data)? onSave,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (popContext) {
      return ManageCustomerAddressModal(
        editModel: editModel,
        onSave: onSave,
      );
    },
  );
}

class CustomerAddressData {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;

  const CustomerAddressData({
    this.id,
    this.name,
    this.phone,
    this.address,
  });

  CustomerAddressData copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
  }) {
    return CustomerAddressData(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
