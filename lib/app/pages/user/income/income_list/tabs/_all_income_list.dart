part of '../income_list_view.dart';

class AllIncomeList extends ConsumerWidget {
  const AllIncomeList({super.key, required this.provider});
  final AllIncomeListViewNotifier provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _theme = Theme.of(context);

    final _incomeCategories = ref.watch(incomeCategoryDropdownProvider);

    return Column(
      children: [
        // Search Field
        CustomSearchField(
          controller: provider.searchController,
          decoration: CustomSearchFieldDecoration(
            // hintText: 'Search...',
            hintText: context.t.common.search,
          ),
          appliedFilterCount: provider.filterCount,
          onTapFilter: () async {
            return await showFilterModalSheet<IncomeFilter, dynamic>(
              context: context,
              selectedFilters: provider.filters,
              filters: [
                FilterModalData.dropdown(
                  key: IncomeFilter.category,
                  // labelText: 'Income Category',
                  labelText: context.t.form.income.incomeCategory.label,
                  // hintText: 'Select Income category',
                  hintText: context.t.form.income.incomeCategory.hint,
                  items: _incomeCategories.when(
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
          onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
            provider.pagingController.refresh,
          ),
        ).fMarginLTRB(16, 15, 16, 0),

        // Income List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => Future.sync(provider.pagingController.refresh),
            child: PagedListView<int, Income>.separated(
              padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              pagingController: provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<Income>(
                itemBuilder: (c, income, i) {
                  final _tileData = IncomeExpenseListTileData(
                    name: income.incomeFor ?? 'N/A',
                    amount: income.amount ?? 0,
                    categoryName: income.category?.categoryName,
                    date: income.incomeDate,
                  );
                  return IncomeExpenseListTile(
                    tileData: _tileData,
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) {
                        return [
                          (context.t.common.view, 'view', Icons.visibility_outlined),
                          if (ref.can(PMKeys.income, action: PermissionAction.update)) ...[
                            (context.t.common.edit, 'edit', FeatherIcons.edit),
                          ],
                          if (ref.can(PMKeys.income, action: PermissionAction.delete)) ...[
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
                          'view' => _handleViewDetails(context, income),
                          'edit' => _handleEditRoute(context, income),
                          'delete' => _handleDelete(
                            context,
                            () => provider.repo.deleteIncome(income.id!),
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
                        context.t.exceptions.noIncomeFound,
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

  Future<void> _handleEditRoute(BuildContext context, Income data) async {
    return await context.router.push<void>(
      ManageIncomeRoute(editModel: data),
    );
  }

  Future<void> _handleViewDetails(BuildContext context, Income data) async {
    return await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (modalContext) {
        final _theme = Theme.of(context);
        final _style = _theme.textTheme.bodyLarge;
        return BottomModalSheetWrapper(
          title: const TextSpan(text: 'View Details'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...{
                  context.t.common.title: data.incomeFor ?? 'N/A',
                  context.t.common.category(n: 1): data.category?.categoryName ?? "N/A",
                  context.t.common.amount: (data.amount ?? 0).quickCurrency(),
                  context.t.common.date: data.incomeDate?.getFormatedString(pattern: 'dd MMMM yyyy') ?? "N/A",
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
        title: context.t.exceptions.doYouWantToDeleteThisIncome,
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
