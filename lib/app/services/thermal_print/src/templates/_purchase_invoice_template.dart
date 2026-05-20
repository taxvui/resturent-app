part of 'templates.dart';

class PurchaseThermalInvoiceTemplate extends ThermalInvoiceTemplateBase {
  PurchaseThermalInvoiceTemplate(super.ref, {required this.purchaseInvoice});
  final SalePurchaseThermalInvoiceData purchaseInvoice;

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
        throw Exception('Failed to generate purchase invoice.');
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
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<List<int>> _mm58(Generator generator) async {
    List<int> _bytes = [];

    final _logo = await getNetworkImage(
      purchaseInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      _bytes += generator.image(_logo);
    }

    // Business Name
    _bytes += generator.text(
      purchaseInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Shop Address
    if (purchaseInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        purchaseInvoice.user!.business!.address!,
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    // VAT Info
    if (purchaseInvoice.user?.business?.vatName != null) {
      _bytes += generator.text(
        "${purchaseInvoice.user?.business?.vatName ?? 'VAT No'}: ${purchaseInvoice.user?.business?.vatNo ?? ''}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Business Phone Number
    if (purchaseInvoice.user?.business?.phoneNumber != null) {
      _bytes += generator.text(
        'Tel: ${purchaseInvoice.user?.business?.phoneNumber ?? 'N/A'}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Invoice Number
    _bytes += generator.text(
      'Purchase Invoice: ${purchaseInvoice.invoiceNumber}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Supplier Name
    _bytes += generator.text(
      'Name: ${purchaseInvoice.party?.name ?? 'Guest'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Supplier Phone Number
    _bytes += generator.text(
      'Mobile: ${purchaseInvoice.party?.phone ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Purchased By
    _bytes += generator.text(
      'Purchased By: ${purchaseInvoice.user?.role?.isShopOwner == true ? 'Admin' : purchaseInvoice.user?.name ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.left),
      linesAfter: 1,
    );
    _bytes += generator.hr();

    //--------------------Product Table--------------------//
    // Header
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Item',
          width: 5,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Cost',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
        PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
        PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ],
    );
    _bytes += generator.hr();

    // Items
    purchaseInvoice.items?.forEach((item) {
      _bytes += generator.row(
        [
          PosColumn(
            text: item.name ?? 'Not Defined',
            width: 5,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: item.unitPrice.toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: item.quantity.toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: item.total.toString(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    });
    _bytes += generator.hr();

    //--------------------Product Table--------------------//

    //--------------------Summary--------------------//
    // Sub Total
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Sub Total:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: purchaseInvoice.subtotal.toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Discount
    if (purchaseInvoice.hasDiscount) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Discount: ${purchaseInvoice.discountPercent ?? 0}%',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (purchaseInvoice.discountAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // VAT/Tax
    if (purchaseInvoice.hasVat) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "${purchaseInvoice.vat?.name ?? 'VAT'}: ${purchaseInvoice.vat?.rate ?? 0}%",
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (purchaseInvoice.vatAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Total Payable
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Total Payable:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: (purchaseInvoice.totalAmount ?? 0).toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ],
    );

    // Paid Amount
    _bytes += generator.row([
      PosColumn(
        text: 'Paid Amount:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: (purchaseInvoice.paidAmount ?? 0).toString(),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Due Amount
    if ((purchaseInvoice.dueAmount ?? 0) > 0) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Due Amount:',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (purchaseInvoice.dueAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Payment Method
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Payment Type:',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: purchaseInvoice.paymentMethod ?? 'N/A',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.hr(ch: '=', linesAfter: 1);
    //--------------------Summary--------------------//

    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (purchaseInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        purchaseInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        purchaseInvoice.dateTime ?? '',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Note
    if (purchaseInvoice.user?.invoiceNoteLabel != null || purchaseInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${purchaseInvoice.user?.invoiceNoteLabel ?? ''}: ${purchaseInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(purchaseInvoice.user?.developByLink ?? AppConfig.orgDomain);
    _bytes += generator.text(
      '${purchaseInvoice.user?.developByLabel ?? "Developed By"} ${purchaseInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<List<int>> _mm80(Generator generator) async {
    List<int> _bytes = [];

    final _logo = await getNetworkImage(
      purchaseInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      final _grayscale = img.grayscale(img.copyResize(_logo, width: 184));
      _bytes += generator.imageRaster(_grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    // Business Name
    _bytes += generator.text(
      purchaseInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Shop Address
    if (purchaseInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        'Address: ${purchaseInvoice.user!.business!.address!}',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    // Business Phone Number
    if (purchaseInvoice.user?.business?.phoneNumber != null) {
      _bytes += generator.text(
        'Mobile: ${purchaseInvoice.user!.business!.phoneNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // VAT Info
    if (purchaseInvoice.user?.business?.vatName != null) {
      _bytes += generator.text(
        "${purchaseInvoice.user?.business?.vatName ?? 'VAT No'}: ${purchaseInvoice.user?.business?.vatNo ?? ''}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    _bytes += generator.emptyLines(1);

    // Invoice Flag
    _bytes += generator.text(
      'INVOICE',
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
          text: 'Purchase Invoice: ${purchaseInvoice.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Date
        PosColumn(
          text: 'Date: ${purchaseInvoice.invoiceDate ?? 'N/A'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Supplier Name & Time
    _bytes += generator.row(
      [
        // Supplier Name
        PosColumn(
          text: 'Name: ${purchaseInvoice.party?.name ?? 'N/A'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Time
        PosColumn(
          text: 'Time: ${purchaseInvoice.invoiceTime}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Supplier Mobile & Purchase By
    _bytes += generator.row(
      [
        // Supplier Mobile
        PosColumn(
          text: 'Mobile: ${purchaseInvoice.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Purchase By
        PosColumn(
          text:
              'Purchase By: ${purchaseInvoice.user?.role?.isShopOwner == true ? 'Admin' : purchaseInvoice.user?.name ?? "N/A"}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.emptyLines(1);

    //--------------------Product Table--------------------//
    // Header
    _bytes += generator.hr();
    _bytes += generator.row([
      PosColumn(
        text: 'SL',
        width: 1,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Item',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Cost',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
      PosColumn(
        text: 'Amount',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    _bytes += generator.hr();

    // Items
    purchaseInvoice.items?.asMap().entries.forEach((entry) {
      _bytes += generator.row(
        [
          // SL
          PosColumn(
            text: '${entry.key + 1}',
            width: 1,
            styles: const PosStyles(align: PosAlign.left),
          ),

          // Item Name
          PosColumn(
            text: entry.value.name ?? 'Not Defined',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          ),

          // Qty
          PosColumn(
            text: entry.value.quantity.commaSeparated(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),

          // Cost Price
          PosColumn(
            text: entry.value.unitPrice.commaSeparated(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),

          // Amount
          PosColumn(
            text: entry.value.total.commaSeparated(),
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    });
    _bytes += generator.hr();
    //--------------------Product Table--------------------//

    //--------------------Summary--------------------//
    // Sub Total
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Sub Total:',
          width: 9,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: (purchaseInvoice.subtotal ?? 0).commaSeparated(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Discount
    if (purchaseInvoice.hasDiscount) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Discount: ${purchaseInvoice.discountPercent ?? 0}%',
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (purchaseInvoice.discountAmount ?? 0).toString(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // VAT/Tax
    if (purchaseInvoice.hasVat) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "${purchaseInvoice.vat?.name ?? 'VAT'}: ${purchaseInvoice.vat?.rate ?? 0}%",
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (purchaseInvoice.vatAmount ?? 0).commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }
    _bytes += generator.text('                    ----------------------------');

    // Total Payable
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Total Payable:',
          width: 9,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: (purchaseInvoice.totalAmount ?? 0).commaSeparated(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ],
    );

    // Paid Amount
    _bytes += generator.row([
      PosColumn(
        text: 'Paid Amount:',
        width: 9,
        styles: const PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: (purchaseInvoice.paidAmount ?? 0).toString(),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Due Amount
    if (purchaseInvoice.hasDue) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Due Amount:',
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (purchaseInvoice.dueAmount ?? 0).commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }
    _bytes += generator.hr();

    // Payment Type
    _bytes += generator.text(
      'Payment Type: ${purchaseInvoice.paymentMethod ?? 'N/A'}',
      linesAfter: 1,
    );
    //--------------------Summary--------------------//
    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (purchaseInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        purchaseInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        purchaseInvoice.dateTime ?? '',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Note
    if (purchaseInvoice.user?.invoiceNoteLabel != null || purchaseInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${purchaseInvoice.user?.invoiceNoteLabel ?? ''}: ${purchaseInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(
      purchaseInvoice.user?.developByLink ?? AppConfig.orgDomain,
      size: QRSize.size6,
    );
    _bytes += generator.text(
      '${purchaseInvoice.user?.developByLabel ?? "Developed By"} ${purchaseInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<Uint8List> _imageMM58(Generator generator) async {
    thermer.ThermerImage? _logo;
    if (purchaseInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          purchaseInvoice.user?.invoiceLogo?.remote ?? '',
          width: 120,
          height: 120,
        );
      } catch (_) {}
    }

    final _layout = thermer.ThermerLayout(
      paperSize: thermer.PaperSize.mm58,
      dpi: printerSettings.printerDpi?.toDouble(),
      marginMm: printerSettings.printerMargin?.toDouble(),
      widgets: [
        // Business Logo
        if (_logo != null) ...[
          thermer.ThermerAlign(child: _logo),
          thermer.ThermerSizedBox(height: 16),
        ],

        // Business Name
        thermer.ThermerText(
          purchaseInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 42, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Shop Address
        if (purchaseInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            purchaseInvoice.user?.business?.address ?? 'N/A',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (purchaseInvoice.user?.business?.vatName != null) ...[
          thermer.ThermerText(
            "${purchaseInvoice.user?.business?.vatName ?? 'VAT No'}: ${purchaseInvoice.user?.business?.vatNo ?? ''}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        if (purchaseInvoice.user?.business?.phoneNumber != null) ...[
          thermer.ThermerText(
            'Tel: ${purchaseInvoice.user?.business?.phoneNumber ?? "N/A"}',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],
        thermer.ThermerSizedBox(height: 16),

        // Invoice Number
        thermer.ThermerText(
          'Purchase Invoice: ${purchaseInvoice.invoiceNumber}',
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Supplier Name
        thermer.ThermerText(
          'Name: ${purchaseInvoice.party?.name ?? 'Guest'}',
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Supplier Phone Number
        thermer.ThermerText(
          'Mobile: ${purchaseInvoice.party?.phone ?? 'N/A'}',
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Purchased By
        thermer.ThermerText(
          'Purchased By: ${purchaseInvoice.user?.role?.isShopOwner == true ? 'Admin' : purchaseInvoice.user?.name ?? "N/A"}',
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),
        thermer.ThermerSizedBox(height: 8),

        //--------------------Product Table--------------------//
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(
              'Item',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Cost',
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Qty',
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Total',
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: List.generate(purchaseInvoice.items?.length ?? 0, (index) {
            final _item = (purchaseInvoice.items ?? [])[index];

            return thermer.ThermerTableRow([
              // Item Name
              thermer.ThermerText(
                _item.name ?? 'Not Defined',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Cost
              thermer.ThermerText(
                _item.unitPrice.quickCurrency(),
                textAlign: thermer.TextAlign.center,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Qty
              thermer.ThermerText(
                _item.quantity.commaSeparated(),
                textAlign: thermer.TextAlign.center,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Total
              thermer.ThermerText(
                _item.total.quickCurrency(),
                textAlign: thermer.TextAlign.end,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
            ]);
          }),
          cellWidths: {
            0: null,
            1: 0.2,
            2: 0.15,
            3: 0.2,
          },
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        //--------------------Summary--------------------//
        // Sub Total
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              'Sub Total: ',
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (purchaseInvoice.subtotal ?? 0).quickCurrency(),
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

        // Discount
        if (purchaseInvoice.hasDiscount) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                'Discount: ${purchaseInvoice.discountPercent ?? 0}%',
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (purchaseInvoice.discountAmount ?? 0).quickCurrency(),
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

        // VAT/Tax
        if (purchaseInvoice.hasVat) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                "${purchaseInvoice.vat?.name ?? 'VAT'}: ${purchaseInvoice.vat?.rate ?? 0}%",
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (purchaseInvoice.vatAmount ?? 0).quickCurrency(),
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

        // Total Payable
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              'Total Payable: ',
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                color: thermer.Colors.black,
                fontWeight: thermer.FontWeight.w600,
              ),
            ),
            thermer.ThermerText(
              (purchaseInvoice.totalAmount ?? 0).quickCurrency(),
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w600,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Paid Amount
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              'Paid Amount: ',
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (purchaseInvoice.paidAmount ?? 0).quickCurrency(),
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

        // Due Amount
        if ((purchaseInvoice.dueAmount ?? 0) > 0) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                'Due Amount: ',
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (purchaseInvoice.dueAmount ?? 0).quickCurrency(),
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

        // Payment Type
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              'Payment Type: ',
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              purchaseInvoice.paymentMethod ?? 'N/A',
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
        if (purchaseInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            purchaseInvoice.user?.gratitudeMessage ?? '',
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
        if (purchaseInvoice.user?.invoiceNoteLabel != null || purchaseInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            '${purchaseInvoice.user?.invoiceNoteLabel ?? ''}: ${purchaseInvoice.user?.invoiceNote ?? ''}',
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
            data: purchaseInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          '${purchaseInvoice.user?.developByLabel ?? "Developed By"} ${purchaseInvoice.user?.developBy ?? "N/A"}',
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
    thermer.ThermerImage? _logo;
    if (purchaseInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          purchaseInvoice.user?.invoiceLogo?.remote ?? '',
          width: 200,
          height: 200,
        );
      } catch (_) {}
    }

    final _layout = thermer.ThermerLayout(
      paperSize: thermer.PaperSize.mm80,
      dpi: printerSettings.printerDpi?.toDouble(),
      marginMm: printerSettings.printerMargin?.toDouble(),
      textDirection: textDirection,
      widgets: [
        // Business Logo
        if (_logo != null) ...[
          thermer.ThermerAlign(
            child: _logo,
          ),
          thermer.ThermerSizedBox(height: 16),
        ],

        // Business Name
        thermer.ThermerText(
          purchaseInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 48, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),

        // Shop Address
        if (purchaseInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            'Address: ${purchaseInvoice.user?.business?.address ?? 'N/A'}',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        if (purchaseInvoice.user?.business?.phoneNumber != null) ...[
          thermer.ThermerText(
            'Mobile: ${purchaseInvoice.user?.business?.phoneNumber ?? "N/A"}',
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (purchaseInvoice.user?.business?.vatName != null) ...[
          thermer.ThermerText(
            "${purchaseInvoice.user?.business?.vatName ?? 'VAT No'}: ${purchaseInvoice.user?.business?.vatNo ?? ''}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],
        thermer.ThermerSizedBox(height: 8),

        // Invoice Flag
        thermer.ThermerText(
          'INVOICE',
          style: thermer.TextStyle(
            fontSize: 48,
            color: thermer.Colors.black,
            fontWeight: thermer.FontWeight.bold,
            decoration: thermer.TextDecoration.underline,
          ),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 24),

        // Invoice Number & Date
        thermer.ThermerRow(
          children: [
            // Invoice Number
            thermer.ThermerText(
              'Purchase Invoice: ${purchaseInvoice.invoiceNumber ?? 'Not Provided'}',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Invoice Date
            thermer.ThermerText(
              "Date: ${purchaseInvoice.invoiceDate ?? 'N/A'}",
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Supplier Name & Time
        thermer.ThermerRow(
          children: [
            // Supplier Name
            thermer.ThermerText(
              'Name: ${purchaseInvoice.party?.name ?? 'N/A'}',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Invoice Time
            thermer.ThermerText(
              "Time: ${purchaseInvoice.invoiceTime}",
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Supplier Mobile & Purchase By
        thermer.ThermerRow(
          children: [
            // Supplier Mobile
            thermer.ThermerText(
              'Mobile: ${purchaseInvoice.party?.phone ?? ''}',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Purchase By
            thermer.ThermerText(
              "Purchase By: ${purchaseInvoice.user?.role?.isShopOwner == true ? 'Admin' : purchaseInvoice.user?.name ?? "N/A"}",
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),
        thermer.ThermerSizedBox(height: 8),

        //--------------------Product Table--------------------//
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(
              'SL',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Item',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Qty',
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Cost',
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              'Amount',
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: List.generate(purchaseInvoice.items?.length ?? 0, (index) {
            final _item = (purchaseInvoice.items ?? [])[index];

            return thermer.ThermerTableRow([
              // SL
              thermer.ThermerText(
                '${index + 1}',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Item Name
              thermer.ThermerText(
                _item.name ?? 'Not Defined',
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Qty
              thermer.ThermerText(
                _item.quantity.commaSeparated(),
                textAlign: thermer.TextAlign.center,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Cost Price
              thermer.ThermerText(
                _item.unitPrice.quickCurrency(),
                textAlign: thermer.TextAlign.center,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),

              // Amount
              thermer.ThermerText(
                _item.total.quickCurrency(),
                textAlign: thermer.TextAlign.end,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
            ]);
          }),
          cellWidths: {
            0: 0.1,
            1: null,
            2: 0.15,
            3: 0.2,
            4: 0.2,
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
              flex: 5,
              child: thermer.ThermerAlign(
                child: thermer.ThermerText(
                  'Payment Type: ${purchaseInvoice.paymentMethod ?? 'N/A'}',
                  textAlign: thermer.TextAlign.center,
                  style: thermer.TextStyle(
                    fontSize: 24,
                    fontWeight: thermer.FontWeight.w500,
                    color: thermer.Colors.black,
                  ),
                ),
              ),
            ),

            // Overview Summary
            thermer.ThermerExpanded(
              flex: 6,
              child: thermer.ThermerColumn(
                children: [
                  // Sub Total
                  thermer.ThermerRow(
                    children: [
                      thermer.ThermerText(
                        'Sub Total: ',
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (purchaseInvoice.subtotal ?? 0).quickCurrency(),
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

                  // Discount
                  if (purchaseInvoice.hasDiscount) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          'Discount: ${purchaseInvoice.discountPercent ?? 0}%',
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (purchaseInvoice.discountAmount ?? 0).quickCurrency(),
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

                  // VAT/Tax
                  if (purchaseInvoice.hasVat) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          "${purchaseInvoice.vat?.name ?? 'VAT'}: ${purchaseInvoice.vat?.rate ?? 0}%",
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (purchaseInvoice.vatAmount ?? 0).quickCurrency(),
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
                  thermer.ThermerDivider.horizontal(),

                  // Total Payable
                  thermer.ThermerRow(
                    children: [
                      thermer.ThermerText(
                        'Total Payable: ',
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          color: thermer.Colors.black,
                          fontWeight: thermer.FontWeight.w600,
                        ),
                      ),
                      thermer.ThermerText(
                        (purchaseInvoice.totalAmount ?? 0).quickCurrency(),
                        textAlign: thermer.TextAlign.end,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w600,
                          color: thermer.Colors.black,
                        ),
                      ),
                    ],
                    mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
                  ),

                  // Paid Amount
                  thermer.ThermerRow(
                    children: [
                      thermer.ThermerText(
                        'Paid Amount: ',
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (purchaseInvoice.paidAmount ?? 0).quickCurrency(),
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

                  // Due Amount
                  if (purchaseInvoice.hasDue) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          'Due Amount: ',
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (purchaseInvoice.dueAmount ?? 0).quickCurrency(),
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
                ],
              ),
            ),
          ],
        ),
        thermer.ThermerDivider.horizontal(),
        thermer.ThermerSizedBox(height: 24),

        //--------------------Footer--------------------//
        // Gratitude/Post Sale Message
        if (purchaseInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            purchaseInvoice.user?.gratitudeMessage ?? '',
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
        if (purchaseInvoice.user?.invoiceNoteLabel != null || purchaseInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            '${purchaseInvoice.user?.invoiceNoteLabel ?? ''}: ${purchaseInvoice.user?.invoiceNote ?? ''}',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w500,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 8),
        ],
        thermer.ThermerSizedBox(height: 16),

        // QR Code
        thermer.ThermerAlign(
          child: thermer.ThermerQRCode(
            data: purchaseInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          '${purchaseInvoice.user?.developByLabel ?? "Developed By"} ${purchaseInvoice.user?.developBy ?? "N/A"}',
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

    return _layout.generateImage();
  }
}
