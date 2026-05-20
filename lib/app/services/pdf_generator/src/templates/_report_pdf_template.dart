import 'package:flutter/material.dart' show DateTimeRange;

import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/core.dart';

import 'templates.dart';

abstract class ReportType {
  String get reportName;
  List<ReportTableColumn> get headerColumns;
  List<List<ReportTableColumn>> get dataRows => [];
  List<ReportTableColumn> get bottomRow => [];
}

class ReportPDFTemplate<T extends ReportType> extends PDFTemplateBase {
  ReportPDFTemplate({
    required this.reportType,
    required this.storeName,
    this.duration,
  });

  final String storeName;
  final DateTimeRange? duration;
  final T reportType;

  @override
  Future<pw.Page> get page async {
    final _cellPadding = pw.EdgeInsetsDirectional.symmetric(
      horizontal: 2,
      vertical: 4.5,
    );

    return pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: pdf.PdfPageFormat.a4.copyWith(
          marginLeft: 20,
          marginTop: 20,
          marginRight: 20,
          marginBottom: 20,
        ),
      ),
      header: (context) {
        if (context.pageNumber != 1) {
          return pw.SizedBox.shrink();
        }
        return pw.Align(
          alignment: pw.AlignmentDirectional.topCenter,
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Store Name
              pw.Text(
                storeName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox.square(dimension: 4),

              // Report Name
              pw.Text(
                reportType.reportName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox.square(dimension: 6),

              // Duration
              if (duration != null) ...[
                pw.Text(
                  'Duration ${duration!.start.toString().substring(0, 10)}-${duration!.start.toString().substring(0, 10)}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
      build: (context) {
        return [
          pw.SizedBox.square(dimension: 12),

          // Data Table
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(
              color: pdf.PdfColor.fromHex('D9D9D9'),
            ),
            columnWidths: <int, pw.TableColumnWidth>{
              ...reportType.headerColumns.asMap().map((key, value) {
                return MapEntry(key, value.width ?? pw.FlexColumnWidth());
              }),
            },
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: pdf.PdfColors.white,
              fontSize: 12,
            ),
            headerPadding: _cellPadding,
            headerDecoration: pw.BoxDecoration(
              color: pdf.PdfColor.fromInt(
                DAppColors.kPrimary.toARGB32(),
              ),
              border: pw.Border.all(
                color: pdf.PdfColor.fromHex('D9D9D9'),
              ),
            ),
            headerAlignment: pw.Alignment.center,
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(
              color: pdf.PdfColors.black,
              fontSize: 12,
            ),
            headers: [...reportType.headerColumns.map((cell) => cell.label)],
            data: [
              ...reportType.dataRows.map((row) {
                return [...row.map((cell) => cell.label)];
              }),
            ],
          ),

          // Footer Row
          pw.Table(
            columnWidths: <int, pw.TableColumnWidth>{
              ...reportType.bottomRow.asMap().map((key, value) {
                return MapEntry(key, value.width ?? pw.FlexColumnWidth());
              }),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: pdf.PdfColor.fromInt(
                    DAppColors.kPrimary.toARGB32(),
                  ),
                ),
                children: [
                  ...List.generate(reportType.bottomRow.length, (index) {
                    final _cell = reportType.bottomRow[index];

                    return pw.Container(
                      padding: index == 0 ? _cellPadding.add(pw.EdgeInsetsDirectional.only(start: 16)) : _cellPadding,
                      alignment: index == 0 ? pw.AlignmentDirectional.centerStart : pw.AlignmentDirectional.center,
                      color: index == 0 ? pdf.PdfColor.fromInt(DAppColors.kPrimary.toARGB32()) : null,
                      child: pw.Text(
                        _cell.label,
                        style: pw.TextStyle(
                          color: pdf.PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ];
      },
      footer: (context) {
        return pw.Row(
          children: [
            pw.Expanded(child: pw.Text('Development By: ${AppConfig.orgDomain}')),
            pw.Expanded(
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  String get fileName {
    return '${reportType.reportName}_${duration == null ? '' : '${duration!.start.toIso8601String()}_${duration!.end.toIso8601String()}'}';
  }
}

typedef ReportTableColumn = ({String label, pw.TableColumnWidth? width});

class SalesReportPDF extends ReportType {
  SalesReportPDF({required this.data});
  final List<({String invoiceNumber, DateTime? saleDate, num sale, num moneyIn, String paymentType})> data;

  @override
  String get reportName => 'Sales Report';
  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(32)),
      (label: "Invoice", width: pw.FixedColumnWidth(100)),
      (label: "Date", width: pw.FixedColumnWidth(115)),
      (label: "Sales", width: pw.FixedColumnWidth(105)),
      (label: "Money In", width: pw.FixedColumnWidth(105)),
      (label: "Payment Type", width: pw.FixedColumnWidth(135)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoiceNumber, width: null),
        (label: _data.saleDate?.getFormatedString() ?? "N/A", width: null),
        (label: _data.sale.quickCurrency(), width: null),
        (label: _data.moneyIn.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalSales = data.fold<num>(
      0,
      (sum, item) => sum + item.sale,
    );
    final _totalMoneyIn = data.fold<num>(
      0,
      (sum, item) => sum + item.moneyIn,
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(232)),
      (label: _totalSales.quickCurrency(), width: pw.FixedColumnWidth(85)),
      (label: _totalMoneyIn.quickCurrency(), width: pw.FixedColumnWidth(85)),
      (label: '', width: pw.FlexColumnWidth(180)),
    ];
  }
}

class QuotationSalesReportPDF extends ReportType {
  QuotationSalesReportPDF({required this.data});
  final List<({String invoiceNumber, DateTime? saleDate, num quotationSale, num moneyIn, String paymentType})> data;

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(32)),
      (label: "Invoice", width: pw.FixedColumnWidth(100)),
      (label: "Date", width: pw.FixedColumnWidth(115)),
      (label: "Quotation Sale", width: pw.FixedColumnWidth(105)),
      (label: "Money In", width: pw.FixedColumnWidth(105)),
      (label: "Payment Type", width: pw.FixedColumnWidth(135)),
    ];
  }

  @override
  String get reportName => 'Quotation Sales Report';

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoiceNumber, width: null),
        (label: _data.saleDate?.getFormatedString() ?? "N/A", width: null),
        (label: _data.quotationSale.quickCurrency(), width: null),
        (label: _data.moneyIn.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }
}

class PurchaseReportPDF extends ReportType {
  PurchaseReportPDF({required this.data});
  final List<
    ({
      String invoiceNumber,
      DateTime? purchaseDate,
      num totalAmount,
      num paidAmount,
      num dueAmount,
      String paymentType,
      String status,
    })
  >
  data;

  @override
  String get reportName => 'Purchase Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FlexColumnWidth(4)),
      (label: "Invoice", width: pw.FlexColumnWidth(8)),
      (label: "Date", width: pw.FlexColumnWidth(8)),
      (label: "Total", width: pw.FlexColumnWidth(9)),
      (label: "Paid", width: pw.FlexColumnWidth(9)),
      (label: "Due", width: pw.FlexColumnWidth(9)),
      (label: "Payment Type", width: pw.FlexColumnWidth(10)),
      (label: "Status", width: pw.FlexColumnWidth(6)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoiceNumber, width: null),
        (label: _data.purchaseDate?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.totalAmount.quickCurrency(), width: null),
        (label: _data.paidAmount.quickCurrency(), width: null),
        (label: _data.dueAmount.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
        (label: _data.status, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final totalPurchase = data.fold<num>(
      0,
      (sum, item) => sum + item.totalAmount,
    );
    final totalPaidAmount = data.fold<num>(
      0,
      (sum, item) => sum + item.paidAmount,
    );
    final totalDueAmount = data.fold<num>(
      0,
      (sum, item) => sum + item.dueAmount,
    );

    return [
      (label: 'Total', width: pw.FlexColumnWidth(20)),
      (label: totalPurchase.quickCurrency(), width: pw.FlexColumnWidth(8)),
      (label: totalPaidAmount.quickCurrency(), width: pw.FlexColumnWidth(8)),
      (label: totalDueAmount.quickCurrency(), width: pw.FlexColumnWidth(8)),
      (label: '', width: pw.FlexColumnWidth(8)),
      (label: '', width: pw.FlexColumnWidth(8)),
      (label: '', width: pw.FlexColumnWidth(2.75)),
    ];
  }
}

class StockReportPDF extends ReportType {
  StockReportPDF({required this.data});
  final List<
    ({
      String itemName,
      num purchasePrice,
      num salePrice,
      int itemStock,
      num stockValue,
    })
  >
  data;

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Name", width: pw.FixedColumnWidth(170)),
      (label: "Purchase", width: pw.FixedColumnWidth(90)),
      (label: "Sale", width: pw.FixedColumnWidth(90)),
      (label: "Stock", width: pw.FixedColumnWidth(70)),
      (label: "Stock Value", width: pw.FixedColumnWidth(110)),
    ];
  }

  @override
  String get reportName => 'Stock Report';

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.itemName, width: null),
        (label: _data.purchasePrice.quickCurrency(), width: null),
        (label: _data.salePrice.quickCurrency(), width: null),
        (label: _data.itemStock.quickCurrency(customCurrency: ''), width: null),
        (label: _data.stockValue.quickCurrency(), width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalPurchase = data.fold<num>(
      0,
      (sum, item) => sum + item.purchasePrice,
    );
    final _totalSale = data.fold<num>(
      0,
      (sum, item) => sum + item.salePrice,
    );
    final _totalStock = data.fold<num>(
      0,
      (sum, item) => sum + item.itemStock,
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(202)),
      (label: _totalPurchase.quickCurrency(), width: pw.FixedColumnWidth(90)),
      (label: _totalSale.quickCurrency(), width: pw.FixedColumnWidth(90)),
      (label: _totalStock.quickCurrency(), width: pw.FixedColumnWidth(70)),
      (label: '', width: pw.FlexColumnWidth(110)),
    ];
  }
}

class DueReportPDF extends ReportType {
  DueReportPDF({required this.data});
  final List<
    ({
      String invoice,
      DateTime? date,
      num purchaseAmount,
      num dueAmount,
      String paymentType,
      String status,
    })
  >
  data;

  @override
  String get reportName => 'Due Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Invoice", width: pw.FixedColumnWidth(65)),
      (label: "Date", width: pw.FixedColumnWidth(110)),
      (label: "Purchase", width: pw.FixedColumnWidth(95)),
      (label: "Due", width: pw.FixedColumnWidth(95)),
      (label: "Payment Type", width: pw.FixedColumnWidth(120)),
      (label: "Status", width: pw.FixedColumnWidth(60)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoice, width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.purchaseAmount.quickCurrency(), width: null),
        (label: _data.dueAmount.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
        (label: _data.status, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalPurchase = data.fold<num>(
      0,
      (sum, item) => sum + item.purchaseAmount,
    );

    final _totalDue = data.fold<num>(
      0,
      (sum, item) => sum + item.dueAmount,
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(200)),
      (label: _totalPurchase.quickCurrency(), width: pw.FixedColumnWidth(95)),
      (label: _totalDue.quickCurrency(), width: pw.FixedColumnWidth(95)),
      (label: '', width: pw.FlexColumnWidth(180)),
    ];
  }
}

class DueCollectionReportPDF extends ReportType {
  DueCollectionReportPDF({required this.data});
  final List<
    ({
      String invoice,
      DateTime? date,
      num purchaseAmount,
      num paidAmount,
      num dueAmount,
      String paymentType,
      String status,
    })
  >
  data;

  @override
  String get reportName => 'Due Collection Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Invoice", width: pw.FixedColumnWidth(95)),
      (label: "Date", width: pw.FixedColumnWidth(90)),
      (label: "Purchase", width: pw.FixedColumnWidth(95)),
      (label: "Paid", width: pw.FixedColumnWidth(95)),
      (label: "Due", width: pw.FixedColumnWidth(95)),
      (label: "Payment Type", width: pw.FixedColumnWidth(120)),
      (label: "Status", width: pw.FixedColumnWidth(60)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoice, width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.purchaseAmount.quickCurrency(), width: null),
        (label: _data.paidAmount.quickCurrency(), width: null),
        (label: _data.dueAmount.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
        (label: _data.status, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalPurchase = data.fold<num>(
      0,
      (sum, item) => sum + item.purchaseAmount,
    );

    final _totalPaid = data.fold<num>(
      0,
      (sum, item) => sum + item.paidAmount,
    );

    final _totalDue = data.fold<num>(
      0,
      (sum, item) => sum + item.dueAmount,
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(178)),
      (label: _totalPurchase.quickCurrency(), width: pw.FixedColumnWidth(75)),
      (label: _totalPaid.quickCurrency(), width: pw.FixedColumnWidth(75)),
      (label: _totalDue.quickCurrency(), width: pw.FixedColumnWidth(75)),
      (label: '', width: pw.FlexColumnWidth(200)),
    ];
  }
}

class TransactionReportPDF extends ReportType {
  TransactionReportPDF({required this.data});
  final List<
    ({
      String invoice,
      DateTime? date,
      num? purchaseAmount,
      num? saleAmount,
      num? dueAmount,
      String paymentType,
      String status,
    })
  >
  data;

  @override
  String get reportName => 'Transaction Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Invoice", width: pw.FixedColumnWidth(65)),
      (label: "Date", width: pw.FixedColumnWidth(95)),
      (label: "Purchase", width: pw.FixedColumnWidth(85)),
      (label: "Sales", width: pw.FixedColumnWidth(85)),
      (label: "Due", width: pw.FixedColumnWidth(85)),
      (label: "Payment Type", width: pw.FixedColumnWidth(95)),
      (label: "Status", width: pw.FixedColumnWidth(65)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoice, width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.purchaseAmount?.quickCurrency() ?? "N/A", width: null),
        (label: _data.saleAmount?.quickCurrency() ?? "N/A", width: null),
        (label: _data.dueAmount?.quickCurrency() ?? "N/A", width: null),
        (label: _data.paymentType, width: null),
        (label: _data.status, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalPurchase = data.fold<num>(
      0,
      (sum, item) => sum + (item.purchaseAmount ?? 0),
    );

    final _totalSale = data.fold<num>(
      0,
      (sum, item) => sum + (item.saleAmount ?? 0),
    );

    final _totalDue = data.fold<num>(
      0,
      (sum, item) => sum + (item.dueAmount ?? 0),
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(177)),
      (label: _totalPurchase.quickCurrency(), width: pw.FixedColumnWidth(80)),
      (label: _totalSale.quickCurrency(), width: pw.FixedColumnWidth(80)),
      (label: _totalDue.quickCurrency(), width: pw.FixedColumnWidth(80)),
      (label: '', width: pw.FlexColumnWidth(200)),
    ];
  }
}

class IncomeReportPDF extends ReportType {
  IncomeReportPDF({required this.data});
  final List<
    ({
      DateTime? date,
      String incomeName,
      String category,
      num amount,
    })
  >
  data;

  @override
  String get reportName => 'Income Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Date", width: pw.FixedColumnWidth(95)),
      (label: "Income Name", width: pw.FixedColumnWidth(185)),
      (label: "Category", width: pw.FixedColumnWidth(155)),
      (label: "Amount", width: pw.FixedColumnWidth(100)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.incomeName, width: null),
        (label: _data.category, width: null),
        (label: _data.amount.quickCurrency(), width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalAmount = data.fold<num>(
      0,
      (sum, item) => sum + item.amount,
    );

    return [
      (label: 'Total', width: pw.FlexColumnWidth(1)),
      (label: _totalAmount.quickCurrency(), width: pw.FixedColumnWidth(97)),
    ];
  }
}

class ExpenseReportPDF extends ReportType {
  ExpenseReportPDF({required this.data});
  final List<
    ({
      DateTime? date,
      String expenseName,
      String category,
      num amount,
    })
  >
  data;

  @override
  String get reportName => 'Expense Report';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(34)),
      (label: "Date", width: pw.FixedColumnWidth(95)),
      (label: "Expense Name", width: pw.FixedColumnWidth(185)),
      (label: "Category", width: pw.FixedColumnWidth(155)),
      (label: "Amount", width: pw.FixedColumnWidth(100)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.expenseName, width: null),
        (label: _data.category, width: null),
        (label: _data.amount.quickCurrency(), width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalAmount = data.fold<num>(
      0,
      (sum, item) => sum + item.amount,
    );

    return [
      (label: 'Total', width: pw.FlexColumnWidth(1)),
      (label: _totalAmount.quickCurrency(), width: pw.FixedColumnWidth(97)),
    ];
  }
}

class PartyLedgerReportPDF extends ReportType {
  PartyLedgerReportPDF({required this.data, required this.partyInfo});
  final ({String partyName, bool isCustomer}) partyInfo;
  final List<
    ({
      String invoiceNumber,
      DateTime? invoiceDate,
      num amount,
      num moneyIn,
      String paymentType,
    })
  >
  data;

  @override
  String get reportName => 'Ledger: ${partyInfo.partyName}';

  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(32)),
      (label: "Invoice", width: pw.FixedColumnWidth(100)),
      (label: "Date", width: pw.FixedColumnWidth(115)),
      (label: partyInfo.isCustomer ? "Sales" : "Purchase", width: pw.FixedColumnWidth(105)),
      (label: partyInfo.isCustomer ? "Money In" : "Money Out", width: pw.FixedColumnWidth(105)),
      (label: "Payment Type", width: pw.FixedColumnWidth(135)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.invoiceNumber, width: null),
        (label: _data.invoiceDate?.getFormatedString() ?? "N/A", width: null),
        (label: _data.amount.quickCurrency(), width: null),
        (label: _data.moneyIn.quickCurrency(), width: null),
        (label: _data.paymentType, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }

  @override
  List<ReportTableColumn> get bottomRow {
    final _totalSales = data.fold<num>(
      0,
      (sum, item) => sum + item.amount,
    );
    final _totalMoneyIn = data.fold<num>(
      0,
      (sum, item) => sum + item.moneyIn,
    );

    return [
      (label: 'Total', width: pw.FixedColumnWidth(232)),
      (label: _totalSales.quickCurrency(), width: pw.FixedColumnWidth(85)),
      (label: _totalMoneyIn.quickCurrency(), width: pw.FixedColumnWidth(85)),
      (label: '', width: pw.FlexColumnWidth(180)),
    ];
  }
}

class KOTOrderReportPDF extends ReportType {
  KOTOrderReportPDF({required this.data});
  final List<({String kotInvoice, String orderInvoice, DateTime? saleDate, String table, String customerName})> data;

  @override
  String get reportName => 'All KOT Report';
  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(32)),
      (label: "KOT", width: pw.FixedColumnWidth(85)),
      (label: "Order", width: pw.FixedColumnWidth(85)),
      (label: "Date", width: pw.FixedColumnWidth(140)),
      (label: "Table", width: pw.FixedColumnWidth(105)),
      (label: "Customer", width: pw.FixedColumnWidth(135)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.kotInvoice, width: null),
        (label: _data.orderInvoice, width: null),
        (label: _data.saleDate?.getFormatedString(pattern: 'dd/MM/yyyy hh:mm a') ?? "N/A", width: null),
        (label: _data.table, width: null),
        (label: _data.customerName, width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }
}

class AttendanceReportPDF extends ReportType {
  AttendanceReportPDF({required this.data});
  final List<({DateTime? date, String? name, String? shift, DateTime? timeIn, DateTime? timeOut})> data;

  @override
  String get reportName => 'Attendance Reports';
  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "SL", width: pw.FixedColumnWidth(32)),
      (label: "Date", width: pw.FixedColumnWidth(95)),
      (label: "Name", width: pw.FixedColumnWidth(140)),
      (label: "Shift ", width: pw.FixedColumnWidth(100)),
      (label: "Time In", width: pw.FixedColumnWidth(120)),
      (label: "Time Out", width: pw.FixedColumnWidth(120)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: "${i + 1}", width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.name ?? "N/A", width: null),
        (label: _data.shift ?? "N/A", width: null),
        (label: _data.timeIn?.getFormatedString(pattern: 'hh:mm a') ?? "N/A", width: null),
        (label: _data.timeOut?.getFormatedString(pattern: 'hh:mm a') ?? "N/A", width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }
}

class LeaveReportPDF extends ReportType {
  LeaveReportPDF({required this.data});
  final List<
    ({
      String? name,
      String? month,
      DateTime? startDate,
      DateTime? endDate,
      String? leaveType,
      int? duration,
      String? status,
    })
  >
  data;

