import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../components/components.dart';

@RoutePage()
class OrderPaymentView extends ConsumerStatefulWidget {
  const OrderPaymentView({super.key, required this.saleData});
  final Sale saleData;
  bool get instantSale => !saleData.isKOT;
  OrderTypeEnum get saleType => OrderTypeEnum.fromString(saleData.salesType);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrderPaymentViewState();
}

class _OrderPaymentViewState extends ConsumerState<OrderPaymentView> {
  late final ValueNotifier<PaymentOptionEnum> selectedPaymentOption;

  @override
  void initState() {
    selectedPaymentOption = ValueNotifier(PaymentOptionEnum.fromString(widget.saleData.meta?.paymentType));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedPaymentOption.value.provider).initEdit(widget.saleData);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        // title: const Text('Payment'),
        title: Text(context.t.common.payment),
        actions: [
          if (widget.saleData.invoiceNumber != null) ...[
            Text(
              // 'Order ${widget.saleData.invoiceNumber ?? "N/A"}',
              '${context.t.common.order} ${widget.saleData.invoiceNumber ?? "N/A"}',
              style: _theme.textTheme.bodyMedium?.copyWith(
                color: _theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox.square(dimension: 16),
          ],
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPaymentOption,
        builder: (_, selectedPaymentMethod, _) {
          return Column(
            children: [
              // Payment Options
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PaymentOptionEnum.values.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemBuilder: (_, index) {
                    final _paymentOption = PaymentOptionEnum.values[index];
                    final _isSeleceted = selectedPaymentMethod == _paymentOption;

                    return SelectedButton(
                      onPressed: () {
                        if (selectedPaymentMethod == _paymentOption) return;
                        selectedPaymentOption.set(_paymentOption);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(selectedPaymentOption.value.provider).initEdit(widget.saleData, resetState: true);
                        });
                      },
                      isSelected: _isSeleceted,
                      child: Text(_paymentOption.label(context)),
                    );
                  },
                  separatorBuilder: (_, _) {
                    return const SizedBox.square(dimension: 10);
                  },
                ),
              ),

              // Payment Contents
              Flexible(
                child: SingleChildScrollView(
                  child: selectedPaymentMethod.childBuilder(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavWrapper(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            if (!ref.read(selectedPaymentOption.value.provider).validate(context)) {
              return;
            }

            return _handlePaymentSubmit(context);
          },
          // child: const Text('Pay Now'),
          child: Text(context.t.common.payNow),
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> _handlePaymentSubmit(BuildContext context) async {
    final controller = ref.watch(selectedPaymentOption.value.provider);
    final repo = ref.read(saleRepoProvider);

    final data = controller.paymentData;

    final _updatedSaleData = widget.saleData.copyWith(
      isKOT: false,
      couponId: controller.coupon?.id,
      paidAmount: data.paidAmount,
      discountAmount: data.discountModifier.valueInFlat,
      discountPercentage: data.discountModifier.valueInPercent,
      discountType: data.discountModifier.type.key,
      couponAmount: data.couponDiscount?.couponAmount,
      couponPercentage: data.couponDiscount?.couponPercent,
      taxId: controller.vatOnSale?.id,
      taxAmount: controller.vatAmount,
      taxPercentage: controller.vatPercent,
      paymentTypeId: data.paymentMethodId,
      totalAmount: data.netPayable,
      dueAmount: data.dueAmount,
      meta: SaleMeta(
        tip: data.tipAmount,
        paymentType: selectedPaymentOption.value.stringValue,
        deliveryCharge: data.deliveryCharge,
      ),
    );

    final _executable = widget.instantSale ? repo.manageSale : repo.completePendingPayment;

    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => Future.microtask(
        () => switch (widget.saleType) {
          OrderTypeEnum.orderQuotation => repo.manageQuotation(Quotation.fromSale(_updatedSaleData)),
          _ => _executable(_updatedSaleData),
        },
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

      // Reload the table dropdown to update table staus
      final _responseData = _result.right;
      if (_responseData is BaseDetailsModel<Sale> && _responseData.data?.tableId != null) {
        ref.invalidate(tableDropdownProvider);
      }
      context.router.maybePop(_responseData);
      context.router.push(
        InvoicePreviewRoute(
          previewType: ThermalPreview(
            SalePurchaseThermalInvoiceData.fromSale((_responseData as BaseDetailsModel<Sale>?)!.data!),
            isSale: true,
          ),
        ),
      );
    }
  }
}
