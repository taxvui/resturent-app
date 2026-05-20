import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../components/components.dart' show OrderTypeEnum;

@RoutePage()
class OrderDetailsView extends ConsumerWidget {
  const OrderDetailsView({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _orderDetails = ref.watch(_orderDetailsProvider(orderId));

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            onPressed: () async {
              return _handleThermalPrint(
                context,
                ref,
                _orderDetails.value?.data,
              );
            },
            icon: const Icon(HugeIconsStroke.printer),
          ),
          IconButton(
            onPressed: () async {
              return _printPDFInvoice(context, ref, _orderDetails.value?.data);
            },
            icon: const Icon(HugeIconsStroke.share01),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(_orderDetailsProvider(orderId).future),
        child: _orderDetails.when(
          skipLoadingOnRefresh: false,
          data: (data) => _buildOrderInfo(context, data.data!),
          error: (error, stackTrace) {
            return EmptyWidget(
              replaceDefault: false,
              emptyBuilder: (context) {
                return RetryButtons.scrollView(
                  error,
                  onRetry: () {
                    return ref.refresh(
                      _orderDetailsProvider(orderId).future,
                    );
                  },
                );
              },
            );
          },
          loading: () {
            return Skeletonizer(
              child: _buildOrderInfo(context, Sale()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Sale data) {
    final _orderType = OrderTypeEnum.maybeFromString(data.salesType);

    final _theme = Theme.of(context);

    final _sectionHeader = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    final _descStyle = _theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final _titleStyle = _descStyle?.copyWith(
      color: const Color(0xff666666),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Info
          Text('General Info', style: _sectionHeader),
          const SizedBox.square(dimension: 12),
          ...[
            ...{
              "Order ID": data.invoiceNumber ?? "N/A",
              "Date": data.saleDate?.getFormatedString(pattern: "dd MMM yyyy hh:mm a") ?? "N/A",
              "Order Type": _orderType?.label(context) ?? "N/A",
              "Payment Type": data.paymentMethod?.name ?? "N/A",
            }.entries.map((entry) {
              return KeyValueRow(
                title: entry.key,
                titleFlex: 3,
                titleStyle: _titleStyle,
                description: entry.value,
                descriptionFlex: 6,
                descriptionStyle: _descStyle,
              );
            }),
            KeyValueRow(
              title: 'Status',
              titleFlex: 3,
              titleStyle: _titleStyle,
              description: data.hasDue ? 'Due' : 'Paid',
              descriptionFlex: 6,
              descriptionStyle: _descStyle?.copyWith(
                color: data.hasDue ? DAppColors.kWarning : DAppColors.kSuccess,
              ),
            ),
            const SizedBox.square(dimension: 6),
          ],

          // Item Info
          Text('Items Info', style: _sectionHeader),
          const SizedBox.square(dimension: 12),
          ...List.generate(
            data.details?.length ?? 0,
            (index) {
              final _item = data.details?[index];

              return DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    top: index == 0 ? Divider.createBorderSide(context) : BorderSide.none,
                    bottom: Divider.createBorderSide(context),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    vertical: -1,
                    horizontal: VisualDensity.minimumDensity,
                  ),
                  title: Text(
                    // "${_item?.product?.productName ?? 'N/A'} ${_item?.variations?.name != null ? '(${_item?.variations?.name})' : ''}",
                    // TODO: Fix this later
                    "TODO",
                  ),
                  titleTextStyle: _sectionHeader?.copyWith(fontSize: 15),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text('Qty: ${_item?.quantities ?? 0}')),
                      Expanded(
                        child: Text(
                          (_item?.price ?? 0).quickCurrency(),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  subtitleTextStyle: _descStyle,
                ),
              );
            },
          ),
          const SizedBox.square(dimension: 16),

          // Delivery Address
          if (_orderType == OrderTypeEnum.delivery) ...[
            Text('Delivery Address', style: _sectionHeader),
            const SizedBox.square(dimension: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: DAppColors.kSurfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                      vertical: VisualDensity.minimumDensity,
                      horizontal: VisualDensity.minimumDensity,
                    ),
                    title: Text(data.deliveryAddress?.name ?? "N/A"),
                    titleTextStyle: _sectionHeader?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    subtitle: Text(data.deliveryAddress?.phone ?? "N/A"),
                    subtitleTextStyle: _titleStyle,
                  ),
                  const SizedBox.square(dimension: 4),
                  Text(
                    data.deliveryAddress?.address ?? 'N/A',
                    style: _titleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox.square(dimension: 20),
          ],

          // Order Summary
          ...[
            ...{
              "Sub Total": data.subtotalAmount.quickCurrency(),
              "Discount ${data.discountPercentage ?? 0}%": (data.discountAmount ?? 0).quickCurrency(),
              "VAT ${(data.tax?.rate ?? 0).commaSeparated()}%": (data.taxAmount ?? 0).quickCurrency(),
              if (data.meta?.tip != null && data.meta!.tip! > 0) "Tip": (data.meta?.tip ?? 0).quickCurrency(),
              if (data.meta?.deliveryCharge != null && data.meta!.deliveryCharge! > 0)
                "Delivery Charge": (data.meta?.deliveryCharge ?? 0).quickCurrency(),
            }.entries.map((entry) {
              return Row(
                children: [
                  Expanded(child: Text(entry.key, style: _titleStyle)),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.end,
                      style: _titleStyle,
                    ),
                  ),
                ],
              ).fMarginOnly(bottom: 8);
            }),
            Row(
              children: [
                Expanded(child: Text('Total', style: _sectionHeader)),
                Expanded(
                  child: Text(
                    (data.totalAmount ?? 0).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _sectionHeader,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleThermalPrint(BuildContext context, WidgetRef ref, Sale? sale) async {
    if (sale == null) return _showNulledError(context);

    try {
      await ref.read(
        saleThermalInvoiceProvider((
          sale: SalePurchaseThermalInvoiceData.fromSale(sale),
          printKOT: false,
        )).future,
      );
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return;
      }
    }
  }

  Future<void> _printPDFInvoice(
    BuildContext context,
    WidgetRef ref,
    Sale? sale,
  ) async {
    if (sale == null) return _showNulledError(context);

    return await showAsyncLoadingOverlay<void>(
      context,
      asyncFunction: () {
        return SharedWidgets.openFile(context, () {
          return ref.read(
            salePurchaseInvoicePDFProvider(
              SalePurchaseThermalInvoiceData.fromSale(sale),
            ).future,
          );
        });
      },
    );
  }

  void _showNulledError(BuildContext context) {
    showCustomSnackBar(
      context,
      content: Text('Invalid sale data.\nPlease try again.'),
    );
  }
}

final _orderDetailsProvider = FutureProvider.autoDispose.family<SaleDetailsModel, int>(
  (ref, id) => Future.microtask(
    () => ref.read(saleRepoProvider).getSaleDetails(id),
  ),
);
