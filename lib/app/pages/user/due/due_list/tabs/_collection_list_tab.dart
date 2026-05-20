part of '../due_list_view.dart';

class CollectionListTab extends ConsumerWidget {
  const CollectionListTab({super.key, required this.provider});
  final DueCollectionListTabNotifier provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      provider.initRefreshListener();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Field
        CustomSearchField(
          controller: provider.searchController,
          appliedFilterCount: provider.filterCount,
          decoration: CustomSearchFieldDecoration(
            // hintText: 'Search invoice no...',
            hintText: context.t.common.searchInvoiceNumber,
          ),
          onTapFilter: () async {
            return showFilterModalSheet<String, dynamic>(
              context: context,
              selectedFilters: {...provider.filters},
              filters: [
                FilterModalData.radioTiles(
                  key: 'status',
                  items: [
                    RadioFilterModalData(
                      label: 'Paid',
                      value: 'paid',
                    ),
                    RadioFilterModalData(
                      label: 'Partial',
                      value: 'partial',
                    ),
                  ],
                ),
              ],
              onSave: (v) => provider.handleFilter(v),
            );
          },
          onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
            provider.pagingController.refresh,
          ),
        ).fMarginLTRB(16, 15, 16, 0),

        // Due Collection List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => Future.sync(provider.pagingController.refresh),
            child: PagedListView<int, DueCollection>(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              pagingController: provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<DueCollection>(
                itemBuilder: (c, dueCollection, i) {
                  late final TransactionCardStatus _status;
                  late final num _secondaryValue;

                  if (dueCollection.isFullyPaid) {
                    _status = TransactionCardStatus.paid;
                    _secondaryValue = dueCollection.totalDue ?? 0;
                  } else if (dueCollection.isPartiallyPaid) {
                    _status = TransactionCardStatus.partial;
                    _secondaryValue = dueCollection.dueAmountAfterPay ?? 0;
                  } else {
                    _status = TransactionCardStatus.due;
                    _secondaryValue = 0;
                  }

                  return TransactionCard(
                    cardData: TransactionCardData(
                      cardType: TransactionCardType.dueReport(
                        primaryKey: dueCollection.isPurchaseDue ? 'Purchase' : 'Sale',
                        status: _status,
                      ),
                      invoiceNumber: dueCollection.invoiceNumber ?? "N/A",
                      transactionDate: dueCollection.paymentDate,
                      paymentType: dueCollection.paymentType?.name,
                      primaryValue: dueCollection.totalDue ?? 0,
                      secondaryValue: _secondaryValue,
                    ),
                    action: !dueCollection.isLast
                        ? null
                        : PopupMenuButton<String>(
                            itemBuilder: (_) {
                              return [
                                ('view', context.t.common.view),
                                if (ref.can(PMKeys.dueCollection, action: PermissionAction.update)) ...[
                                  ('edit', context.t.common.edit),
                                ],
                              ].map((menu) {
                                return PopupMenuItem<String>(
                                  value: menu.$1,
                                  child: Text(menu.$2),
                                );
                              }).toList();
                            },
                            onSelected: (val) async {
                              final _v = val.trim().toLowerCase();

                              if (_v == 'view') {
                                return context.router.push<void>(
                                  InvoicePreviewRoute(
                                    previewType: ThermalPreview(
                                      DueCollectionThermalInvoiceData.fromDueCollect(dueCollection),
                                      isSale: true,
                                    ),
                                  ),
                                );
                              }
                              if (_v == 'edit') {
                                return await context.router.push<void>(
                                  ManageDueCollectionRoute(
                                    collection: dueCollection.copyWith(
                                      dueAmountAfterPay:
                                          (dueCollection.dueAmountAfterPay ?? 0) + (dueCollection.payDueAmount ?? 0),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Icon(Icons.more_vert),
                          ),
                  );
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return EmptyWidget(
                    replaceDefault: false,
                    emptyBuilder: (context) {
                      return RetryButtons.scrollView(
                        context.t.exceptions.noDueCollectionFound,
                        onRetry: provider.pagingController.refresh,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
