part of '../expense_list_view.dart';

class AllExpenseList extends ConsumerWidget {
  const AllExpenseList({super.key, required this.provider});
  final AllExpenseListViewNotifier provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _theme = Theme.of(context);

    final _expenseCategories = ref.watch(expenseCategoryDropdownProvider);

    return Column(
      children: [
        // Search Field
        CustomSearchField(
          controller: provider.searchController,
          decoration: CustomSearchFieldDecoration(
            // hintText: 'Search...',
            hintText: context.t.common.search,
          ),
          onTapFilter: () async {
            return await showFilterModalSheet<ExpenseFilter, dynamic>(
              context: context,
              selectedFilters: provider.filters,
              filters: [
                FilterModalData.dropdown(
                  key: ExpenseFilter.category,
                  // labelText: 'Expense Category',
                  labelText: context.t.form.expense.label,
                  // hintText: 'Select expense category',
                  hintText: context.t.form.expense.hint,
                  items: _expenseCategories.when(
                    data: (data) => [
                      ...?data.data?.data?.map((category) {
                        return CustomDropdownMenuItem<int>(
                          value: category.id,
                          label: TextSpan(
                            text: category.categoryName ?? 'N/A',
                          ),
                        );
                      }),
                    ],
                    error: (e, s) => [],
                    loading: () => [],
                  ),
                ),
              ],
              onSave: provider.handleFilter,
            );
          },
          appliedFilterCount: provider.filterCount,
          onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
            provider.pagingController.refresh,
          ),
        ).fMarginLTRB(16, 15, 16, 0),

        // Expense List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => Future.sync(provider.pagingController.refresh),
            child: PagedListView<int, Expense>.separated(
              padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              pagingController: provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<Expense>(
                itemBuilder: (c, expense, i) {
                  final _tileData = IncomeExpenseListTileData(
                    name: expense.expanseFor ?? 'N/A',
                    amount: expense.amount ?? 0,
                    categoryName: expense.category?.categoryName,
                    date: expense.expenseDate,
                  );
                  return IncomeExpenseListTile(
                    tileData: _tileData,
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) {
                        return [
                          (context.t.common.view, 'view', Icons.visibility_outlined),
                          if (ref.can(PMKeys.expense, action: PermissionAction.update)) ...[
                            (context.t.common.edit, 'edit', FeatherIcons.edit),
                          ],
                          if (ref.can(PMKeys.expense, action: PermissionAction.delete)) ...[
                            (context.t.common.delete, 'delete', FeatherIcons.trash2),
                          ],
                        ].map((menu) {
                          return PopupMenuItem<String>(
                            value: menu.$2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  menu.$3,
                                  size: 18,
                                  color: _theme.colorScheme.secondary,
                                ),
                                const SizedBox.square(dimension: 8),
                                Text(menu.$1),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (v) async {
                        return switch (v) {
                          'view' => _handleViewDetails(context, expense),
                          'edit' => _handleEditRoute(context, expense),
                          'delete' => _handleDelete(
                            context,
                            () => provider.repo.deleteExpense(expense.id!),
                          ),
                          _ => null,
                        };
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
                        context.t.exceptions.noExpenseFoundPleaseTryAddingExpense,
                        onRetry: provider.pagingController.refresh,
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
    );
  }

  Future<void> _handleEditRoute(BuildContext context, Expense data) async {
    return await context.router.push<void>(
      ManageExpenseRoute(editModel: data),
    );
  }

  Future<void> _handleViewDetails(BuildContext context, Expense data) async {
    return await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (modalContext) {
        final _theme = Theme.of(context);
        final _style = _theme.textTheme.bodyLarge;
        return BottomModalSheetWrapper(
          title: TextSpan(text: context.t.common.viewDetails),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...{
                  context.t.common.title: data.expanseFor ?? 'N/A',
                  context.t.common.category(n: 1): data.category?.categoryName ?? "N/A",
                  context.t.common.amount: (data.amount ?? 0).quickCurrency(),
                  context.t.common.date: data.expenseDate?.getFormatedString(pattern: 'dd MMMM yyyy') ?? "N/A",
                  context.t.common.note: data.note ?? "N/A",
                }.entries.map(
                  (entry) {
                    return KeyValueRow(
                      title: entry.key,
                      titleFlex: 3,
                      titleStyle: _style?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                      description: entry.value,
                      descriptionFlex: 7,
                      descriptionStyle: _style?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.exceptions.doYouWantToDeleteThisExpense,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(callback),
      );

      if (context.mounted) {
        if (_result.isFailure) {
          showCustomSnackBar(
            context,
            content: Text(_result.left!),
            customSnackBarType: CustomOverlayType.error,
          );
          return;
        }
      }
    }
  }
}
