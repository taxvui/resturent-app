part of 'templates.dart';

class SaleThermalInvoiceTemplate extends ThermalInvoiceTemplateBase {
  SaleThermalInvoiceTemplate(super.ref, {required this.saleInvoice, this.printKOT = false});
  final SalePurchaseThermalInvoiceData saleInvoice;
  final bool printKOT;

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
        throw Exception('Failed to generate invoice.');
      }

      _bytes += _generator.image(_image);
    }

    if (printerSettings.printingMethod == ThermalPrinterPrintingMethod.kDefault) {
      _bytes += await switch (paperSize) {
        ThermalPrinterPaperSize.mm582Inch => _defaultMM58(_generator),
        ThermalPrinterPaperSize.mm803Inch => _defaultMM80(_generator),
      };
    }

    _bytes += _generator.cut();
    return _bytes;
  }

  Future<List<int>> _defaultMM58(Generator generator) async {
    List<int> _bytes = [];

    final _logo = await getNetworkImage(
      saleInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      _bytes += generator.image(_logo);
    }

    // Business Name
    _bytes += generator.text(
      saleInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Seller Info
    _bytes += generator.text(
      'Seller: ${saleInvoice.user?.role?.isShopOwner == true ? 'Admin' : saleInvoice.user?.name ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
    );

    // Shop Address
    if (saleInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        saleInvoice.user!.business!.address!,
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    // VAT Info
    if (saleInvoice.user?.business?.vatName != null) {
      _bytes += generator.text(
        "${saleInvoice.user?.business?.vatName ?? 'VAT No'}: ${saleInvoice.user?.business?.vatNo ?? ''}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Business Phone Number
    _bytes += generator.text(
      'Tel: ${saleInvoice.user?.business?.phoneNumber ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    // Order Number
    _bytes += generator.text(
      'Order No: ${saleInvoice.invoiceNumber}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Customer Name
    _bytes += generator.text(
      'Name: ${saleInvoice.party?.name ?? 'Guest'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Customer Phone Number
    _bytes += generator.text(
      'Mobile: ${saleInvoice.party?.phone ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Order Type
    _bytes += generator.text(
      'Order Type: ${saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Table No.
    if (saleInvoice.table != null) {
      _bytes += generator.text(
        'Table: ${saleInvoice.table?.name ?? "N/A"}',
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      );
    }
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
    saleInvoice.items?.forEach((item) {
      final _name = [
        item.name ?? 'Not Defined',
        ...item.options.map((option) => '•${option.name}:${option.price}'),
      ];
      _bytes += generator.row(
        [
          PosColumn(
            text: _name.join(item.options.isNotEmpty ? '\n' : ''),
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
          text: 'Sub Total (${saleInvoice.items?.length ?? 0} Items)',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: saleInvoice.subtotal.toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Discount
    if (saleInvoice.hasDiscount) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Discount ${saleInvoice.discountPercent ?? 0}%',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (saleInvoice.discountAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // VAT/Tax
    if (saleInvoice.vat != null) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "${saleInvoice.vat?.name ?? 'VAT'} ${saleInvoice.vat?.rate ?? 0}%",
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (saleInvoice.vatAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Tip
    if (saleInvoice.hasTip) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "Tip",
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (saleInvoice.tipAmount ?? 0).toString(),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Delivery Charge
    if (saleInvoice.hasDeliveryCharge) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "Delivery Charge",
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (saleInvoice.deliveryCharge ?? 0).toString(),
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
          text: (saleInvoice.totalAmount ?? 0).toString(),
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
        text: (saleInvoice.paidAmount ?? 0).toString(),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Due Amount
    if ((saleInvoice.dueAmount ?? 0) > 0) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Due Amount:',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: (saleInvoice.dueAmount ?? 0).toString(),
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
          text: saleInvoice.paymentMethod ?? 'N/A',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );
    _bytes += generator.hr(ch: '=', linesAfter: 1);
    //--------------------Summary--------------------//

    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (saleInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        saleInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        saleInvoice.dateTime ?? '',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Note
    if (saleInvoice.user?.invoiceNoteLabel != null || saleInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${saleInvoice.user?.invoiceNoteLabel ?? ''}: ${saleInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(saleInvoice.user?.developByLink ?? AppConfig.orgDomain);
    _bytes += generator.text(
      '${saleInvoice.user?.developByLabel ?? "Developed By"} ${saleInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<List<int>> _defaultMM80(Generator generator) async {
    List<int> _bytes = [];

    final _logo = await getNetworkImage(
      saleInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      final _grayscale = img.grayscale(img.copyResize(_logo, width: 184));
      _bytes += generator.imageRaster(_grayscale, imageFn: PosImageFn.bitImageRaster);
    }

    // Business Name
    _bytes += generator.text(
      saleInvoice.user?.business?.companyName ?? "N/A",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Shop Address
    if (saleInvoice.user?.business?.address != null) {
      _bytes += generator.text(
        'Address: ${saleInvoice.user!.business!.address!}',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
    }

    // Business Phone Number
    if (saleInvoice.user?.business?.phoneNumber != null) {
      _bytes += generator.text(
        'Mobile: ${saleInvoice.user!.business!.phoneNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // VAT Info
    if (saleInvoice.user?.business?.vatName != null) {
      _bytes += generator.text(
        "${saleInvoice.user?.business?.vatName ?? 'VAT No'}: ${saleInvoice.user?.business?.vatNo ?? ''}",
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

    // Order Number & Date
    _bytes += generator.row(
      [
        // Order Number
        PosColumn(
          text: 'Order No: ${saleInvoice.invoiceNumber ?? 'Not Provided'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Date
        PosColumn(
          text: 'Date: ${saleInvoice.invoiceDate}',
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
          text: 'Name: ${saleInvoice.party?.name ?? 'Guest'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Invoice Time
        PosColumn(
          text: 'Time: ${saleInvoice.invoiceTime}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Customer Mobile & Sales By
    _bytes += generator.row(
      [
        // Customer Mobile
        PosColumn(
          text: 'Mobile: ${saleInvoice.party?.phone ?? ''}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Sales By
        PosColumn(
          text: 'Sales By: ${saleInvoice.user?.role?.isShopOwner == true ? 'Admin' : saleInvoice.user?.name ?? "N/A"}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Order Type & Table No.
    _bytes += generator.row(
      [
        // Customer Mobile
        PosColumn(
          text: 'Order Type: ${saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A'}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),

        // Table No.
        PosColumn(
          text: saleInvoice.table != null ? 'Table No. ${saleInvoice.table?.name ?? 'N/A'}' : '',
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
        text: 'U.Price',
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
    saleInvoice.items?.asMap().entries.forEach((entry) {
      final _name = [
        entry.value.name ?? 'Not Defined',
        ...entry.value.options.map((option) => '•${option.name}:${option.price}'),
      ];
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
            text: _name.join(entry.value.options.isNotEmpty ? '\n' : ''),
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

          // U.Price
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
          text: (saleInvoice.subtotal ?? 0).commaSeparated(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ],
    );

    // Discount
    if (saleInvoice.hasDiscount) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Discount: ${saleInvoice.discountPercent ?? 0}%',
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (saleInvoice.discountAmount ?? 0).toString(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // VAT/Tax
    if (saleInvoice.hasVat) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "${saleInvoice.vat?.name ?? 'VAT'}: ${saleInvoice.vat?.rate ?? 0}%",
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (saleInvoice.vatAmount ?? 0).commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Tip
    if (saleInvoice.hasTip) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "Tip:",
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (saleInvoice.tipAmount ?? 0).commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }

    // Delivery Charge
    if (saleInvoice.hasDeliveryCharge) {
      _bytes += generator.row(
        [
          PosColumn(
            text: "Delivery Charge:",
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (saleInvoice.deliveryCharge ?? 0).commaSeparated(),
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
          text: (saleInvoice.totalAmount ?? 0).commaSeparated(),
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
        text: (saleInvoice.paidAmount ?? 0).toString(),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Due Amount
    if (saleInvoice.hasDue) {
      _bytes += generator.row(
        [
          PosColumn(
            text: 'Due Amount:',
            width: 9,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: (saleInvoice.dueAmount ?? 0).commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      );
    }
    _bytes += generator.hr();

    // Payment Type
    _bytes += generator.text(
      'Payment Type: ${saleInvoice.paymentMethod ?? 'N/A'}',
      linesAfter: 1,
    );
    //--------------------Summary--------------------//

    //--------------------Footer--------------------//
    // Gratitude/Post Sale Message
    if (saleInvoice.user?.gratitudeMessage != null) {
      _bytes += generator.text(
        saleInvoice.user?.gratitudeMessage ?? '',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      _bytes += generator.text(
        saleInvoice.dateTime ?? '',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Sale Date Time
    _bytes += generator.text(
      saleInvoice.dateTime ?? 'N/A',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    // Note
    if (saleInvoice.user?.invoiceNoteLabel != null || saleInvoice.user?.invoiceNote != null) {
      _bytes += generator.text(
        '${saleInvoice.user?.invoiceNoteLabel ?? ''}: ${saleInvoice.user?.invoiceNote ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code
    _bytes += generator.qrcode(
      saleInvoice.user?.developByLink ?? AppConfig.orgDomain,
      size: QRSize.size6,
    );
    _bytes += generator.text(
      '${saleInvoice.user?.developByLabel ?? "Developed By"} ${saleInvoice.user?.developBy ?? "N/A"}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );
    //--------------------Footer--------------------//

    return _bytes;
  }

  Future<Uint8List> _imageMM58(Generator generator) async {
    thermer.ThermerImage? _logo;
    if (saleInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          saleInvoice.user?.invoiceLogo?.remote ?? '',
          width: 120,
          height: 120,
        );
      } catch (_) {}
    }

    final _layout = thermer.ThermerLayout(
      paperSize: thermer.PaperSize.mm58,
      dpi: printerSettings.printerDpi?.toDouble(),
      marginMm: printerSettings.printerMargin?.toDouble(),
      textDirection: textDirection,
      widgets: [
        // Business Logo
        if (_logo != null) ...[
          thermer.ThermerAlign(child: _logo),
          thermer.ThermerSizedBox(height: 16),
        ],

        // Business Name
        thermer.ThermerText(
          saleInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 42, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Seller Info
        thermer.ThermerText(
          // 'Seller: ${saleInvoice.user?.role?.isShopOwner == true ? 'Admin' : saleInvoice.user?.role ?? "N/A"}',
          loc.t.thermalPrint.invoice.seller(
            name: saleInvoice.user?.role?.isShopOwner == true ? 'Admin' : saleInvoice.user?.name ?? "N/A",
          ),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),

        // Shop Address
        if (saleInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            // 'Address: ${saleInvoice.user?.business?.address ?? 'N/A'}',
            loc.t.thermalPrint.invoice.address(addr: saleInvoice.user?.business?.address ?? 'N/A'),
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (saleInvoice.user?.business?.vatName != null) ...[
          thermer.ThermerText(
            // "${saleInvoice.user?.business?.vatName ?? 'VAT No'}: ${saleInvoice.user?.business?.vatNo ?? ''}",
            "${saleInvoice.user?.business?.vatName ?? loc.t.thermalPrint.invoice.vatNo}: ${saleInvoice.user?.business?.vatNo ?? ''}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        thermer.ThermerText(
          // 'Tel: ${saleInvoice.user?.business?.phoneNumber ?? "N/A"}',
          loc.t.thermalPrint.invoice.tel(phoneNumber: saleInvoice.user?.business?.phoneNumber ?? "N/A"),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Order Number
        thermer.ThermerText(
          // 'Order No: ${saleInvoice.invoiceNumber ?? 'Not Provided'}',
          loc.t.thermalPrint.invoice.saleInvoiceLabel(invoiceNumber: saleInvoice.invoiceNumber ?? 'Not Provided'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Customer Name
        thermer.ThermerText(
          // 'Name: ${saleInvoice.party?.name ?? 'Guest'}',
          loc.t.thermalPrint.invoice.nameLabel(name: saleInvoice.party?.name ?? 'Guest'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Customer Phone Number
        thermer.ThermerText(
          // 'Mobile: ${saleInvoice.party?.phone ?? 'N/A'}',
          loc.t.thermalPrint.invoice.mobileLabel(phone: saleInvoice.party?.phone ?? 'N/A'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Order Type
        thermer.ThermerText(
          // 'Order Type: ${saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A'}',
          loc.t.thermalPrint.invoice.orderTypeLabel(
            orderType: saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A',
          ),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Table No.
        thermer.ThermerText(
          // 'Table: ${saleInvoice.table?.name ?? "N/A"}',
          loc.t.thermalPrint.invoice.tableLabel(tableName: saleInvoice.table?.name ?? "N/A"),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        //--------------------Product Table--------------------//
        thermer.ThermerTable(
          header: thermer.ThermerTableRow([
            thermer.ThermerText(
              // 'Item',
              loc.t.thermalPrint.tableHeaders.item,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Qty',
              loc.t.thermalPrint.tableHeaders.qty,
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'U.Price',
              loc.t.thermalPrint.tableHeaders.uPrice,
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Amount',
              loc.t.thermalPrint.tableHeaders.amount,
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: List.generate(saleInvoice.items?.length ?? 0, (index) {
            final _item = (saleInvoice.items ?? [])[index];

            final _name = [
              _item.name ?? 'Not Defined',
              ..._item.options.map((option) => '• ${option.name}:${option.price}'),
            ];
            return thermer.ThermerTableRow([
              // Item Name
              thermer.ThermerText(
                _name.join(_item.options.isNotEmpty ? '\n' : ''),
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

              // U.Price
              thermer.ThermerText(
                _item.unitPrice.quickCurrency(),
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
        //--------------------Product Table--------------------//

        //--------------------Summary--------------------//
        // Sub Total
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Sub Total: ',
              loc.t.thermalPrint.summary.subTotal,
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (saleInvoice.subtotal ?? 0).quickCurrency(),
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
        if (saleInvoice.hasDiscount) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                // 'Discount: ${saleInvoice.discountPercent ?? 0}%',
                loc.t.thermalPrint.summary.discount(percentFmt: (saleInvoice.discountPercent ?? 0).commaSeparated()),
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (saleInvoice.discountAmount ?? 0).quickCurrency(),
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
        if (saleInvoice.hasVat) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                // "${saleInvoice.vat?.name ?? 'VAT'}: ${saleInvoice.vat?.rate ?? 0}%",
                loc.t.thermalPrint.summary.vat(
                  vatName: saleInvoice.vat?.name ?? loc.t.common.vat,
                  rateFmt: (saleInvoice.vat?.rate ?? 0).commaSeparated(),
                ),
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (saleInvoice.vatAmount ?? 0).quickCurrency(),
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

        // Tip
        if (saleInvoice.hasTip) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                // "Tip:",
                loc.t.thermalPrint.summary.tip,
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (saleInvoice.tipAmount ?? 0).quickCurrency(),
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

        // Delivery Charge
        if (saleInvoice.hasDeliveryCharge) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                // "Delivery Charge:",
                loc.t.thermalPrint.summary.deliveryCharge,
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (saleInvoice.deliveryCharge ?? 0).quickCurrency(),
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
              // 'Total Payable: ',
              loc.t.thermalPrint.summary.totalPayable,
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                color: thermer.Colors.black,
                fontWeight: thermer.FontWeight.w600,
              ),
            ),
            thermer.ThermerText(
              (saleInvoice.totalAmount ?? 0).quickCurrency(),
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
              // 'Paid Amount: ',
              loc.t.thermalPrint.summary.paidAmount,
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              (saleInvoice.paidAmount ?? 0).quickCurrency(),
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
        if (saleInvoice.hasDue) ...[
          thermer.ThermerRow(
            children: [
              thermer.ThermerText(
                // 'Due Amount: ',
                loc.t.thermalPrint.summary.dueAmount,
                textAlign: thermer.TextAlign.start,
                style: thermer.TextStyle(
                  fontSize: 24,
                  fontWeight: thermer.FontWeight.w500,
                  color: thermer.Colors.black,
                ),
              ),
              thermer.ThermerText(
                (saleInvoice.dueAmount ?? 0).quickCurrency(),
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
        thermer.ThermerText(
          // 'Payment Type: ${saleInvoice.paymentMethod ?? 'N/A'}',
          loc.t.thermalPrint.summary.paymentType(method: saleInvoice.paymentMethod ?? 'N/A'),
          textAlign: thermer.TextAlign.start,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),

        thermer.ThermerDivider.horizontal(),
        thermer.ThermerSizedBox(height: 16),
        //--------------------Summary--------------------//

        //--------------------Footer--------------------//
        // Gratitude/Post Sale Message
        if (saleInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            saleInvoice.user?.gratitudeMessage ?? '',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w600,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 4),
        ],

        // Sale Date Time
        thermer.ThermerText(
          saleInvoice.dateTime ?? 'N/A',
          textAlign: thermer.TextAlign.center,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),

        // Note
        if (saleInvoice.user?.invoiceNoteLabel != null || saleInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            '${saleInvoice.user?.invoiceNoteLabel ?? ''}: ${saleInvoice.user?.invoiceNote ?? ''}',
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
            data: saleInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          '${saleInvoice.user?.developByLabel ?? "Developed By"} ${saleInvoice.user?.developBy ?? "N/A"}',
          textAlign: thermer.TextAlign.center,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),
        //--------------------Footer--------------------//
      ],
    );

    return _layout.toUint8List();
  }

  Future<Uint8List> _imageMM80(Generator generator) async {
    thermer.ThermerImage? _logo;
    if (saleInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          saleInvoice.user?.invoiceLogo?.remote ?? '',
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
          saleInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 48, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),

        // Shop Address
        if (saleInvoice.user?.business?.address != null) ...[
          thermer.ThermerText(
            // 'Address: ${saleInvoice.user?.business?.address ?? 'N/A'}',
            loc.t.thermalPrint.invoice.address(addr: saleInvoice.user?.business?.address ?? 'N/A'),
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // Business Phone Number
        if (saleInvoice.user?.business?.phoneNumber != null) ...[
          thermer.ThermerText(
            // 'Mobile: ${saleInvoice.user?.business?.phoneNumber ?? "N/A"}',
            loc.t.thermalPrint.invoice.mobileLabel(phone: saleInvoice.user?.business?.phoneNumber ?? "N/A"),
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],

        // VAT Info
        if (saleInvoice.user?.business?.vatName != null) ...[
          thermer.ThermerText(
            // "${saleInvoice.user?.business?.vatName ?? 'VAT No'}: ${saleInvoice.user?.business?.vatNo ?? ''}",
            "${saleInvoice.user?.business?.vatName ?? loc.t.thermalPrint.invoice.vatNo}: ${saleInvoice.user?.business?.vatNo ?? ''}",
            style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
            textAlign: thermer.TextAlign.center,
          ),
        ],
        thermer.ThermerSizedBox(height: 8),

        // Invoice Flag
        thermer.ThermerText(
          // 'INVOICE',
          loc.t.thermalPrint.invoice.invoiceFlag,
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
              // 'Order No: ${saleInvoice.invoiceNumber ?? 'Not Provided'}',
              loc.t.thermalPrint.invoice.saleInvoiceLabel(invoiceNumber: saleInvoice.invoiceNumber ?? 'Not Provided'),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Invoice Date
            thermer.ThermerText(
              // "Date: ${saleInvoice.invoiceDate}",
              loc.t.thermalPrint.invoice.dateLabel(dateTime: saleInvoice.invoiceDate ?? 'N/A'),
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
            // Customer Name
            thermer.ThermerText(
              // 'Name: ${saleInvoice.party?.name ?? 'Guest'}',
              loc.t.thermalPrint.invoice.nameLabel(name: saleInvoice.party?.name ?? 'Guest'),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Invoice Time
            thermer.ThermerText(
              // "Time: ${saleInvoice.invoiceTime}",
              loc.t.thermalPrint.invoice.timeLabel(dateTime: saleInvoice.invoiceTime ?? "N/A"),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Customer Mobile & Sales By
        thermer.ThermerRow(
          children: [
            // Customer Mobile
            thermer.ThermerText(
              // 'Mobile: ${saleInvoice.party?.phone ?? ''}',
              loc.t.thermalPrint.invoice.mobileLabel(phone: saleInvoice.party?.phone ?? ''),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Sales By
            thermer.ThermerText(
              // "Sales By: ${_role}",
              loc.t.thermalPrint.invoice.salesByLabel(
                role: saleInvoice.user?.role?.isShopOwner == true ? 'Admin' : saleInvoice.user?.name ?? "N/A",
              ),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // Order Type & Table No.
        thermer.ThermerRow(
          children: [
            // Order Type
            thermer.ThermerText(
              // 'Order Type: ${saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A'}',
              loc.t.thermalPrint.invoice
                  .orderTypeLabel(orderType: saleInvoice.orderType?.stringValue.split('_').join(' ') ?? 'N/A'),
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),

            // Table No.
            thermer.ThermerText(
              // saleInvoice.table != null ? 'Table No: ${saleInvoice.table?.name ?? 'N/A'}' : '',
              saleInvoice.table != null
                  ? loc.t.thermalPrint.invoice.tableNoLabel(tableName: saleInvoice.table?.name ?? 'N/A')
                  : '',
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.w500,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        //--------------------Product Table--------------------//
        // Order Type & Table No.
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
              // 'Item',
              loc.t.thermalPrint.tableHeaders.item,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Qty',
              loc.t.thermalPrint.tableHeaders.qty,
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'U.Price',
              loc.t.thermalPrint.tableHeaders.uPrice,
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Amount',
              loc.t.thermalPrint.tableHeaders.amount,
              textAlign: thermer.TextAlign.end,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ]),
          data: List.generate(saleInvoice.items?.length ?? 0, (index) {
            final _item = (saleInvoice.items ?? [])[index];

            final _name = [
              _item.name ?? 'Not Defined',
              ..._item.options.map((option) => '• ${option.name}:${option.price}'),
            ];
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
                _name.join(_item.options.isNotEmpty ? '\n' : ''),
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

              // U.Price
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
        //--------------------Product Table--------------------//

        //--------------------Summary--------------------//
        thermer.ThermerRow(
          children: [
            // Payment Type
            thermer.ThermerExpanded(
              flex: 5,
              child: thermer.ThermerAlign(
                child: thermer.ThermerText(
                  // 'Payment Type: ${saleInvoice.paymentMethod ?? 'N/A'}',
                  loc.t.thermalPrint.summary.paymentType(method: saleInvoice.paymentMethod ?? 'N/A'),
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
                        // 'Sub Total: ',
                        loc.t.thermalPrint.summary.subTotal,
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (saleInvoice.subtotal ?? 0).quickCurrency(),
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
                  if (saleInvoice.hasDiscount) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          // 'Discount: ${saleInvoice.discountPercent ?? 0}%',
                          loc.t.thermalPrint.summary
                              .discount(percentFmt: (saleInvoice.discountPercent ?? 0).commaSeparated()),
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (saleInvoice.discountAmount ?? 0).quickCurrency(),
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
                  if (saleInvoice.hasVat) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          // "${saleInvoice.vat?.name ?? 'VAT'}: ${saleInvoice.vat?.rate ?? 0}%",
                          loc.t.thermalPrint.summary.vat(
                            vatName: saleInvoice.vat?.name ?? loc.t.common.vat,
                            rateFmt: (saleInvoice.vat?.rate ?? 0).commaSeparated(),
                          ),
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (saleInvoice.vatAmount ?? 0).quickCurrency(),
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

                  // Tip
                  if (saleInvoice.hasTip) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          // "Tip:",
                          loc.t.thermalPrint.summary.tip,
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (saleInvoice.tipAmount ?? 0).quickCurrency(),
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

                  // Delivery Charge
                  if (saleInvoice.hasDeliveryCharge) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          // "Delivery Charge:",
                          loc.t.thermalPrint.summary.deliveryCharge,
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (saleInvoice.deliveryCharge ?? 0).quickCurrency(),
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
                        // 'Total Payable: ',
                        loc.t.thermalPrint.summary.totalPayable,
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          color: thermer.Colors.black,
                          fontWeight: thermer.FontWeight.w600,
                        ),
                      ),
                      thermer.ThermerText(
                        (saleInvoice.totalAmount ?? 0).quickCurrency(),
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
                        // 'Paid Amount: ',
                        loc.t.thermalPrint.summary.paidAmount,
                        textAlign: thermer.TextAlign.start,
                        style: thermer.TextStyle(
                          fontSize: 24,
                          fontWeight: thermer.FontWeight.w500,
                          color: thermer.Colors.black,
                        ),
                      ),
                      thermer.ThermerText(
                        (saleInvoice.paidAmount ?? 0).quickCurrency(),
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
                  if (saleInvoice.hasDue) ...[
                    thermer.ThermerRow(
                      children: [
                        thermer.ThermerText(
                          // 'Due Amount: ',
                          loc.t.thermalPrint.summary.dueAmount,
                          textAlign: thermer.TextAlign.start,
                          style: thermer.TextStyle(
                            fontSize: 24,
                            fontWeight: thermer.FontWeight.w500,
                            color: thermer.Colors.black,
                          ),
                        ),
                        thermer.ThermerText(
                          (saleInvoice.dueAmount ?? 0).quickCurrency(),
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
        //--------------------Summary--------------------//

        //--------------------Footer--------------------//
        // Gratitude/Post Sale Message
        if (saleInvoice.user?.gratitudeMessage != null) ...[
          thermer.ThermerText(
            saleInvoice.user?.gratitudeMessage ?? '',
            textAlign: thermer.TextAlign.center,
            style: thermer.TextStyle(
              fontSize: 24,
              fontWeight: thermer.FontWeight.w600,
              color: thermer.Colors.black,
            ),
          ),
          thermer.ThermerSizedBox(height: 4),
        ],

        // Sale Date Time
        thermer.ThermerText(
          saleInvoice.dateTime ?? 'N/A',
          textAlign: thermer.TextAlign.center,
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),

        // Note
        if (saleInvoice.user?.invoiceNoteLabel != null || saleInvoice.user?.invoiceNote != null) ...[
          thermer.ThermerText(
            // '${saleInvoice.user?.invoiceNoteLabel ?? ''}: ${saleInvoice.user?.invoiceNote ?? ''}',
            loc.t.thermalPrint.footer.note(
              noteLabel: saleInvoice.user?.invoiceNoteLabel ?? '',
              note: saleInvoice.user?.invoiceNote ?? '',
            ),
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
            data: saleInvoice.user?.developByLink ?? AppConfig.orgDomain,
            size: 120,
          ),
        ),
        thermer.ThermerSizedBox(height: 8),
        thermer.ThermerText(
          // '${saleInvoice.user?.developByLabel ?? "Developed By"} ${saleInvoice.user?.developBy ?? "N/A"}',
          loc.t.thermalPrint.footer.developedBy(
            developByLabel: saleInvoice.user?.developByLabel ?? "Developed By",
            developBy: saleInvoice.user?.developBy ?? "N/A",
          ),
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
