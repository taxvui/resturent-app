part of 'templates.dart';

class KOTTicketTemplate extends ThermalInvoiceTemplateBase {
  KOTTicketTemplate(super.ref, {required this.kotInvoice});
  final SalePurchaseThermalInvoiceData kotInvoice;

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
        throw Exception('Failed to generate KOT ticket.');
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
    final _logo = await getNetworkImage(
      kotInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      _bytes += generator.image(_logo);
      _bytes += generator.emptyLines(2);
    }

    // Business Name
    _bytes += generator.text(
      kotInvoice.user?.business?.companyName ?? 'N/A',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Order No.
    _bytes += generator.text(
      'Order NO: ${kotInvoice.invoiceNumber ?? 'N/A'}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
      linesAfter: 1,
    );

    // Table No.
    _bytes += generator.text(
      'Table NO: ${kotInvoice.table?.name ?? 'Take Away'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Date
    _bytes += generator.text(
      'Date: ${kotInvoice.dateTime ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.left),
    );
    _bytes += generator.emptyLines(1);

    //--------------------Product Table--------------------//
    // Header
    _bytes += generator.hr();
    _bytes += generator.row(
      [
        PosColumn(
          text: 'SL',
          width: 1,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Item',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Qty',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );
    _bytes += generator.hr();

    // Items
    kotInvoice.items?.asMap().entries.forEach((entry) {
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
            text: '${[
              entry.value.name ?? 'Not Defined',
              ...entry.value.options.map((option) => '• ${option.name}: ${option.price}'),
            ].join('\n')}\n',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),

          // Quantity
          PosColumn(
            text: entry.value.quantity.commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.center),
          ),
        ],
        multiLine: false,
      );
    });
    _bytes += generator.hr();
    //--------------------Product Table--------------------//

    // Total Items
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Items: ${kotInvoice.items?.length ?? 0}',
          width: 9,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Qty: ${kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0}',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );

    return _bytes;
  }

  Future<List<int>> _mm80(Generator generator) async {
    List<int> _bytes = [];

    final _logo = await getNetworkImage(
      kotInvoice.user?.invoiceLogo?.remote,
    );

    // Business Logo
    if (_logo != null) {
      final _grayscale = img.grayscale(img.copyResize(_logo, width: 184));
      _bytes += generator.imageRaster(_grayscale, imageFn: PosImageFn.bitImageRaster);
      _bytes += generator.emptyLines(2);
    }

    // Business Name
    _bytes += generator.text(
      kotInvoice.user?.business?.companyName ?? 'N/A',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    // Order No.
    _bytes += generator.text(
      'Order NO: ${kotInvoice.invoiceNumber ?? 'Guest'}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
      linesAfter: 1,
    );

    // Table No.
    _bytes += generator.text(
      'Table NO: ${kotInvoice.table?.name ?? 'Take Away'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    // Date
    _bytes += generator.text(
      'Date: ${kotInvoice.dateTime ?? 'N/A'}',
      styles: const PosStyles(align: PosAlign.left),
    );
    _bytes += generator.emptyLines(1);

    //--------------------Product Table--------------------//
    // Header
    _bytes += generator.hr();
    _bytes += generator.row(
      [
        PosColumn(
          text: 'SL',
          width: 1,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Item',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Qty',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );
    _bytes += generator.hr();

    // Items
    kotInvoice.items?.asMap().entries.forEach((entry) {
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
            text: '${[
              entry.value.name ?? 'Not Defined',
              ...entry.value.options.map((option) => '• ${option.name}: ${option.price}'),
            ].join('\n')}\n',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),

          // Quantity
          PosColumn(
            text: entry.value.quantity.commaSeparated(),
            width: 3,
            styles: const PosStyles(align: PosAlign.center),
          ),
        ],
        multiLine: false,
      );
    });
    _bytes += generator.hr();
    //--------------------Product Table--------------------//

    // Total Items
    _bytes += generator.row(
      [
        PosColumn(
          text: 'Items: ${kotInvoice.items?.length ?? 0}',
          width: 9,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: 'Qty: ${kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0}',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      ],
    );

    return _bytes;
  }

  Future<Uint8List> _imageMM58(Generator generator) async {
    thermer.ThermerImage? _logo;
    if (kotInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          kotInvoice.user?.invoiceLogo?.remote ?? '',
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
          kotInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 42, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Order No.
        thermer.ThermerText(
          // 'Order NO: ${kotInvoice.invoiceNumber ?? 'Guest'}',
          loc.t.thermalPrint.invoice.orderNoKotLabel(invoiceNumber: kotInvoice.invoiceNumber ?? 'N/A'),
          style: thermer.TextStyle(
            fontSize: 42,
            color: thermer.Colors.black,
            fontWeight: thermer.FontWeight.bold,
          ),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 16),

        // Table No.
        thermer.ThermerText(
          // 'Table NO: ${kotInvoice.table?.name ?? 'Take Away'}',
          loc.t.thermalPrint.invoice.tableLabel(tableName: kotInvoice.table?.name ?? 'Take Away'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),

        // Date
        thermer.ThermerText(
          // 'Date: ${kotInvoice.dateTime ?? 'N/A'}',
          loc.t.thermalPrint.invoice.dateLabel(dateTime: kotInvoice.dateTime ?? 'N/A'),
          style: thermer.TextStyle(fontSize: 24, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.start,
        ),
        thermer.ThermerSizedBox(height: 8),

        //--------------------Product Table--------------------//
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
          ]),
          data: List.generate(kotInvoice.items?.length ?? 0, (index) {
            final _item = (kotInvoice.items ?? [])[index];

            final _name = [
              _item.name ?? 'Not Defined',
              ..._item.options.map((option) => '• ${option.name}: ${option.price}'),
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
            ]);
          }),
          cellWidths: {
            0: 0.1,
            1: null,
            2: 0.2,
          },
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // Total Items
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Items: ${kotInvoice.items?.length ?? 0}',
              loc.t.thermalPrint.summary.itemsCount(count: kotInvoice.items?.length ?? 0),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Qty: ${kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0}',
              loc.t.thermalPrint.summary.qtyTotal(
                totalQty: kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0,
              ),
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // White Space
        thermer.ThermerSizedBox(height: 200)
      ],
    );

    return _layout.toUint8List();
  }

  Future<Uint8List> _imageMM80(Generator generator) async {
    thermer.ThermerImage? _logo;
    if (kotInvoice.user?.invoiceLogo?.remote != null) {
      try {
        _logo = await thermer.ThermerImage.network(
          kotInvoice.user?.invoiceLogo?.remote ?? '',
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
          kotInvoice.user?.business?.companyName ?? "N/A",
          style: thermer.TextStyle(fontSize: 48, fontWeight: thermer.FontWeight.w500, color: thermer.Colors.black),
          textAlign: thermer.TextAlign.center,
        ),

        // Order No.
        thermer.ThermerText(
          // 'Order NO: ${kotInvoice.invoiceNumber ?? 'Guest'}',
          loc.t.thermalPrint.invoice.orderNoKotLabel(invoiceNumber: kotInvoice.invoiceNumber ?? 'Guest'),
          style: thermer.TextStyle(
            fontSize: 48,
            color: thermer.Colors.black,
            fontWeight: thermer.FontWeight.bold,
          ),
          textAlign: thermer.TextAlign.center,
        ),
        thermer.ThermerSizedBox(height: 24),

        // Table No.
        thermer.ThermerText(
          // 'Table NO: ${kotInvoice.table?.name ?? 'Take Away'}',
          loc.t.thermalPrint.invoice.tableNoLabel(tableName: kotInvoice.table?.name ?? 'Take Away'),
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
          textAlign: thermer.TextAlign.start,
        ),

        // Date
        thermer.ThermerText(
          // 'Date: ${kotInvoice.dateTime ?? 'N/A'}',
          loc.t.thermalPrint.invoice.dateLabel(dateTime: kotInvoice.dateTime ?? 'N/A'),
          style: thermer.TextStyle(
            fontSize: 24,
            fontWeight: thermer.FontWeight.w500,
            color: thermer.Colors.black,
          ),
          textAlign: thermer.TextAlign.start,
        ),
        thermer.ThermerSizedBox(height: 8),

        //--------------------Product Table--------------------//
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
          ]),
          data: List.generate(kotInvoice.items?.length ?? 0, (index) {
            final _item = (kotInvoice.items ?? [])[index];

            final _name = [
              _item.name ?? 'Not Defined',
              ..._item.options.map((option) => '• ${option.name}: ${option.price}'),
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
            ]);
          }),
          cellWidths: {
            0: 0.1,
            1: null,
            2: 0.2,
          },
          columnSpacing: 15.0,
          rowSpacing: 3.0,
        ),
        thermer.ThermerDivider.horizontal(),

        // Total Items
        thermer.ThermerRow(
          children: [
            thermer.ThermerText(
              // 'Items: ${kotInvoice.items?.length ?? 0}',
              loc.t.thermalPrint.summary.itemsCount(count: kotInvoice.items?.length ?? 0),
              textAlign: thermer.TextAlign.start,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
            thermer.ThermerText(
              // 'Qty: ${kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0}',
              loc.t.thermalPrint.summary.qtyTotal(
                totalQty: kotInvoice.items?.fold<int>(0, (p, eV) => p + (eV.quantity)) ?? 0,
              ),
              textAlign: thermer.TextAlign.center,
              style: thermer.TextStyle(
                fontSize: 24,
                fontWeight: thermer.FontWeight.bold,
                color: thermer.Colors.black,
              ),
            ),
          ],
          mainAxisAlignment: thermer.ThermerMainAxisAlignment.spaceBetween,
        ),

        // White Space
        thermer.ThermerSizedBox(height: 200)
      ],
    );

    return _layout.generateImage();
  }
}
