import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';
import '../../../common/widgets/widgets.dart';

@RoutePage()
class PartyLedgerDetailsView extends ConsumerStatefulWidget {
  const PartyLedgerDetailsView({super.key, required this.party});
  final Party party;

  @override
  ConsumerState<PartyLedgerDetailsView> createState() => _PartyLedgerDetailsViewState();
}

class _PartyLedgerDetailsViewState extends ConsumerState<PartyLedgerDetailsView>
    with PaginatedControllerMixin<PartyLedger> {
  final dateFilterValue = ValueNotifier<DateFilterRowData>(DateFilterRowData());
  final totalAmount = ValueNotifier<num>(0);

  @override
  void initState() {
    initPaging();
    super.initState();
  }

  @override
  void dispose() {
    pageDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _isCustomer = widget.party.type?.trim().toLowerCase() == 'customer';

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox.square(
            dimension: 40,
            child: UserAvatarPicker(
              userName: widget.party.name,
              showInitialsPlaceholder: true,
              image: widget.party.image,
              foregroundColor: _theme.colorScheme.primary,
              backgroundColor: _theme.colorScheme.onPrimary,
              showBorder: false,
              fit: BoxFit.cover,
            ),
          ),
          horizontalTitleGap: 8,
          title: Text(widget.party.name ?? "N/A"),
          titleTextStyle: _theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _theme.colorScheme.onPrimary,
          ),
          subtitle: Text(context.t.pages.ledger.subTitle),
          subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
            color: _theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton.filledTonal(
            onPressed: () async {
              return await showAsyncLoadingOverlay<void>(
                context,
                asyncFunction: () {
                  return SharedWidgets.openFile(context, () {
                    return ref.read(
                      partyLedgerReportPDFProvider(
                        (
                          party: widget.party,
                          range: DateTimeRange(
                            start: dateFilterValue.value.dateRange.start,
                            end: dateFilterValue.value.dateRange.end,
                          ),
                        ),
                      ).future,
                    );
                  });
                },
              );
            },
            icon: const Icon(Icons.print),
            style: IconButton.styleFrom(
              backgroundColor: _theme.colorScheme.primaryContainer.withValues(
                alpha: 0.2,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Static Contents
          ValueListenableBuilder(
            valueListenable: dateFilterValue,
            builder: (_, value, _) {
              return DateFilterRow(
                value: value,
                onChanged: (value) {
                  dateFilterValue.value = value;
                  pagingController.refresh();
                },
              );
            },
          ),
          const SizedBox.square(dimension: 16),

          // Overview
          ValueListenableBuilder(
            valueListenable: totalAmount,
            builder: (_, value, _) {
              return OverviewContainer(
                label: _isCustomer ? context.t.common.totalSales : context.t.common.totalPurchase,
                value: value,
                isCurrency: true,
                color: Color(0xffFFF2E8),
              );
            },
          ).fMarginLTRB(16, 0, 16, 0),

          // Transaction List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, PartyLedger>.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<PartyLedger>(
                  itemBuilder: (c, ledger, i) {
                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: _isCustomer ? TransactionCardType.saleList() : TransactionCardType.purchaseList(),
                        invoiceNumber: ledger.invoiceNumber ?? "N/A",
                        transactionDate: _isCustomer ? ledger.saleDate : ledger.purchaseDate,
                        paymentType: ledger.paymentType?.name ?? "N/A",
                        primaryValue: ledger.totalAmount ?? 0,
                        secondaryValue: ledger.paidAmount ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          // 'No ledger found!\n Please try adding a ${_isCustomer ? 'sale' : 'purchase'}.',
                          context.t.exceptions.noLedgerFound(
                            transactionType: _isCustomer ? context.t.common.sales : context.t.common.purchase,
                          ),
                          onRetry: pagingController.refresh,
                        );
                      },
                    );
                  },
                ),
                separatorBuilder: (c, i) {
                  return const SizedBox.square(dimension: 6);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<PaginatedListModel<PartyLedger>> fetchData(int page) {
    return ref.read(
      partyLedgerListProvider((
        page: page,
        partyId: widget.party.id!,
        partyType: widget.party.type!,
        fromDate: dateFilterValue.value.dateRange.start.dbFormat,
        toDate: dateFilterValue.value.dateRange.end.dbFormat,
      )).future,
    );
  }

  @override
  void getRawData(PaginatedListModel<PartyLedger> data) {
    final _data = (data as PaginatedPartyLedgerListModel);

    totalAmount.value = _data.amount ?? 0;
    super.getRawData(data);
  }
}
