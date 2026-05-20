import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class MenuListView extends ConsumerStatefulWidget {
  const MenuListView({super.key});

  @override
  ConsumerState<MenuListView> createState() => _MenuListViewState();
}

class _MenuListViewState extends ConsumerState<MenuListView> with PaginatedControllerMixin<ItemMenu> {
  late final searchController = TextEditingController();

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _apiEventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Menu List'),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchHere,
              actions: [
                if (ref.can(PMKeys.menus, action: PermissionAction.create)) ...[
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.custom(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      return await context.router.push<void>(ManageMenuRoute());
                    },
                    style: CustomSearchFieldActionButton.themeColored(context),
                  ),
                ],
              ],
            ),
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Menu List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, ItemMenu>.separated(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<ItemMenu>(
                  itemBuilder: (c, menu, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(text: menu.name),
                      onDelete: ref.canT(
                        PMKeys.menus,
                        action: PermissionAction.delete,
                        input: () async => await _handleDelete(
                          context,
                          () => ref.read(itemsRepoProvider).deleteMenu(menu.id!),
                        ),
                      ),
                      onEdit: ref.canT(
                        PMKeys.menus,
                        action: PermissionAction.update,
                        input: () async => await _handleEdit(context, menu),
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          "No menu found!\n Please try adding a menu.",
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
    ).unfocusPrimary();
  }

  Future<void> _handleEdit(BuildContext context, ItemMenu data) async {
    return await context.router.push<void>(
      ManageMenuRoute(editModel: data),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: 'Do you want to delete this menu?',
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

  @override
  Future<PaginatedListModel<ItemMenu>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(itemsRepoProvider)
          .getItemMenus(
            page: page,
            search: searchController.text,
          ),
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.menu) {
        pagingController.refresh();
      }
    });
    super.initRefreshListener();
  }
}
