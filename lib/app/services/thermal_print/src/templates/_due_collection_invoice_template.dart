part of 'templates.dart';

class DueCollectionTemplate extends ThermalInvoiceTemplateBase {
  DueCollectionTemplate(super.key, {required this.dueInvoice});
  final DueCollectionThermalInvoiceData dueInvoice;

  @override
  Future<List<int>> get template async {
    List<int> _bytes = [];
    final _profile = await CapabilityProfile.load(name: printerProfile);
    final _generator = Generator(paperSize.escPosSize, _profile);

    if (printerSettings.printingMethod == ThermalPrinterPrintingMethod.image) {
      final _imageBytes = await switch (paperSize) {
        ThermalPrinterPaperSize.mm582Inch => _imageMM58(_generator),
        ThermalPrinterPaperSize.mm803Inch => _imageMM80(_generator),
      };
      final _image = img.decodeImage(_imageBytes);
      if (_image == null) {
        throw Exception('Failed to generate due collection receipt.');
      }

      _bytes += _generator.image(_image);
    }

    if (printerSettings.printingMethod == ThermalPrinterPrintingMethod.kDefault) {
      _bytes += await switch (paperSize) {
        ThermalPrinterPaperSize.mm582Inch => _mm58(_generator),
        ThermalPrinterPaperSize.mm803Inch => _mm80(_generator),
      };
    }

    _bytes += _generator.cut();
    return _bytes;
  }

