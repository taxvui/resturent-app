import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../common/widgets/widgets.dart';

part 'full_payment_option/_full_payment_option.dart';
part 'due_payment_option/_due_payment_option.dart';

abstract class PaymentOptionWidgetBase extends ConsumerWidget {
  const PaymentOptionWidgetBase({super.key, required this.option});
  final PaymentOptionEnum option;

  Widget paymentMethodListWidget({
    required int? selectedId,
    ValueChanged<int>? onSelected,
  }) {
    return SizedBox(
      height: 44,
      child: Consumer(
        builder: (_, ref, _) {
          final _paymentMethodAsync = ref
              .watch(businessPaymentMethodDropdownProvider)
              .whenData(
                (list) => [...?list.data?.data],
              );

          return AsyncLisViewBuilder<BusinessPaymentMethod>(
            asyncData: _paymentMethodAsync,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            itemBuilder: (context, item, index) {
              return SelectedButton.outlined(
                isSelected: selectedId == item.id,
                onPressed: () => onSelected?.call(item.id!),
                child: Text(item.name ?? "N/A"),
              );
            },
            placeholderItem: BusinessPaymentMethod(),
            emptyListBuilder: (context) {
              return Center(
                child: Text.rich(
                  RetryButtons.inlineText(
                    'No payment method found!\n',
                    onRetry: () async {
                      return await context.router.push<void>(
                        ManageBusinessPaymentMethodRoute(),
                      );
                    },
                    buttonText: 'Add payment',
                    icon: const Icon(Icons.add),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
            errorBuilder: (error, stackTrace) {
              return Center(
                child: Text.rich(
                  RetryButtons.inlineText(
                    error,
                    onRetry: () => ref.invalidate(
                      businessPaymentMethodDropdownProvider,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget orderSummary({bool showTotal = true}) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(option.provider);

        final _theme = Theme.of(context);

        final _sectionHeader = _theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );

        final _descStyle = _theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );
        final _titleStyle = _descStyle?.copyWith(
          color: const Color(0xff666666),
          fontWeight: FontWeight.w500,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            Row(
              children: [
                Expanded(child: Text("Sub Total", style: _titleStyle)),
                Expanded(
                  child: Text(
                    controller.itemSubtotal.quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _titleStyle,
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 10),

            // Discount
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Discount ${controller.discountAmount.quickCurrency()}',
                    style: _titleStyle,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 105,
                    minWidth: 75,
                  ),
                  child: RateSelectorFormField(
                    showModifierSelector: false,
                    baseAmount: controller.itemSubtotal,
                    selectedModifier: RateModifierData(type: RateModifierEnum.percent),
                    controller: controller.discountController,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 10),

            // Coupon
            if (controller.coupon != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Coupon ${controller.couponDiscount.couponPercent.commaSeparated()}% ",
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              onTap: () => controller.setCoupon(null),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: _titleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.couponDiscount.couponAmount.quickCurrency(),
                      textAlign: TextAlign.end,
                      style: _titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 10),
            ],

            // VAT
            if (controller.vatPercent > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "VAT ${controller.vatPercent}%",
                      style: _titleStyle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.vatAmount.quickCurrency(),
                      textAlign: TextAlign.end,
                      style: _titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 10),
            ],

            // Delivery Charge
            if (controller.deliveryCharge > 0) ...[
              Row(
                children: [
                  Expanded(child: Text("Delivery Charge", style: _titleStyle)),
                  Expanded(
                    child: Text(
                      controller.deliveryCharge.quickCurrency(),
                      textAlign: TextAlign.end,
                      style: _titleStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox.square(dimension: 10),
            ],

            if (controller.tipAmount > 0) ...[
              DefaultTextStyle(
                style: TextStyle().merge(
                  _titleStyle?.copyWith(color: DAppColors.kSuccess),
                ),
                child: Row(
                  children: [
                    Expanded(child: const Text('Add Tip')),
                    Expanded(
                      child: Text(
                        controller.tipAmount.quickCurrency(),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 8),
            ],
            if (showTotal) ...[
              Row(
                children: [
                  Expanded(child: Text('Total', style: _sectionHeader)),
                  Expanded(
                    child: Text(
                      controller.netPayable.quickCurrency(),
                      textAlign: TextAlign.end,
                      style: _sectionHeader,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget tipSelectorBuilder() {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(option.provider);
        final _theme = Theme.of(context);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Add Tip  ',
                    recognizer: TapGestureRecognizer()..onTap = controller.toggleShowTipField,
                    style: _theme.textTheme.bodyMedium?.copyWith(
                      color: _theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SizedBox.square(
                      dimension: 16,
                      child: Checkbox(
                        value: controller.showTipField,
                        onChanged: controller.toggleShowTipField,
                      ),
                    ).fMarginOnly(right: 6),
                  ),
                ],
              ),
            ),
            if (controller.showTipField) ...[
              const SizedBox.square(dimension: 8),
              NumberFormField(
                controller: controller.tipAmountController,
                decoration: const InputDecoration(
                  hintText: 'Ex: \$10',
                ),
              ),
            ],
            const SizedBox.square(dimension: 16),
          ],
        );
      },
    );
  }

  Widget couponSelectorBuilder() {
    return Consumer(
      builder: (context, ref, _) {
        final _theme = Theme.of(context);
        return GestureDetector(
          onTap: () async {
            final _result = await showCouponListModal(context);

            if (_result != null) {
              return ref.read(option.provider).setCoupon(_result);
            }
          },
          child: Text.rich(
            TextSpan(
              // text: 'Coupon ',
              text: '${t.common.coupon} ',
              children: [
                WidgetSpan(
                  child: UniversalImage(
                    DAppSvgIcons.discountFlag.svgPath,
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      DAppColors.kSuccess,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            style: _theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: DAppColors.kSuccess,
            ),
          ),
        );
      },
    );
  }
}

abstract class PaymentOptionWidgetBaseNotifier extends ChangeNotifier {
  PaymentOptionWidgetBaseNotifier(this.ref, {required this.paymentOption});
  final Ref ref;
  final PaymentOptionEnum paymentOption;

  //--------------Form Fields----------------------//
  int? selectedPaymentMethod;
  void selectPaymentMethod(int id) {
    selectedPaymentMethod = id;
    notifyListeners();
  }

  late final discountController = TextEditingController()..addListener(_updatedDiscount);

  num get discountAmount {
    final _discountPercent = discountController.getNumber ?? 0;
    final _discountAmount = (itemSubtotal * _discountPercent) / 100;

    return _discountAmount;
  }

  void _updatedDiscount() {
    discountAmount;
    notifyListeners();
  }

  CouponModel? coupon;
  void setCoupon(CouponModel? coupon) {
    this.coupon = coupon;
    notifyListeners();
  }

  CouponDiscountData get couponDiscount {
    num _couponAmount = 0;
    num _couponPercent = 0;

    if (coupon != null) {
      final discount = coupon!.discount ?? 0;

      if (coupon!.isPercentage == true) {
        _couponPercent = discount;
        _couponAmount = (itemSubtotal * discount) / 100;
      } else {
        _couponPercent = (itemSubtotal > 0) ? (discount / itemSubtotal) * 100 : 0;
        _couponAmount = discount;
      }

      if (_couponAmount > itemSubtotal) {
        _couponAmount = itemSubtotal;
        _couponPercent = 100;
      }
    }

    return (couponAmount: _couponAmount.toFixedDecimal(), couponPercent: _couponPercent.toFixedDecimal());
  }

  bool validate(BuildContext context) {
    String? errorMsg;

    if (selectedPaymentMethod == null) {
      errorMsg = 'Please select a payment method.';
    }

    if (errorMsg != null) {
      showCustomSnackBar(
        context,
        content: Text(errorMsg),
        customSnackBarType: CustomOverlayType.error,
      );
    }

    return errorMsg == null;
  }

  num itemSubtotal = 0;
  num deliveryCharge = 0;

  TaxModel? get vatOnSale {
    return ref.watch(userRepositoryProvider).value?.business?.tax;
  }

  num get vatPercent {
    return vatOnSale?.rate ?? 0;
  }

  num get vatAmount {
    final _newAmount = itemSubtotal - (discountAmount + couponDiscount.couponAmount);
    return ((_newAmount * vatPercent) / 100).toFixedDecimal();
  }

  num tipAmount = 0;

  bool showTipField = false;
  void toggleShowTipField([bool? value]) {
    showTipField = value ?? !showTipField;
    if (!showTipField) {
      tipAmount = 0;
      tipAmountController.clear();
    }
    notifyListeners();
  }

  late final tipAmountController = TextEditingController()..addListener(_setTipAmount);
  void _setTipAmount() {
    tipAmount = (tipAmountController.getNumber ?? 0);
    notifyListeners();
  }

  num get netPayableBeforeTip {
    return (itemSubtotal - (discountAmount + couponDiscount.couponAmount)) + vatAmount + deliveryCharge;
  }

  num get netPayable {
    return netPayableBeforeTip + tipAmount;
  }

  PaymentOptionData get paymentData {
    return PaymentOptionData(
      paymentOption: paymentOption.stringValue,
      itemSubtotal: itemSubtotal,
      paymentMethodId: selectedPaymentMethod,
      discountModifier: RateModifierData(
        type: RateModifierEnum.percent,
        valueInFlat: discountAmount,
        valueInPercent: discountController.getNumber ?? 0,
      ),
      couponDiscount: couponDiscount,
      taxAmount: vatAmount,
      taxPercent: vatPercent,
      tipAmount: tipAmount,
      deliveryCharge: deliveryCharge,
    );
  }
  //--------------Form Fields----------------------//

  void initEdit(Sale sale, {bool resetState = true}) {
    itemSubtotal = sale.subtotalAmount;

    // Set Tip
    showTipField = sale.meta?.tip != null && sale.meta!.tip! > 0;
    tipAmountController.text = sale.meta?.tip?.toString() ?? '';

    // Set Discount
    discountController.text = sale.discountPercentage?.toFixedDecimal().toString() ?? '';

    // Set Coupon
    coupon = sale.coupon;

    // Set Payment Method
    selectedPaymentMethod = sale.paymentTypeId;

    // Set Delivery Charge
    deliveryCharge = sale.meta?.deliveryCharge ?? 0;

    if (resetState) return notifyListeners();
  }
}

//----------------------Data Model----------------------//
typedef PaymentOptionWidgetBaseProvider<T extends PaymentOptionWidgetBaseNotifier> =
    AutoDisposeChangeNotifierProvider<T>;

class PaymentOptionData {
  final String paymentOption;
  final int? paymentMethodId;
  final num itemSubtotal;
  final RateModifierData discountModifier;
  final CouponDiscountData? couponDiscount;
  final num taxAmount;
  final num taxPercent;
  final num? tipAmount;
  final num paidAmount;
  final num deliveryCharge;

  num get netPayableBeforeTip {
    return ((itemSubtotal - (discountModifier.valueInFlat + (couponDiscount?.couponAmount ?? 0))) + taxAmount)
        .toFixedDecimal();
  }

  num get netPayable {
    return (netPayableBeforeTip + (tipAmount ?? 0) + deliveryCharge).toFixedDecimal();
  }

  num get dueAmount {
    return (netPayable - paidAmount).toFixedDecimal();
  }

  const PaymentOptionData({
    required this.paymentOption,
    this.paymentMethodId,
    this.itemSubtotal = 0,
    this.discountModifier = const RateModifierData(type: RateModifierEnum.flat),
    this.couponDiscount,
    this.taxAmount = 0,
    this.taxPercent = 0,
    this.tipAmount,
    this.paidAmount = 0,
    this.deliveryCharge = 0,
  });

  PaymentOptionData copyWith({
    String? paymentOption,
    int? paymentMethodId,
    num? itemSubtotal,
    RateModifierData? discountModifier,
    CouponDiscountData? couponDiscount,
    num? taxAmount,
    num? taxPercent,
    num? tipAmount,
    num? paidAmount,
    num? deliveryCharge,
  }) {
    return PaymentOptionData(
      paymentOption: paymentOption ?? this.paymentOption,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      itemSubtotal: itemSubtotal ?? this.itemSubtotal,
      discountModifier: discountModifier ?? this.discountModifier,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      tipAmount: tipAmount ?? this.tipAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
    );
  }

  @override
  String toString() {
    return '''PaymentOptionData(
            paymentOption: $paymentOption,
            paymentMethodId: $paymentMethodId,
            subtotal: $itemSubtotal,
            discountModifier: $discountModifier,
            taxAmount: $taxAmount,
            taxPercent: $taxPercent,
            tipAmount: $tipAmount,
            paidAmount: $paidAmount
          ''';
  }
}

enum PaymentOptionEnum {
  fullPayment,
  duePayment;

  String label(BuildContext context) {
    return switch (this) {
      // fullPayment => 'Full Payment',
      fullPayment => context.t.common.fullPayment,
      // duePayment => 'Due Payment',
      duePayment => context.t.common.duePayment,
    };
  }

  static PaymentOptionEnum? maybeFromString(String? value) {
    return switch (value) {
      'full_payment' => fullPayment,
      'due_payment' => duePayment,
      _ => null,
    };
  }

  static PaymentOptionEnum fromString(String? value) {
    return maybeFromString(value) ?? fullPayment;
  }

  String get stringValue {
    return switch (this) {
      fullPayment => 'full_payment',
      duePayment => 'due_payment',
    };
  }

  PaymentOptionWidgetBaseProvider get provider {
    return switch (this) {
      fullPayment => fullPaymentOptionProvider,
      duePayment => duePaymentOptionProvider,
    };
  }

  PaymentOptionWidgetBase childBuilder() {
    return switch (this) {
      fullPayment => const FullPaymentOptionWidget(),
      duePayment => const DuePaymentOptionWidget(),
    };
  }
}

typedef CouponDiscountData = ({num couponAmount, num couponPercent});
//----------------------Data Model----------------------//
