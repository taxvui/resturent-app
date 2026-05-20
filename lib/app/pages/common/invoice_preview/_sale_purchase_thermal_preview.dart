part of 'invoice_preview_view.dart';

class SalePurchaseThermalInvoicePreview extends ConsumerWidget {
  const SalePurchaseThermalInvoicePreview(this.data, {super.key});
  final SalePurchaseThermalInvoiceData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _data = data.copyWith(
      user: ref.read(userRepositoryProvider).value,
    );

    final _theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              // Logo
              Center(
                child: SizedBox.square(
                  dimension: 48,
                  child: CustomNetworkImage(
                    url: _data.user?.invoiceLogo?.remote,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox.square(dimension: 4),

              // Store Name
              Text(
                _data.user?.business?.companyName ?? 'N/A',
                style: _theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox.square(dimension: 4),

              // Store Address
              Text(
                '${context.t.common.address}: ${_data.user?.business?.address ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 4),

              // Store Phone
              Text(
                '${context.t.common.mobile}: ${_data.user?.business?.phoneNumber ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 4),

              // Store Email
              Text(
                '${context.t.common.email}: ${_data.user?.email ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 16),
            ],
          ),
          const DashedDivider(),
          const SizedBox.square(dimension: 10),

          // Order No
          Text.rich(
            TextSpan(
              text: '${context.t.common.orderNo}: ',
              children: [
                TextSpan(
                  text: ' ${_data.invoiceNumber ?? "N/A"}',
                  style: TextStyle(
                    color: _theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              style: _theme.textTheme.bodyLarge?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
          ),

          // Table
          if (data.table != null) ...[
            Text.rich(
              TextSpan(
                text: 'Table:',
                children: [
                  TextSpan(
                    text: ' ${data.table?.name ?? "N/A"}',
                    style: TextStyle(
                      color: _theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
                style: _theme.textTheme.bodyLarge?.copyWith(
                  color: _theme.colorScheme.secondary,
                ),
              ),
            ),
          ],

          // Invoice Date
          Text.rich(
            TextSpan(
              text: '${context.t.common.dateAndTime}: ',
              children: [
                TextSpan(
                  text: ' ${_data.invoiceDate ?? "N/A"}',
                  style: TextStyle(
                    color: _theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              style: _theme.textTheme.bodyLarge?.copyWith(
                color: _theme.colorScheme.secondary,
              ),
            ),
          ),

          // Party Name
          if (_data.party != null) ...[
            Text.rich(
              TextSpan(
                text: '${context.t.common.name}: ',
                children: [
                  TextSpan(
                    text: ' ${_data.party?.name ?? "N/A"}',
                    style: TextStyle(
                      color: _theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
                style: _theme.textTheme.bodyLarge?.copyWith(
                  color: _theme.colorScheme.secondary,
                ),
              ),
            ),
          ],

          // Order Type
          if (_data.orderType != null) ...[
            Text.rich(
              TextSpan(
                text: '${context.t.common.orderType}: ',
                children: [
                  TextSpan(
                    text: ' ${_data.orderType?.label(context) ?? "N/A"}',
                    style: TextStyle(
                      color: _theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
                style: _theme.textTheme.bodyLarge?.copyWith(
                  color: _theme.colorScheme.secondary,
                ),
              ),
            ),
          ],

          const SizedBox.square(dimension: 10),
          const DashedDivider(),
          // Items
          InvoiceItemTable(items: [...?_data.items]),
          const SizedBox.square(dimension: 10),

          // Sub Total
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t.common.subTotal} (${_data.items?.length ?? 0} ${context.t.common.items}):',
                  style: _theme.textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Text(
                  (_data.subtotal ?? 0).quickCurrency(),
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 4),

          // Discount
          if (_data.hasDiscount) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.t.common.discount} ${_data.discountPercent?.commaSeparated() ?? 0}% :',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    ((_data.discountAmount ?? 0)).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 4),
          ],

          // Coupon
          if (_data.coupon != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_data.coupon?.code ?? context.t.common.coupon} ${_data.coupon?.discountPercent.commaSeparated() ?? 0}% :',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    ((_data.coupon?.discountAmount ?? 0)).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 4),
          ],

          // VAT
          if (_data.vatPercent != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_data.vat?.name ?? context.t.common.vat} ${_data.vatPercent?.commaSeparated() ?? 0}% :',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    ((_data.vatAmount ?? 0)).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 4),
          ],

          // Tip
          if (_data.hasTip) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.t.common.tip}: ',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    ((_data.tipAmount ?? 0)).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 4),
          ],

          // Delivery Charge
          if (_data.hasDeliveryCharge) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.t.common.deliveryCharge}: ',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    ((_data.deliveryCharge ?? 0)).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 4),
          ],
          const SizedBox.square(dimension: 6),
          const DashedDivider(),
          const SizedBox.square(dimension: 6),

          // Total Amount
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t.common.totalAmount} :',
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  (data.totalAmount ?? 0).quickCurrency(),
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 6),
          const DashedDivider(),
          const SizedBox.square(dimension: 2),
          const DashedDivider(),
          const SizedBox.square(dimension: 6),

          // Paid Amount
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t.common.paidAmount}:',
                  style: _theme.textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Text(
                  (data.paidAmount ?? 0).quickCurrency(),
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 6),

          // Due Amount
          if (data.hasDue) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.t.common.dueAmount}:',
                    style: _theme.textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    (data.dueAmount ?? 0).quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 6),
          ],

          // Payment Method
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t.common.paymentType}:',
                  style: _theme.textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Text(
                  _data.paymentMethod ?? "N/A",
                  textAlign: TextAlign.end,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 40),

          // Footer
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Column(
              children: [
                if (_data.user?.gratitudeMessage != null) ...[
                  // Gratitude Message
                  Text(
                    _data.user?.gratitudeMessage ?? '',
                    textAlign: TextAlign.center,
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox.square(dimension: 8),
                ],

                // QR Code
                SizedBox.square(
                  dimension: 80,
                  child: QrImageView(
                    data: _data.user?.developByLink ?? AppConfig.orgDomain,
                  ),
                ),

                // Developped By
                Text(
                  '${_data.user?.developByLabel ?? "Developed by"} ${_data.user?.developBy ?? AppConfig.orgDomain}',
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceItemTable extends StatelessWidget {
  const InvoiceItemTable({super.key, required this.items});
  final List<ThermalInvoiceItemData> items;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _headerStyle = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        // Header
        const SizedBox.square(dimension: 8),
        Row(
          children: [
            Text('SL', style: _headerStyle),
            const SizedBox.square(dimension: 8),
            Expanded(
              flex: 2,
              child: Text(
                "Items",
                style: _headerStyle,
              ),
            ),
            Expanded(
              child: Text(
                "Price",
                textAlign: TextAlign.center,
                style: _headerStyle,
              ),
            ),
            Expanded(
              child: Text(
                "Qty",
                textAlign: TextAlign.center,
                style: _headerStyle,
              ),
            ),
            Flexible(
              flex: 0,
              child: Text(
                "Amount",
                textAlign: TextAlign.end,
                style: _headerStyle,
              ),
            ),
          ],
        ),
        const SizedBox.square(dimension: 8),
        const DashedDivider(),

        // Items
        ...items.asMap().entries.map(
          (itemEntry) => _buildRow(itemEntry.key, itemEntry.value),
        ),
      ],
    );
  }

  Widget _buildRow(int index, ThermalInvoiceItemData item) {
    return Builder(
      builder: (context) {
        final _theme = Theme.of(context);
        final _rowStyle = _theme.textTheme.bodyLarge?.copyWith(
          color: _theme.colorScheme.onPrimaryContainer,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(dimension: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${index + 1}', style: _rowStyle),
                const SizedBox.square(dimension: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name ?? "N/A",
                        style: _rowStyle,
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...item.options.map((option) {
                              return Text("• ${option.name}: ${option.price.quickCurrency()}");
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    item.unitPrice.quickCurrency(),
                    textAlign: TextAlign.center,
                    style: _rowStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.quantity.commaSeparated(),
                    textAlign: TextAlign.center,
                    style: _rowStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.total.quickCurrency(),
                    textAlign: TextAlign.end,
                    style: _rowStyle,
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 8),
            const DashedDivider(),
          ],
        );
      },
    );
  }
}
