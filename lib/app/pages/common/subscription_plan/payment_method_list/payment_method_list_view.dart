import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';

@RoutePage()
class PaymentMethodListView extends StatefulWidget {
  const PaymentMethodListView({super.key});

  @override
  State<PaymentMethodListView> createState() => _PaymentMethodListViewState();
}

class _PaymentMethodListViewState extends State<PaymentMethodListView> {
  final paymentTypeList = {
    'Paypal': PaymentMethodIcon.paypalIcon,
    'Stripe': PaymentMethodIcon.stripeIcon,
    'Paytm': PaymentMethodIcon.paytmIcon,
    'Razorpay': PaymentMethodIcon.rezorpayIcon,
    'Paystack': PaymentMethodIcon.payStackIcon,
    'Flutterwave': PaymentMethodIcon.flutterWaveIcon,
    'SSL Commerce': PaymentMethodIcon.ssslCommarzIcon,
    'Payonline': PaymentMethodIcon.payOnlineIcon,
  };
  int selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.payment.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: RadioGroup<int>(
          groupValue: selectedMethod,
          onChanged: (v) => setState(() => selectedMethod = v!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                context.t.pages.payment.selectPaymentMethod,
                style: _theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox.square(dimension: 11),

              // Payment Method
              ...paymentTypeList.entries.toList().asMap().entries.map((entry) {
                return RadioListTile<int>(
                  value: entry.key,
                  controlAffinity: ListTileControlAffinity.trailing,
                  tileColor: _theme.colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                  ),
                  title: Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints.tightFor(
                          width: 84,
                          height: 52,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: entry.value.value.baseColor?.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: UniversalImage(entry.value.value.svgPath),
                      ),
                      const SizedBox.square(dimension: 14),
                      Expanded(child: Text(entry.value.key)),
                    ],
                  ),
                ).fMarginOnly(bottom: 10);
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {},
        child: Text(context.t.action.kContinue),
      ).fMarginSymmetric(horizontal: 16, vertical: 12),
    );
  }
}
