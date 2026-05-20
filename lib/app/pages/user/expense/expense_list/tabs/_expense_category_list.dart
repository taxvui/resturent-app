part of '../expense_list_view.dart';

class ExpenseCategoryList extends ConsumerWidget {
  const ExpenseCategoryList({super.key, required this.provider});
  final ExpenseCategoryListViewNotifier provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Search Field
        CustomSearchField(
          controller: provider.searchController,
          decoration: CustomSearchFieldDecoration(
            hintText: context.t.common.search,
          ),
          onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
            provider.pagingController.refresh,
          ),
        ).fMarginLTRB(16, 15, 16, 0),

        // Category List
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => Future.sync(provider.pagingController.refresh),
            child: PagedListView<int, ExpenseCategory>(
              padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              pagingController: provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<ExpenseCategory>(
                itemBuilder: (c, category, i) {
                  return ItemAttributeListTile(
                    name: TextSpan(text: category.categoryName),
                    onDelete: ref.canT(
                      PMKeys.expenseCategory,
                      action: PermissionAction.delete,
                      input: () async => await _handleDelete(
                        context,
                        () => provider.repo.deleteCategory(category.id!),
                      ),
                    ),
                    onEdit: ref.canT(
                      PMKeys.expenseCategory,
                      action: PermissionAction.update,
                      input: () async {
                        return await context.router.push<void>(
                          ManageExpenseCategoryRoute(editModel: category),
                        );
                      },
                    ),
                  );
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return EmptyWidget(
                    replaceDefault: false,
                    emptyBuilder: (context) {
                      return RetryButtons.scrollView(
                        context.t.exceptions.noExpenseCategoryFound,
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

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.exceptions.doYouWantToDeleteThisCategory,
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
