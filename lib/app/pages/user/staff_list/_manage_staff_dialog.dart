part of 'staff_list_view.dart';

class ManageStaffDialog extends ConsumerStatefulWidget {
  const ManageStaffDialog({super.key, this.editModel});
  final StaffModel? editModel;

  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageStaffDialog> createState() => _ManageStaffDialogState();
}

class _ManageStaffDialogState extends ConsumerState<ManageStaffDialog> {
  late final fullNameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneNumberController = TextEditingController(),
      addressController = TextEditingController();
  StaffTypeEnum? selectedDesignation;

  void initEdit() {
    fullNameController.text = widget.editModel?.name ?? "";
    emailController.text = widget.editModel?.email ?? "";
    phoneNumberController.text = widget.editModel?.phone ?? "";
    addressController.text = widget.editModel?.address ?? "";
    selectedDesignation = StaffTypeEnum.fromString(
      widget.editModel?.designation,
    );
  }

  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          backgroundColor: _theme.colorScheme.surface,
          child: BottomModalSheetWrapper(
            title: TextSpan(
              // text: widget.isEditMode ? "Update Staff" : "Add New Staff",
              text: widget.isEditMode
                  ? context.t.pages.staffs.manageStaff.title2
                  : context.t.pages.staffs.manageStaff.title1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full Name
                        TextFormField(
                          controller: fullNameController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          decoration: InputDecoration(
                            // labelText: 'Full Name*',
                            labelText: "${context.t.form.fullName.label}*",
                            // hintText: 'Enter full name',
                            hintText: context.t.form.fullName.hint,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              // return 'Please enter full name';
                              return context.t.form.fullName.errors.required;
                            }

                            return null;
                          },
                        ),
                        const SizedBox.square(dimension: 16),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            // labelText: 'Email*',
                            labelText: '${context.t.form.email.label}*',
                            // hintText: 'Enter email',
                            hintText: context.t.form.email.hint,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              // return 'Please enter email address';
                              return context.t.form.email.errors.required;
                            }
                            if (!value.isEmail) {
                              // return '⦸ Invalid Email, Please Try Again';
                              return context.t.form.email.errors.invalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox.square(dimension: 16),

                        // Phone Number
                        TextFormField(
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            // labelText: 'Phone Number*',
                            labelText: '${context.t.form.phone.label}*',
                            // hintText: 'Enter phone number',
                            hintText: context.t.form.phone.hint,
                          ),
                          validator: FormBuilderValidators.phoneNumber(
                            // errorText: 'Please enter phone number.',
                            errorText: context.t.form.phone.errors.required,
                          ),
                        ),
                        const SizedBox.square(dimension: 16),

                        // Address
                        TextFormField(
                          controller: addressController,
                          keyboardType: TextInputType.text,
                          autofillHints: const [AutofillHints.fullStreetAddress],
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            // labelText: 'Address',
                            labelText: context.t.form.address.label,
                            // hintText: 'Enter address',
                            hintText: context.t.form.address.hint,
                          ),
                        ),
                        const SizedBox.square(dimension: 16),

                        // Designation List
                        CustomDropdown<StaffTypeEnum>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            // labelText: 'Designation*',
                            labelText: "${context.t.form.designation.label}*",
                            // hintText: 'Select a designation',
                            hintText: context.t.form.designation.hint,
                          ),
                          value: selectedDesignation,
                          items: List.generate(
                            StaffTypeEnum.values.length,
                            (index) {
                              final _value = StaffTypeEnum.values[index];
                              return CustomDropdownMenuItem<StaffTypeEnum>(
                                value: _value,
                                label: TextSpan(text: _value.label(context)),
                              );
                            },
                          ),
                          onChanged: (value) => setState(
                            () => selectedDesignation = value,
                          ),
                          validator: (value) {
                            if (value == null) {
                              // return 'Please select a designation.';
                              return context.t.form.designation.errors.required;
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return _handleFormSubmit(context);
                    }
                  },
                  // child: const Text('Save'),
                  child: Text(context.t.action.save),
                ).fMarginAll(16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _data = (widget.editModel ?? StaffModel()).copyWith(
      name: fullNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      address: addressController.text,
      designation: selectedDesignation?.stringValue,
    );
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () {
        return ref.read(staffDesignationRepoProvider).manageStaff(_data);
      },
    );

    if (context.mounted) {
      if (_result.isFailure) {
        showCustomSnackBar(
          context,
          content: Text(_result.left!),
          customSnackBarType: CustomOverlayType.error,
        );
        return Navigator.of(context).pop();
      }

      return Navigator.of(context).pop(_result.right);
    }
  }
}
