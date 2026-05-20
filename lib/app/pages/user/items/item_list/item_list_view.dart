import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../common/widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part '_item_list_view_provider.dart';

@RoutePage()
class ItemListView extends ConsumerWidget {
  const ItemListView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(itemListViewProvider);

    if (context.mounted) {
      controller.initRefreshListener();
    }

    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: scaffoldKey,
        title: Text(context.t.common.itemsList),
        actions: [
          // Navigation Menus
          if (ref.canAny([
            PMKeys.menus,
            PMKeys.categories,
            PMKeys.modifierGroups,
            PMKeys.itemModifiers,
          ]))
            PopupMenuButton<PageRouteInfo<dynamic>>(
              itemBuilder: (context) {
                return [
                  if (ref.can(PMKeys.menus)) ...[
                    (context.t.common.menus, const MenuListRoute()),
                  ],
                  if (ref.can(PMKeys.categories)) ...[
                    (context.t.common.category(n: 1), const CategoryListRoute()),
                  ],
                  if (ref.can(PMKeys.modifierGroups)) ...[
                    (context.t.common.modifierGroups, const ModifierGroupListRoute()),
                  ],
                  if (ref.can(PMKeys.itemModifiers)) ...[
                    (context.t.common.itemModifiers, const ItemModifierListRoute()),
                  ],
                ].map((menu) {
                  return PopupMenuItem<PageRouteInfo<dynamic>>(
                    value: menu.$2,
                    child: Text(menu.$1),
                  );
                }).toList();
              },
              onSelected: context.router.push,
            ),
        ],
      ),
      body: PermissionGate(
        moduleKey: PMKeys.products,
        fallback: PermissionGate.imageFallback(),
        child: Column(
          children: [
            // Search Field
            CustomSearchField(
              controller: controller.searchController,
              decoration: CustomSearchFieldDecoration(
                hintText: context.t.common.searchItemsName,
              ),
              appliedFilterCount: controller.filterCount,
              onTapFilter: () async {
                final _result = await showItemFilterBottomModalSheet(
                  context: context,
                  selectedFilters: {...controller.filters},
                );
                if (_result == null) {
                  return;
                }

                return controller.handleFilter(_result);
              },
              onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                controller.pagingController.refresh,
              ),
            ).fMarginLTRB(16, 16, 16, 0),

            // Items List
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: () => Future.sync(controller.pagingController.refresh),
                child: PagedListView<int, PItem>(
                  padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: controller.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<PItem>(
                    itemBuilder: (c, item, i) {
                      final _itemType = ItemTypeEnum.fromString(item.priceType);
                      final _itemCardData = ItemCardData(
                        itemName: item.productName ?? "N/A",
                        imageUrl: item.images?.firstOrNull?.remote,
                        salesPrice: (_itemType.isVariation ? item.minVariationPrice : item.salesPrice) ?? 0,
                      );

                      return HorizontalItemCard.itemList(
                        data: _itemCardData,
                        action: PopupMenuButton<String>(
                          itemBuilder: (context) {
                            return [
                              (context.t.common.view, 'view'),
                              if (ref.can(PMKeys.products, action: PermissionAction.update)) ...[
                                (context.t.common.edit, 'edit'),
                              ],
                              if (ref.can(PMKeys.products, action: PermissionAction.delete)) ...[
                                (context.t.common.delete, 'delete'),
                              ],
                            ].map((menu) {
                              return PopupMenuItem<String>(
                                value: menu.$2,
                                child: Text(menu.$1),
                              );
                            }).toList();
                          },
                          onSelected: (v) async {
                            return switch (v) {
                              'view' => _handleDetailsRoute(context, item.id!),
                              'edit' => _handleEditRoute(context, ref, item.id!),
                              'delete' => _handleDelete(
                                context,
                                () => ref.read(itemsRepoProvider).deleteItem(item.id!),
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
                            context.t.pages.items.itemList.extra.emptyItem,
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
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: PermissionGate(
        moduleKey: PMKeys.products,
        action: PermissionAction.create,
        child: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            onPressed: () async {
              return await context.router.push<void>(
                ManageItemRoute(),
              );
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            label: Text('+ ${context.t.common.addItems}'),
          ),
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleDetailsRoute(BuildContext context, int id) async {
    return await context.router.push<void>(
      ItemDetailsRoute(itemId: id),
    );
  }

  Future<void> _handleEditRoute(BuildContext context, WidgetRef ref, int id) async {
    return _fetchItemPerformAction(context, ref, id, (context, itemDetails) async {
      return await context.router.push<void>(
        ManageItemRoute(editModel: itemDetails),
      );
    });
  }

  Future<void> _fetchItemPerformAction(
    BuildContext context,
    WidgetRef ref,
    int id,
    Future<void> Function(BuildContext context, PItem itemDetails) action,
  ) async {
    try {
      final _details = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(itemDetailsProvider(id).future),
        ),
      );

      if (context.mounted && _details.data != null) {
        return await action(context, _details.data!);
      }
    } catch (error) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(error.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.prompt.items.delete.title,
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