  @override
  String get reportName => 'Leave Reports';
  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "Employee ", width: pw.FixedColumnWidth(140)),
      (label: "Month", width: pw.FixedColumnWidth(120)),
      (label: "Start Date", width: pw.FixedColumnWidth(120)),
      (label: "End Date", width: pw.FixedColumnWidth(120)),
      (label: "Leave Type", width: pw.FixedColumnWidth(140)),
      (label: "Duration ", width: pw.FixedColumnWidth(85)),
      (label: "Status", width: pw.FixedColumnWidth(135)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: _data.name ?? "N/A", width: null),
        (label: _data.month ?? "N/A", width: null),
        (label: _data.startDate?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.endDate?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.leaveType ?? "N/A", width: null),
        (label: (_data.duration != null ? "${_data.duration} days" : "N/A"), width: null),
        (label: _data.status ?? "N/A", width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }
}

class PayrollReportPDF extends ReportType {
  PayrollReportPDF({required this.data});
  final List<
    ({
      String? name,
      DateTime? date,
      String? slipNo,
      num? amount,
      String? paymentType,
      String? status,
    })
  >
  data;

  @override
  String get reportName => 'Payroll Reports';
  @override
  List<ReportTableColumn> get headerColumns {
    return [
      (label: "Employee", width: pw.FixedColumnWidth(140)),
      (label: "Date", width: pw.FixedColumnWidth(90)),
      (label: "Slip No", width: pw.FixedColumnWidth(95)),
      (label: "Amount", width: pw.FixedColumnWidth(90)),
      (label: "Payment", width: pw.FixedColumnWidth(110)),
      (label: "Status", width: pw.FixedColumnWidth(110)),
    ];
  }

  @override
  List<List<ReportTableColumn>> get dataRows {
    final _dataColumn = <List<ReportTableColumn>>[];
    for (var i = 0; i < data.length; i++) {
      final _data = data[i];
      final _row = <ReportTableColumn>[
        (label: _data.name ?? "N/A", width: null),
        (label: _data.date?.getFormatedString(pattern: 'dd/MM/yyyy') ?? "N/A", width: null),
        (label: _data.slipNo ?? "N/A", width: null),
        (label: _data.amount?.quickCurrency() ?? "N/A", width: null),
        (label: _data.paymentType ?? "N/A", width: null),
        (label: _data.status ?? "N/A", width: null),
      ];
      _dataColumn.add(_row);
    }

    return _dataColumn;
  }
}
