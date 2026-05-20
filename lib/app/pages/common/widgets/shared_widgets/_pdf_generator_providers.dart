import 'package:flutter/material.dart' show DateTimeRange;

import '../../../../data/repository/repository.dart';

final saleReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _saleReport = await Future.microtask(
        () => ref
            .read(saleRepoProvider)
            .getSaleReportList(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_saleReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<SalesReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: SalesReportPDF(
            data: [
              ...?_saleReport.data?.data?.map((sale) {
                return (
                  invoiceNumber: sale.invoiceNumber ?? "N/A",
                  saleDate: sale.saleDate,
                  sale: sale.totalAmount ?? 0,
                  moneyIn: sale.paidAmount ?? 0,
                  paymentType: sale.paymentMethod?.name ?? "N/A",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final saleQuotationReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _quotationReport = await Future.microtask(
        () => ref
            .read(saleRepoProvider)
            .getQuotationReportList(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_quotationReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<QuotationSalesReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: QuotationSalesReportPDF(
            data: [
              ...?_quotationReport.data?.data?.map((quotation) {
                return (
                  invoiceNumber: quotation.invoiceNumber ?? 'N/A',
                  saleDate: quotation.quotationDate,
                  quotationSale: quotation.totalAmount ?? 0,
                  moneyIn: 0,
                  paymentType: quotation.paymentMethod?.name ?? 'N/A',
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final purchaseReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _purchaseReport = await Future.microtask(
        () => ref
            .read(purchaseRepoProvider)
            .getPurchaseReportList(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_purchaseReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<PurchaseReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: PurchaseReportPDF(
            data: [
              ...?_purchaseReport.data?.data?.map((purchase) {
                return (
                  invoiceNumber: purchase.invoiceNumber ?? "N/A",
                  purchaseDate: purchase.purchaseDate,
                  totalAmount: purchase.totalAmount ?? 0,
                  paidAmount: purchase.paidAmount ?? 0,
                  dueAmount: purchase.dueAmount ?? 0,
                  paymentType: purchase.paymentMethod?.name ?? "N/A",
                  status: purchase.isPartial
                      ? "Partial"
                      : purchase.isPaid
                      ? "Paid"
                      : "Due",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final stockReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    throw UnimplementedError();
    /*
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _stockReport = await Future.microtask(
        () => ref.read(itemsRepoProvider).getStockItemReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_stockReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<StockReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: StockReportPDF(
            data: [
              ...?_stockReport.data?.data?.map((stock) {
                return (
                  itemName: stock.productName ?? "N/A",
                  purchasePrice: stock.finalPurchasePrice ?? 0,
                  salePrice: stock.finalPurchasePrice ?? 0,
                  itemStock: stock.stocksSumProductStock ?? 0,
                  stockValue: stock.stockValue ?? 0,
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  */
  },
);

final dueReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _dueReport = await Future.microtask(
        () => ref
            .read(dueRepoProvider)
            .getDueReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_dueReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<DueReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: DueReportPDF(
            data: [
              ...?_dueReport.data?.data?.map((due) {
                return (
                  invoice: due.invoiceNumber ?? "N/A",
                  date: due.date,
                  purchaseAmount: due.totalAmount ?? 0,
                  dueAmount: due.dueAmount ?? 0,
                  paymentType: due.paymentMethod?.name ?? "N/A",
                  status: due.isPartial
                      ? "Partial"
                      : due.isPaid
                      ? "Paid"
                      : "Due",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final dueCollectionReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _dueCollectionReport = await Future.microtask(
        () => ref
            .read(dueRepoProvider)
            .getDueCollectionReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_dueCollectionReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<DueCollectionReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: DueCollectionReportPDF(
            data: [
              ...?_dueCollectionReport.data?.data?.map((dueCollection) {
                return (
                  invoice: dueCollection.invoiceNumber ?? "N/A",
                  date: dueCollection.paymentDate,
                  purchaseAmount: dueCollection.totalDue ?? 0,
                  paidAmount: dueCollection.payDueAmount ?? 0,
                  dueAmount: dueCollection.dueAmountAfterPay ?? 0,
                  paymentType: dueCollection.paymentType?.name ?? 'N/A',
                  status: dueCollection.isPartiallyPaid ? 'Partial' : 'Paid',
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final transactionReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _transactionReport = await Future.microtask(
        () => ref
            .read(partyRepoProvider)
            .getTransactionReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_transactionReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<TransactionReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: TransactionReportPDF(
            data: [
              ...?_transactionReport.data?.data?.map((transaction) {
                return (
                  invoice: transaction.invoiceNumber ?? "N/A",
                  date: transaction.date,
                  purchaseAmount: transaction.isPurchase ? transaction.totalAmount : null,
                  saleAmount: transaction.isSale ? transaction.totalAmount : null,
                  dueAmount: transaction.isPurchase ? transaction.dueAmount : null,
                  paymentType: transaction.paymentType?.name ?? "N/A",
                  status: transaction.isPurchase
                      ? transaction.isPaid
                            ? "Paid"
                            : "Due"
                      : "Money In",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final incomeReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _incomeReport = await Future.microtask(
        () => ref
            .read(incomeRepoProvider)
            .getIncomeReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_incomeReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<IncomeReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: IncomeReportPDF(
            data: [
              ...?_incomeReport.data?.data?.map((income) {
                return (
                  date: income.incomeDate,
                  incomeName: income.incomeFor ?? 'N/A',
                  category: income.category?.categoryName ?? "N/A",
                  amount: income.amount ?? 0,
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final expensePDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _expenseReport = await Future.microtask(
        () => ref
            .read(expenseRepoProvider)
            .getExpenseReport(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_expenseReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<ExpenseReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: ExpenseReportPDF(
            data: [
              ...?_expenseReport.data?.data?.map((expense) {
                return (
                  date: expense.expenseDate,
                  expenseName: expense.expanseFor ?? 'N/A',
                  category: expense.category?.categoryName ?? "N/A",
                  amount: expense.amount ?? 0,
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final partyLedgerReportPDFProvider = FutureProvider.autoDispose.family<File, ({DateTimeRange range, Party party})>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;
    final _isCustomer = arg.party.type?.trim().toLowerCase() == 'customer';

    try {
      final _ledgerReport = await Future.microtask(
        () => ref
            .read(partyRepoProvider)
            .getPartyLedger(
              partyId: arg.party.id!,
              partyType: arg.party.type!,
              noPaging: true,
              fromDate: arg.range.start.dbFormat,
              toDate: arg.range.end.dbFormat,
            ),
      );
      if (_ledgerReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<PartyLedgerReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg.range,
          reportType: PartyLedgerReportPDF(
            partyInfo: (
              partyName: arg.party.name ?? "N/A",
              isCustomer: _isCustomer,
            ),
            data: [
              ...?_ledgerReport.data?.data?.map((transaction) {
                return (
                  invoiceNumber: transaction.invoiceNumber ?? "N/A",
                  invoiceDate: _isCustomer ? transaction.saleDate : transaction.purchaseDate,
                  amount: transaction.totalAmount ?? 0,
                  moneyIn: transaction.paidAmount ?? 0,
                  paymentType: transaction.paymentType?.name ?? "N/A",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final salePurchaseInvoicePDFProvider = FutureProvider.autoDispose.family<File, SalePurchaseThermalInvoiceData>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _generator = PDFGenerator(
        template: SalePurchaseInvoiceTemplate(arg.copyWith(user: _user)),
      );
      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final kotOrderReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    final _user = ref.read(userRepositoryProvider).value;

    try {
      final _kotReport = await Future.microtask(
        () => ref
            .read(saleRepoProvider)
            .getKOTOrderReportList(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_kotReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<KOTOrderReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: KOTOrderReportPDF(
            data: [
              ...?_kotReport.data?.data?.map((kot) {
                return (
                  kotInvoice: kot.kotInvoiceNumber ?? "N/A",
                  orderInvoice: kot.invoiceNumber ?? "N/A",
                  saleDate: kot.saleDate,
                  table: kot.kotTable?.name ?? "N/A",
                  customerName: kot.party?.name ?? "Guest",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final attendanceReportPDFProvider = FutureProvider.autoDispose.family<File, DateTimeRange>(
  (ref, arg) async {
    try {
      final _user = await ref.read(userRepositoryProvider.future);

      final _attendanceReport = await Future.microtask(
        () => ref
            .read(attendanceRepoProvider)
            .getAttendanceReportList(
              noPaging: true,
              fromDate: arg.start.dbFormat,
              toDate: arg.end.dbFormat,
            ),
      );
      if (_attendanceReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<AttendanceReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          duration: arg,
          reportType: AttendanceReportPDF(
            data: [
              ...?_attendanceReport.data?.data?.map((attendance) {
                return (
                  date: attendance.date,
                  name: attendance.employee?.name,
                  shift: attendance.shift?.name,
                  timeIn: attendance.timeIn,
                  timeOut: attendance.timeOut,
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final leaveReportPDFProvider = FutureProvider.autoDispose.family<File, ({String? month, int? employeeId})>(
  (ref, arg) async {
    try {
      final _user = await ref.read(userRepositoryProvider.future);

      final _leaveReport = await Future.microtask(
        () => ref
            .read(leaveRepoProvider)
            .getLeaveReportList(
              noPaging: true,
              month: arg.month,
              employeeId: arg.employeeId,
            ),
      );
      if (_leaveReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<LeaveReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          reportType: LeaveReportPDF(
            data: [
              ...?_leaveReport.data?.data?.map((leave) {
                return (
                  name: leave.employee?.name,
                  month: leave.month,
                  startDate: leave.startDate,
                  endDate: leave.endDate,
                  leaveType: leave.leaveType?.name,
                  duration: leave.leaveDuration,
                  status: leave.status,
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);

final payrollReportPDFProvider = FutureProvider.autoDispose.family<File, ({String? month, int? employeeId})>(
  (ref, arg) async {
    try {
      final _user = await ref.read(userRepositoryProvider.future);

      final _payrollReport = await Future.microtask(
        () => ref
            .read(payrollRepoProvider)
            .getPayrollReportList(
              noPaging: true,
              month: arg.month,
              employeeId: arg.employeeId,
            ),
      );
      if (_payrollReport.data?.data?.isEmpty ?? true) {
        throw Exception("No Data Found");
      }

      final _generator = PDFGenerator(
        template: ReportPDFTemplate<PayrollReportPDF>(
          storeName: _user?.business?.companyName ?? 'N/A',
          reportType: PayrollReportPDF(
            data: [
              ...?_payrollReport.data?.data?.map((payroll) {
                return (
                  name: payroll.employee?.name,
                  date: payroll.date,
                  slipNo: payroll.puid,
                  amount: payroll.amount,
                  paymentType: payroll.paymentType?.name,
                  status: (payroll.amount != null && payroll.amount! > 0) ? "Paid" : "Unpaid",
                );
              }),
            ],
          ),
        ),
      );

      return await _generator.getPDFFile();
    } catch (e) {
      throw Exception(e);
    }
  },
);
