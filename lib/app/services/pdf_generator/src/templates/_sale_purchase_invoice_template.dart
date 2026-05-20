import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/core.dart';

import '../../../services.dart' show SalePurchaseThermalInvoiceData, ThermalInvoiceItemData;
import 'templates.dart';

class SalePurchaseInvoiceTemplate extends PDFTemplateBase {
  SalePurchaseInvoiceTemplate(this.data);
  final SalePurchaseThermalInvoiceData data;

  @override
  String get fileName {
    return data.invoiceNumber ?? DateTime.now().getFormatedString(pattern: 'dd-MM-yyyy');
  }

  @override
  Future<pw.Page> get page async {
    final _storeLogo = await resolvedImage(
      data.user?.invoiceLogo?.remote,
      fit: pw.BoxFit.cover,
    );

    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: pdf.PdfPageFormat.a4.copyWith(
          marginLeft: 32,
          marginTop: 32,
          marginRight: 32,
          marginBottom: 24,
        ),
      ),
      header: (context) {
        if (context.pageNumber != 1) {
          return pw.SizedBox.shrink();
        }

        return pw.Align(
          child: pw.Column(
            children: [
              // Store Logo
              if (_storeLogo != null) ...[
                pw.SizedBox.square(
                  dimension: 48,
                  child: _storeLogo,
                ),
                pw.SizedBox.square(dimension: 4),
              ],

              // Store Name
              pw.Text(
                data.user?.business?.companyName ?? 'N/A',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox.square(dimension: 4),

              // Store Address
              pw.Text(
                data.user?.business?.address ?? 'N/A',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox.square(dimension: 2),

              // Store Phone
              pw.Text(
                "Mobile: ${data.user?.business?.phoneNumber ?? 'N/A'}",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox.square(dimension: 2),

              // Store Email
              pw.Text(
                "Email: ${data.user?.email ?? 'N/A'}",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox.square(dimension: 2),
            ],
          ),
        );
      },
      build: (context) {
        return [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox.square(dimension: 32),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 0),
              pw.SizedBox.square(dimension: 8),

              // Invoice Info
              ...{
                "Order No: ": data.invoiceNumber ?? "N/A",
                "Date & Time: ": data.invoiceDate ?? "N/A",
                if (data.table != null) "Table: ": data.table?.name ?? "N/A",
              }.entries.map((e) {
                return pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 2),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: e.key,
                      children: [
                        pw.TextSpan(
                          text: e.value,
                          style: pw.TextStyle(color: pdf.PdfColors.black),
                        ),
                      ],
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: pdf.PdfColor.fromHex('4D4D4D'),
                      ),
                    ),
                  ),
                );
              }),
              pw.SizedBox.square(dimension: 12),

              // Items
              _InvoiceItemTable(items: [...?data.items]),
              pw.SizedBox.square(dimension: 24),

              // Subtotal
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Sub Total (${data.items?.length ?? 0} Items):',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      (data.subtotal ?? 0).quickCurrency(),
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox.square(dimension: 4),

              // Discount
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Discount ${data.discountPercent?.commaSeparated() ?? 0}% :',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      ((data.discountAmount ?? 0) * -1).quickCurrency(),
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox.square(dimension: 4),

              // VAT
              if (data.vatPercent != null) ...[
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '${data.vat?.name ?? "VAT"} ${data.vatPercent?.commaSeparated() ?? 0}% :',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        ((data.vatAmount ?? 0)).quickCurrency(),
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox.square(dimension: 4),
              ],
              pw.SizedBox.square(dimension: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 0),
              pw.SizedBox.square(dimension: 8),

              // Total Amount
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Total Amount :',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      (data.totalAmount ?? 0).quickCurrency(),
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox.square(dimension: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 0),
              pw.SizedBox.square(dimension: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 0),
              pw.SizedBox.square(dimension: 6),

              // Paid Amount
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Paid Amount:',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      (data.paidAmount ?? 0).quickCurrency(),
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Due Amount
              if (data.dueAmount != null) ...[
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Due Amount:',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        (data.dueAmount ?? 0).quickCurrency(),
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox.square(dimension: 6),
              ],

              // Payment Method
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Payment Type:',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      data.paymentMethod ?? "N/A",
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox.square(dimension: 40),

              // Footer
              pw.Align(
                alignment: pw.AlignmentDirectional.topCenter,
                child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    // Gratitude Message
                    if (data.user?.gratitudeMessage != null) ...[
                      pw.Text(
                        'Thank you',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox.square(dimension: 14),
                    ],

                    // QR Code
                    pw.BarcodeWidget(
                      data: data.user?.developByLink ?? AppConfig.orgDomain,
                      barcode: pw.Barcode.qrCode(),
                      height: 80,
                      width: 80,
                    ),
                    pw.SizedBox.square(dimension: 8),

                    // Developped By
                    pw.Text(
                      '${data.user?.developByLabel ?? "Developed by"} ${data.user?.developBy ?? AppConfig.orgDomain}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: pdf.PdfColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ];
      },
    );
  }
}

class _InvoiceItemTable extends pw.StatelessWidget {
  _InvoiceItemTable({required this.items});
  final List<ThermalInvoiceItemData> items;

  @override
  pw.Widget build(pw.Context context) {
    final _headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 16,
    );

    return pw.Column(
      children: [
        // Header
        pw.Divider(
          borderStyle: pw.BorderStyle.dashed,
          height: 0,
        ),
        pw.SizedBox.square(dimension: 8),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                "Items",
                style: _headerStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                "Price",
                textAlign: pw.TextAlign.center,
                style: _headerStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                "Qty",
                textAlign: pw.TextAlign.center,
                style: _headerStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                "Amount",
                textAlign: pw.TextAlign.end,
                style: _headerStyle,
              ),
            ),
          ],
        ),
        pw.SizedBox.square(dimension: 8),
        pw.Divider(
          borderStyle: pw.BorderStyle.dashed,
          height: 0,
        ),

        // Items
        ...items.map((item) => _buildRow(item)),
      ],
    );
  }

  pw.Widget _buildRow(ThermalInvoiceItemData item) {
    final _rowStyle = pw.TextStyle(fontSize: 16);
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox.square(dimension: 8),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                item.name ?? "N/A",
                style: _rowStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                item.unitPrice.quickCurrency(),
                textAlign: pw.TextAlign.center,
                style: _rowStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                item.quantity.commaSeparated(),
                textAlign: pw.TextAlign.center,
                style: _rowStyle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                item.total.quickCurrency(),
                textAlign: pw.TextAlign.end,
                style: _rowStyle,
              ),
            ),
          ],
        ),
        pw.SizedBox.square(dimension: 8),
        pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 0),
      ],
    );
  }
}
