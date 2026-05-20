import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';

part '_category_list_view_provider.dart';

@RoutePage()
class CategoryListView extends ConsumerWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(categoryListViewProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        controller.initRefreshListener();
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.categoryList),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: controller.searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchHere,
              actions: [
                if (ref.can(PMKeys.categories, action: PermissionAction.create)) ...[
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.custom(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      return await context.router.push<void>(
                        ManageCategoryRoute(),
                      );
                    },
                    style: CustomSearchFieldActionButton.themeColored(context),
                  ),
                ],
              ],
            ),
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              controller.pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Category List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(controller.pagingController.refresh),
              child: PagedListView<int, ItemCategory>(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: controller.pagingController,
                builderDelegate: PagedChildBuilderDelegate<ItemCategory>(
                  itemBuilder: (c, category, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(text: category.categoryName),
                      onDelete: ref.canT(
                        PMKeys.categories,
                        action: PermissionAction.delete,
                        input: () async => await _handleDelete(
                          context,
                          () => controller.repo.deleteCategory(category.id!),
                        ),
                      ),
                      onEdit: ref.canT(
                        PMKeys.categories,
                        action: PermissionAction.update,
                        input: () async => await _handleEdit(context, category),
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noCategoryFound,
                          onRetry: controller.pagingController.refresh,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleEdit(BuildContext context, ItemCategory data) async {
    return await context.router.push<void>(
      ManageCategoryRoute(editModel: data),
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
