import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';

part '_manage_due_collection_provider.dart';

@RoutePage()
class ManageDueCollectionView extends ConsumerStatefulWidget {
  const ManageDueCollectionView({super.key, required this.collection});
  final DueCollection collection;

  @override
  ConsumerState<ManageDueCollectionView> createState() => _ManageDueCollectionViewState();
}

class _ManageDueCollectionViewState extends ConsumerState<ManageDueCollectionView> {
  @override
  void initState() {
    ref.read(manageDueCollectionProvider).initEdit(widget.collection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageDueCollectionProvider);
    final _supplierListAsync = ref.watch(supplierDropdownProvider);
    final hasParty = widget.collection.partyId != null;

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(title: const Text('Due Collection')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Invoice Number & Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Number
                    Expanded(
                      child: TextFormField(
                        controller: controller.invoiceNumberController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Order No',
                          hintText: 'P-00001',
                        ),
                      ),
                    ),
                    const SizedBox.square(dimension: 16),

                    // Invoice Date
                    Expanded(
                      child: DateFormField(
                        controller: controller.invoiceDateController,
                        dateFormat: CustomDateFormat('dd/MM/yyyy'),
                        decoration: const InputDecoration(
                          labelText: 'Date',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20),

                // Party Dropdown
                if (!widget.collection.isPurchaseDue) ...[
                  TextFormField(
                    readOnly: true,
                    initialValue: widget.collection.party?.name ?? "Walk-in Customer",
                    decoration: const InputDecoration(labelText: 'Customer'),
                  ),
                ] else ...[
                  AsyncCustomDropdown<int, PartyList>(
                    asyncData: _supplierListAsync,
                    decoration: const InputDecoration(
                      labelText: 'Supplier*',
                      hintText: 'Select Supplier',
                    ),
                    showClearButton: !hasParty,
                    value: controller.dropdownValues['party_id'],
                    items: _supplierListAsync.when(
                      data: (data) => [
                        ...?data.data?.data?.map((supplier) {
                          return CustomDropdownMenuItem<int>(
                            value: supplier.id,
                            label: TextSpan(text: supplier.name ?? "N/A"),
                          );
                        }),
                      ],
                      error: (e, s) => [],
                      loading: () => [],
                    ),
                    onChanged: hasParty ? null : (v) => controller.handleDropdownChange(MapEntry('party_id', v)),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please select a supplier.',
                    ),
                  ),
                ],
                const SizedBox.square(dimension: 20),

                // Invoice Overview
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      // Paid Amount
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Pay Amount',
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: InputDecorator(
                              decoration: CustomFieldStyles.kUnderlined(
                                context,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Text(
                                  controller.dueAmount.quickCurrency(),
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox.square(dimension: 16),

                      // Received Amount
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: SizedBox.square(
                                      dimension: 16,
                                      child: Checkbox(
                                        value: controller.isReceived,
                                        onChanged: controller.toggleIsReceived,
                                      ),
                                    ).fMarginOnly(right: 6),
                                  ),
                                  const TextSpan(text: 'Received'),
                                ],
                              ),
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                color: _theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: NumberFormField(
                              controller: controller.receivedAmountController,
                              textAlign: TextAlign.end,
                              decoration: CustomFieldStyles.kUnderlined(
                                context,
                                hinText: 'Ex: \$200',
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.notZeroNumber(),
                                FormBuilderValidators.positiveNumber(),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox.square(dimension: 16),

                      // Balance Due
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              controller.isChangeAmount ? 'Change Amount' : 'Remaining Due',
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (controller.isChangeAmount ? controller.changeAmount : controller.balanceDue)
                                  .quickCurrency(),
                              textAlign: TextAlign.end,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavWrapper(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Method
                PaymentSelectorFormField(
                  selectedPaymentMethod: controller.dropdownValues['payment_id'],
                  onChanged: (value) => controller.handleDropdownChange(
                    MapEntry('payment_id', value),
                  ),
                ),

                const SizedBox.square(dimension: 14),

                // Action Button
                ElevatedButton(
                  onPressed: () async {
                    final _hasPayment = PaymentSelectorFormField.validate(
                      context,
                      controller.dropdownValues['payment_id'],
                    );
                    if (FormWrapper.validate(formContext) && _hasPayment) {
                      return await _handleFormSubmit(context);
                    }
                  },
                  child: const Text('Save'),
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
      asyncFunction: () {
        return ref.read(manageDueCollectionProvider).handleManageDueCollection(widget.collection);
      },
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
