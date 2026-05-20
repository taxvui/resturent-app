import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';

@RoutePage()
class ItemModifierListView extends ConsumerStatefulWidget {
  const ItemModifierListView({super.key});

  @override
  ConsumerState<ItemModifierListView> createState() => _ItemModifierListViewState();
}

class _ItemModifierListViewState extends ConsumerState<ItemModifierListView>
    with PaginatedControllerMixin<ItemModifier> {
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
        // title: const Text('Item Modifiers'),
        title: Text(context.t.pages.itemModifier.itemModifierList.title),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: searchController,
            decoration: CustomSearchFieldDecoration(
              // hintText: 'Search here...',
              hintText: context.t.common.searchHere,
              actions: [
                if (ref.can(PMKeys.itemModifiers, action: PermissionAction.create)) ...[
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.custom(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      return await context.router.push<void>(
                        ManageItemModifierRoute(),
                      );
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

          // Item Modifier List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, ItemModifier>.separated(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<ItemModifier>(
                  itemBuilder: (c, modifier, i) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: Divider.createBorderSide(context),
                        ),
                      ),
                      child: ListTile(
                        title: Text(modifier.product?.productName ?? "N/A"),
                        subtitle: Text(
                          modifier.modifierGroup?.name ?? "N/A",
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        trailing: PopupMenuButton<String>(
                          child: const Icon(Icons.more_vert),
                          itemBuilder: (context) {
                            return [
                              ("view", "View"),
                              if (ref.can(PMKeys.itemModifiers, action: PermissionAction.update)) ...[
                                ("edit", context.t.common.edit),
                              ],
                              if (ref.can(PMKeys.itemModifiers, action: PermissionAction.delete)) ...[
                                ("delete", context.t.common.delete),
                              ],
                            ].map((menu) {
                              return PopupMenuItem<String>(
                                value: menu.$1,
                                child: Text(menu.$2),
                              );
                            }).toList();
                          },
                          onSelected: (v) async {
                            return switch (v) {
                              'view' => _handleViewDetails(context, modifier),
                              'edit' => _handleEdit(context, modifier),
                              'delete' => _handleDelete(
                                context,
                                () => ref.read(itemsRepoProvider).deleteItemModifier(modifier.id!),
                              ),
                              _ => null,
                            };
                          },
                        ),
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          // "No item modifier found!\n Please try adding a item modifier.",
                          context.t.exceptions.noItemModifierFound,
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

  Future<void> _handleEdit(BuildContext context, ItemModifier data) async {
    return await context.router.push<void>(
      ManageItemModifierRoute(editModel: data),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Do you want to delete this item modifier?',
        title: context.t.prompt.deleteItemModifier,
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

  Future<void> _handleViewDetails(BuildContext context, ItemModifier data) async {
    return await showDialog(
      context: context,
      builder: (modalContext) {
        final _theme = Theme.of(context);

        final _valueStyle = _theme.textTheme.bodyLarge?.copyWith(
          color: _theme.paragraphColor,
        );
        final _labelStyle = _valueStyle?.copyWith(
          fontSize: 14,
          color: _theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(24),
          clipBehavior: Clip.antiAlias,
          alignment: AlignmentDirectional.centerStart,
          backgroundColor: _theme.colorScheme.surface,
          child: BottomModalSheetWrapper(
            // title: const TextSpan(text: 'View Details'),
            title: TextSpan(text: context.t.common.viewDetails),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item
                  // Text('Items', style: _labelStyle),
                  Text(context.t.common.items, style: _labelStyle),
                  const SizedBox.square(dimension: 2),
                  Text(data.product?.productName ?? "N/A", style: _valueStyle),
                  const SizedBox.square(dimension: 14),

                  // Modifier Group
                  // Text('Modifier Group', style: _labelStyle),
                  Text(context.t.common.modifierGroups, style: _labelStyle),
                  const SizedBox.square(dimension: 2),
                  Text(data.modifierGroup?.name ?? "N/A", style: _valueStyle),
                  const SizedBox.square(dimension: 14),

                  // Allow multiple section
                  // Text('Allow multiple section', style: _labelStyle),
                  Text(context.t.common.allowMultiSelection, style: _labelStyle),
                  const SizedBox.square(dimension: 2),
                  Text(
                    // data.isMultiple ? 'Yes' : 'No',
                    data.isMultiple ? context.t.action.yes : context.t.action.no,
                    style: _valueStyle?.copyWith(
                      color: DAppColors.kSuccess,
                    ),
                  ),
                  const SizedBox.square(dimension: 14),

                  // Required
                  // Text('Required', style: _labelStyle),
                  Text(context.t.common.required, style: _labelStyle),
                  const SizedBox.square(dimension: 2),
                  Text(
                    // data.isRequired ? 'Required' : 'Optional',
                    data.isRequired ? context.t.common.required : context.t.common.optional,
                    style: _valueStyle?.copyWith(
                      color: _theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Future<PaginatedListModel<ItemModifier>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(itemsRepoProvider)
          .getItemModifers(
            page: page,
            search: searchController.text,
          ),
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.modifier) {
        pagingController.refresh();
      }
    });
    super.initRefreshListener();
  }
}