  Future<List<int>> _mm58(Generator generator) async {
    List<int> _bytes = [];

    // Business Name
    _bytes += generator.text(
      dueInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Address
    if (dueInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        dueInvoice.user?.business?.address ?? "",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Business Phone Number
    if (dueInvoice.user?.business?.phoneNumber != null) {
      _bytes += generator.text(
        dueInvoice.user?.business?.phoneNumber ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // VAT Info
    if (dueInvoice.user?.business?.vatNo != null) {
      _bytes += generator.text(
        "${dueInvoice.user?.business?.vatName ?? 'VAT No :'}${dueInvoice.user?.business?.vatNo ?? 'N/A'}",
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Receipt No
    _bytes += generator.text(
      'Receipt No: ${dueInvoice.invoiceNumber ?? 'Not Provided'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Paid To/Received From
    _bytes += generator.text(
      '${dueInvoice.isPurchaseDue ? 'Paid To' : 'Received From'}: ${dueInvoice.party?.name ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Party Phone Number
    _bytes += generator.text(
      'Mobile: ${dueInvoice.party?.phone ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Received By
    _bytes += generator.text(
      '${dueInvoice.isPurchaseDue ? "Paid By" : "Received By"}: ${dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.name ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.left),
      linesAfter: 1,
    );

    _bytes += generator.hr();

    // Info Table
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Invoice',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Due',
          width: 4,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );
    _bytes += generator.hr();
    _bytes += generator.row(
      [
        PosColumn(
          text: dueInvoice.parentInvoiceNumber ?? 'N/A',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: dueInvoice.totalDue.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
      ],
    );
    _bytes += generator.hr();
    //Payment Amount
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Payment Amount:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: dueInvoice.paidAmount.toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    //Remaining Due
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Remaining Due:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: dueInvoice.remainingDueAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ],
    );
    _bytes += generator.row(
      [
        //Payment Type
        PosColumn(
          text: 'Payment Type:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        //Payment Method
        PosColumn(
          text: dueInvoice.paymentMethod ?? 'N/A',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.hr(ch: '=', linesAfter: 1);

    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (dueInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        dueInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        '${dueInvoice.invoiceDate ?? ''}, ${dueInvoice.invoiceTime ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Note
    if (dueInvoice.user?.invoiceNoteLabel != null || dueInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${dueInvoice.user?.invoiceNoteLabel ?? ''}: ${dueInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(
      dueInvoice.user?.developByLink ?? AppConfig.orgDomain,
    );
    _bytes += generator.text(
      '${dueInvoice.user?.developByLabel ?? "Developed By"} ${dueInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<List<int>> _mm80(Generator generator) async {
    List<int> _bytes = [];

    // Business Name
    _bytes += generator.text(
      dueInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Address
    if (dueInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        dueInvoice.user?.business?.address ?? "",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Business Phone Number
    if (dueInvoice.user?.business?.phoneNumber != null) {
      _bytes += generator.text(
        dueInvoice.user?.business?.phoneNumber ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // VAT Info
    if (dueInvoice.user?.business?.vatNo != null) {
      _bytes += generator.text(
        "${dueInvoice.user?.business?.vatName ?? 'VAT No :'}${dueInvoice.user?.business?.vatNo ?? 'N/A'}",
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Receipt Flag
    _bytes += generator.text(
      'RECEIPT',
      styles: const PosStyles(
        bold: true,
        underline: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Invoice Number & Date
    _bytes += generator.row(
      [
        // Invoice Number
        PosColumn(
          text: 'Receipt No: ${dueInvoice.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Date
        PosColumn(
          text: 'Date: ${dueInvoice.invoiceDate ?? "N/A"}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Customer Name & Time
    _bytes += generator.row(
      [
        // Customer Name
        PosColumn(
          text: 'Name: ${dueInvoice.party?.name ?? 'Guest'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Time
        PosColumn(
          text: 'Time: ${dueInvoice.invoiceTime ?? "N/A"}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Party Mobile & Sales By
    _bytes += generator.row(
      [
        // Party Mobile
        PosColumn(
          text: 'Mobile: ${dueInvoice.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Received By
        PosColumn(
          text:
              '${dueInvoice.isPurchaseDue ? "Paid By" : "Received By"}: ${dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.name ?? "N/A"}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.emptyLines(1);

    // Info Table
    _bytes += generator.hr();
    _bytes += generator.row(
      [
        PosColumn(
          text: 'SL',
          width: 1,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Invoice',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Due',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );
    _bytes += generator.hr();
    _bytes += generator.row(
      [
        PosColumn(
          text: '1',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: dueInvoice.parentInvoiceNumber ?? 'N/A',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: dueInvoice.totalDue.toString(),
          width: 3,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
      ],
    );
    _bytes += generator.hr();
    //--------------------Summary--------------------//
    // Paid Amount
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Payment Amount:',
          width: 9,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: (dueInvoice.paidAmount ?? 0).commaSeparated(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Remaining Due
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Remaining Due:',
          width: 9,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: (dueInvoice.remainingDueAmount ?? 0).commaSeparated(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.text('                    ----------------------------');

    // Payment Type
    _bytes += generator.text(
      'Payment Type: ${dueInvoice.paymentMethod ?? 'N/A'}',
      linesAfter: 1,
    );
    //--------------------Summary--------------------//
    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (dueInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        dueInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        '${dueInvoice.invoiceDate ?? ''}, ${dueInvoice.invoiceTime ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Note
    if (dueInvoice.user?.invoiceNoteLabel != null || dueInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${dueInvoice.user?.invoiceNoteLabel ?? ''}: ${dueInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(
      dueInvoice.user?.developByLink ?? AppConfig.orgDomain,
      size: QRSize.size6,
    );
    _bytes += generator.text(
      '${dueInvoice.user?.developByLabel ?? "Developed By"} ${dueInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<Uint8List> _imageMM58(Generator generator) async {
    final _layout = thermer.ThermerLayout(
      paperSize: thermer.PaperSize.mm58,
      dpi: printerSettings.printerDpi?.toDouble(),
      marginMm: printerSettings.printerMargin?.toDouble(),
      widgets: [
        // Business Name
        thermer.ThermerText(
          dueInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 42, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Address
        if (dueInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.business?.address ?? "",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        if (dueInvoice.user?.business?.phoneNumber != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.business?.phoneNumber ?? '',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (dueInvoice.user?.business?.vatNo != null) ...[
          thermer.ThermerText(
            // "${dueInvoice.user?.business?.vatName ?? 'VAT No :'}${dueInvoice.user?.business?.vatNo ?? 'N/A'}",
            "${dueInvoice.user?.business?.vatName ?? loc.t.thermalPrint.invoice.vatNo}: ${dueInvoice.user?.business?.vatNo ?? ''}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],
        thermer.ThermerSizedBox(height: 16),

        // Receipt No
        thermer.ThermerText(
          // 'Receipt No: ${dueInvoice.invoiceNumber ?? 'Not Provided'}',
          loc.t.thermalPrint.invoice.receiptNoLabel(invoiceNumber: dueInvoice.invoiceNumber ?? 'Not Provided'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Paid To/Received From
        thermer.ThermerText(
          // '${dueInvoice.isPurchaseDue ? 'Paid To' : 'Received From'}: ${dueInvoice.party?.name ?? "N/A"}',
          loc.t.thermalPrint.invoice.paidToReceivedFromLabel(
            label:
                dueInvoice.isPurchaseDue ? loc.t.thermalPrint.invoice.paidTo : loc.t.thermalPrint.invoice.receivedFrom,
            name: dueInvoice.party?.name ?? "N/A",
          ),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Party Phone Number
        thermer.ThermerText(
          // 'Mobile: ${dueInvoice.party?.phone ?? "N/A"}',
          loc.t.thermalPrint.invoice.mobileLabel(phone: dueInvoice.party?.phone ?? "N/A"),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Received By
        thermer.ThermerText(
          // '${dueInvoice.isPurchaseDue ? "Paid By" : "Received By"}: ${dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.role ?? "N/A"}',
          loc.t.thermalPrint.invoice.paidToReceivedFromLabel(
            label: dueInvoice.isPurchaseDue ? loc.t.thermalPrint.invoice.paidBy : loc.t.thermalPrint.invoice.receivedBy,
            name: dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.name ?? "N/A",
          ),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),
        thermer.ThermerSizedBox(height: 8),

        // Info Table
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(
              // 'Invoice',
              loc.t.thermalPrint.tableHeaders.invoiceTable,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Due',
              loc.t.thermalPrint.tableHeaders.dueTable,
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: [
            thermer.ThermerTableRow([
              thermer.ThermerText(
                dueInvoice.parentInvoiceNumber ?? 'N/A',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (dueInvoice.totalDue ?? 0).quickCurrency(),
                textAlign: thermer.TextAlign.center,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
            ]),
          ],
          cellWidths: {
            0: null,
            1: 0.3,
          },
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // Payment Amount
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Payment Amount: ',
              loc.t.thermalPrint.summary.paymentAmount,
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (dueInvoice.paidAmount ?? 0).quickCurrency(),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Remaining Due
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Remaining Due: ',
              loc.t.thermalPrint.summary.remainingDue,
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (dueInvoice.remainingDueAmount ?? 0).quickCurrency(),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Payment Type
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Payment Type: ',
              loc.t.thermalPrint.summary.paymentType(method: ''),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              dueInvoice.paymentMethod ?? 'N/A',
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),
        thermer.ThermerDivider.horizontal(),
        thermer.ThermerSizedBox(height: 16),

        //--------------------Footer--------------------//
        // Gratitude/Post Sale Message
        if (dueInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.gratitudeMessage ?? '',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w600,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 4),
        ],

        // Note
        if (dueInvoice.user?.invoiceNoteLabel != null || dueInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            '${dueInvoice.user?.invoiceNoteLabel ?? ''}: ${dueInvoice.user?.invoiceNote ?? ''}',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w500,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 8),
        ],

        // QR Code
        thermer.ThermerAlign(
          child: thermer.ThermerQRCode(
            data: dueInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          '${dueInvoice.user?.developByLabel ?? "Developed By"} ${dueInvoice.user?.developBy ?? "N/A"}',
          textAlign: thermer.TextAlign.center,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),
        //--------------------Footer--------------------//

        // White Space
        thermer.ThermerSizedBox(height: 200)
      ],
    );

    return _layout.toUint8List();
  }

  Future<Uint8List> _imageMM80(Generator generator) async {
    final _layout = thermer.ThermerLayout(
      paperSize: thermer.PaperSize.mm80,
      dpi: printerSettings.printerDpi?.toDouble(),
      marginMm: printerSettings.printerMargin?.toDouble(),
      textDirection: textDirection,
      widgets: [
        // Business Name
        thermer.ThermerText(
          dueInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 42, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Address
        if (dueInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.business?.address ?? "",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        if (dueInvoice.user?.business?.phoneNumber != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.business?.phoneNumber ?? '',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (dueInvoice.user?.business?.vatNo != null) ...[
          thermer.ThermerText(
            "${dueInvoice.user?.business?.vatName ?? loc.t.thermalPrint.invoice.vatNo}: ${dueInvoice.user?.business?.vatNo ?? 'N/A'}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],
        thermer.ThermerSizedBox(height: 16),

        // Receipt Flag
        thermer.ThermerText(
          // 'RECEIPT',
          loc.t.thermalPrint.invoice.receiptFlag,
          style: thermer.TextStyle(
            fontSize: 42,
            fontWeight: thermer.FontWeight.bold,
            color: thermer.Colors.black,
          ),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Invoice Number & Date
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Receipt No: ${dueInvoice.invoiceNumber ?? 'Not Provided'}',
              loc.t.thermalPrint.invoice.receiptNoLabel(invoiceNumber: dueInvoice.invoiceNumber ?? 'Not Provided'),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Date: ${dueInvoice.invoiceDate ?? "N/A"}',
              loc.t.thermalPrint.invoice.dateLabel(dateTime: dueInvoice.invoiceDate ?? "N/A"),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Customer Name & Time
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Name: ${dueInvoice.party?.name ?? 'Guest'}',
              loc.t.thermalPrint.invoice.nameLabel(name: dueInvoice.party?.name ?? 'Guest'),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Time: ${dueInvoice.invoiceTime ?? "N/A"}',
              loc.t.thermalPrint.invoice.timeLabel(dateTime: dueInvoice.invoiceTime ?? "N/A"),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Party Mobile & Sales By
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Mobile: ${dueInvoice.party?.phone ?? ''}',
              loc.t.thermalPrint.invoice.mobileLabel(phone: dueInvoice.party?.phone ?? 'N/A'),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // '${dueInvoice.isPurchaseDue ? "Paid By" : "Received By"}: ${dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.name ?? "N/A"}',
              loc.t.thermalPrint.invoice.paidToReceivedFromLabel(
                label: dueInvoice.isPurchaseDue
                    ? loc.t.thermalPrint.invoice.paidBy
                    : loc.t.thermalPrint.invoice.receivedBy,
                name: dueInvoice.user?.role?.isShopOwner == true ? 'Admin' : dueInvoice.user?.name ?? "N/A",
              ),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Info Table
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(
              // 'SL',
              loc.t.thermalPrint.tableHeaders.sl,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Invoice',
              loc.t.thermalPrint.tableHeaders.invoiceTable,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Due',
              loc.t.thermalPrint.tableHeaders.dueTable,
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: [
            thermer.ThermerTableRow([
              thermer.ThermerText(
                '1',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                dueInvoice.parentInvoiceNumber ?? 'N/A',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (dueInvoice.totalDue ?? 0).quickCurrency(),
                textAlign: thermer.TextAlign.end,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
            ]),
          ],
          cellWidths: {
            0: 0.1,
            1: null,
            2: 0.3,
          },
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        //--------------------Summary--------------------//
        thermer.ThermerRow(
          children: [
            // Payment Type
            thermer.ThermerExpanded(
              flex: 6,
              child: thermer.ThermerAlign(
                child: thermer.ThermerAlign(
                  child: thermer.ThermerText(
                    // 'Payment Type: ${dueInvoice.paymentMethod ?? 'N/A'}',
                    loc.t.thermalPrint.summary.paymentType(method: dueInvoice.paymentMethod ?? 'N/A'),
                    style: thermer.TextStyle(
                      fontSize: 24,
                      fontWeight: thermer.FontWeight.w500,
                      color: thermer.Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            // Overview
            thermer.ThermerExpanded(
              flex: 5,
              child: thermer.ThermerColumn(
                children: [
                  // Paid Amount
                  thermer.ThermerRow(
                    children: [
                      thermer.ThermerText(
                        // 'Payment Amount:',
                        loc.t.thermalPrint.summary.paymentAmount,
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (dueInvoice.paidAmount ?? 0).quickCurrency(),
                        textAlign: thermer.TextAlign.end,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                    ],
                    mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
                  ),

                  // Remaining Due
                  thermer.ThermerRow(
                    children: [
                      thermer.ThermerText(
                        // 'Remaining Due:',
                        loc.t.thermalPrint.summary.remainingDue,
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (dueInvoice.remainingDueAmount ?? 0).quickCurrency(),
                        textAlign: thermer.TextAlign.end,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                    ],
                    mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
                  ),
                ],
              ),
            )
          ],
        ),
        thermer.ThermerDivider.horizontal(),
        //--------------------Summary--------------------//
        thermer.ThermerSizedBox(height: 16),

        //--------------------Footer--------------------//
        // Gratitude/Post Sale Message
        if (dueInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            dueInvoice.user?.gratitudeMessage ?? '',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w600,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 4),
        ],

        // Note
        if (dueInvoice.user?.invoiceNoteLabel != null || dueInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            '${dueInvoice.user?.invoiceNoteLabel ?? ''}: ${dueInvoice.user?.invoiceNote ?? ''}',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w500,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 8),
        ],

        // QR Code
        thermer.ThermerAlign(
          child: thermer.ThermerQRCode(
            data: dueInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          '${dueInvoice.user?.developByLabel ?? "Developed By"} ${dueInvoice.user?.developBy ?? "N/A"}',
          textAlign: thermer.TextAlign.center,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),
        //--------------------Footer--------------------//

        // White Space
        thermer.ThermerSizedBox(height: 200)
      ],
    );

    return _layout.toUint8List();
  }
}
