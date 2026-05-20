import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';

part '_purchase_payment_receive_view_provider.dart';

@RoutePage()
class PurchasePaymentReceiveView extends ConsumerWidget {
  const PurchasePaymentReceiveView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(purchasePaymentReceiveViewProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(context.t.common.paymentReceived),
          ),
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
                        decoration: InputDecoration(
                          labelText: context.t.common.orderNo,
                        ),
                      ),
                    ),

                    const SizedBox.square(dimension: 16),

                    // Invoice Date
                    Expanded(
                      child: DateFormField(
                        controller: controller.invoiceDateController,
                        dateFormat: CustomDateFormat('dd/MM/yyyy'),
                        decoration: InputDecoration(
                          labelText: context.t.common.date,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 20),

                // Supplier Dropdown
                DropdownButtonFormField<int>(
                  hint: Text(context.t.common.selectSupplier),
                  decoration: InputDecoration(
                    labelText: context.t.common.supplier,
                    filled: true,
                    fillColor: _theme.colorScheme.outline.withValues(alpha: 0.10),
                  ),
                  initialValue: controller.dropdownValues['supplier'],
                  items: List.generate(
                    5,
                    (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('${context.t.common.supplier} ${index + 1}'),
                      );
                    },
                  ),
                  onChanged: null,
                ),
                const SizedBox.square(dimension: 20),

                // Invoice Overview
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _theme.colorScheme.primaryContainer,
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
                              context.t.common.paidAmount,
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
                                  4000.quickCurrency(),
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
                                  TextSpan(
                                    // text: 'Received',
                                    text: context.t.common.received,
                                    recognizer: TapGestureRecognizer()..onTap = controller.toggleIsReceived,
                                    style: _theme.textTheme.bodyLarge?.copyWith(
                                      color: _theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: controller.receivedAmountController,
                              keyboardType: TextInputType.number,
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
                              context.t.common.balanceDue,
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              2000.quickCurrency(),
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
                  onChanged: (value) {},
                ),

                const SizedBox.square(dimension: 14),

                // Action Button
                ElevatedButton(
                  onPressed: () {
                    if (Form.maybeOf(formContext)?.validate() == true) {}
                  },
                  child: Text(context.t.action.save),
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }
}
