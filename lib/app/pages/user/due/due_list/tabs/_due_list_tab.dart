part of '../due_list_view.dart';

class DueListTab extends ConsumerWidget {
  const DueListTab({super.key, required this.provider});
  final DueListTabNotifier provider;

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

        // Due List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => Future.sync(provider.pagingController.refresh),
            child: PagedListView<int, DueModel>(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              pagingController: provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<DueModel>(
                itemBuilder: (c, due, i) {
                  return TransactionCard(
                    cardData: TransactionCardData(
                      cardType: TransactionCardType.dueReport(
                        primaryKey: due.isPurchaseDue ? 'Purchase' : 'Sale',
                        status: TransactionCardStatus.due,
                      ),
                      invoiceNumber: due.invoiceNumber ?? "N/A",
                      transactionDate: due.date,
                      paymentType: due.paymentMethod?.name,
                      primaryValue: due.totalAmount ?? 0,
                      secondaryValue: due.dueAmount ?? 0,
                    ),
                    action: ref.canT(
                      PMKeys.dueCollection,
                      action: PermissionAction.create,
                      input: PopupMenuButton<String>(
                        itemBuilder: (_) {
                          return [
                            if (ref.can(PMKeys.dueCollection, action: PermissionAction.create)) ...[
                              ('due_collection', context.t.pages.due.dueCollection),
                            ],
                          ].map((menu) {
                            return PopupMenuItem<String>(
                              value: menu.$1,
                              child: Text(menu.$2),
                            );
                          }).toList();
                        },
                        onSelected: (v) async {
                          if (v.trim().toLowerCase() == 'due_collection') {
                            return await _handleDueCollectionRoute(context, due);
                          }
                        },
                        child: const Icon(Icons.more_vert),
                      ),
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

  Future<void> _handleDueCollectionRoute(BuildContext context, DueModel due) async {
    return await context.router.push<void>(
      ManageDueCollectionRoute(
        collection: DueCollection(
          party: due.party,
          partyId: due.partyId,
          dueAmountAfterPay: due.dueAmount,
          refInvoiceNumber: due.invoiceNumber,
        ),
      ),
    );
  }
}
