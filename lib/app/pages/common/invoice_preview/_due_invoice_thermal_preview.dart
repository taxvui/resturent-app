part of 'invoice_preview_view.dart';

class DueInvoiceThermalInvoicePreview extends ConsumerWidget {
  const DueInvoiceThermalInvoicePreview(this.data, {super.key});
  final DueCollectionThermalInvoiceData data;

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
                // 'Address: ${_data.user?.business?.address ?? 'N/A'}',
                '${context.t.common.address}: ${_data.user?.business?.address ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 4),

              // Store Phone
              Text(
                // 'Mobile: ${_data.user?.business?.phoneNumber ?? 'N/A'}',
                '${context.t.common.mobile}: ${_data.user?.business?.phoneNumber ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 4),

              // Store Email
              Text(
                // 'Email: ${_data.user?.email ?? 'N/A'}',
                '${context.t.common.email}: ${_data.user?.email ?? 'N/A'}',
                style: _theme.textTheme.bodyLarge,
              ),
              const SizedBox.square(dimension: 16),
            ],
          ),
          const DashedDivider(),
          const SizedBox.square(dimension: 10),

          // Receipt No
          Text.rich(
            TextSpan(
              // text: 'Receipt No: ',
              text: '${context.t.common.receiptNo}: ',
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

          // Invoice Date
          Text.rich(
            TextSpan(
              // text: 'Date & Time: ',
              text: '${context.t.common.dateAndTime}: ',
              children: [
                TextSpan(
                  text: ' ${_data.invoiceDate ?? ''} ${_data.invoiceTime ?? ''}',
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
          Text.rich(
            TextSpan(
              // text: 'Name: ',
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

          // Received/Paid By
          Text.rich(
            TextSpan(
              // text: '${_data.isPurchaseDue ? "Paid By" : "Received By"}: ',
              text: '${_data.isPurchaseDue ? context.t.common.paidBy : context.t.common.receivedBy}: ',
              children: [
                TextSpan(
                  text: _data.user?.role?.isShopOwner == true ? 'Admin' : _data.user?.name ?? "N/A",
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
          const SizedBox.square(dimension: 10),

          //------------------------------Info Table------------------------------//
          Builder(
            builder: (_) {
              final _headerStyle = _theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              );
              final _rowStyle = _headerStyle?.copyWith(
                fontWeight: FontWeight.normal,
                color: _theme.colorScheme.onPrimaryContainer,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  const DashedDivider(),
                  const SizedBox.square(dimension: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        // child: Text('Invoice', style: _headerStyle),
                        child: Text(context.t.common.invoice, style: _headerStyle),
                      ),
                      Expanded(
                        flex: 3,
                        // child: Text('Due', textAlign: TextAlign.end, style: _headerStyle),
                        child: Text(context.t.common.due, textAlign: TextAlign.end, style: _headerStyle),
                      ),
                    ],
                  ),
                  const SizedBox.square(dimension: 8),
                  const DashedDivider(),
                  const SizedBox.square(dimension: 8),

                  // Info
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(_data.parentInvoiceNumber ?? 'N/A', style: _rowStyle),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          (_data.totalDue ?? 0).quickCurrency(),
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
          ),
          //------------------------------Info Table------------------------------//
          const SizedBox.square(dimension: 10),

          // Summary
          DefaultTextStyle.merge(
            style: _theme.textTheme.bodyLarge,
            child: Column(
              children: [
                // Paid Amount
                Row(
                  children: [
                    // Expanded(child: Text('Payment Amount: ')),
                    Expanded(child: Text('${context.t.common.paymentAmount}: ')),
                    Text((_data.paidAmount ?? 0).quickCurrency()),
                  ],
                ),
                const SizedBox.square(dimension: 8),
                Row(
                  children: [
                    // Expanded(child: Text('Remaining Due: ')),
                    Expanded(child: Text('${context.t.common.remainingDue}: ')),
                    Text((_data.remainingDueAmount ?? 0).quickCurrency()),
                  ],
                ),
                const SizedBox.square(dimension: 8),
                Row(
                  children: [
                    // Expanded(child: Text('Payment Type: ')),
                    Expanded(child: Text('${context.t.common.paymentType}: ')),
                    Text(_data.paymentMethod ?? 'N/A'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox.square(dimension: 24),

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
