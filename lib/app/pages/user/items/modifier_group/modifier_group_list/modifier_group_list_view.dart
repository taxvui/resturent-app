import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';

@RoutePage()
class ModifierGroupListView extends ConsumerStatefulWidget {
  const ModifierGroupListView({super.key});

  @override
  ConsumerState<ModifierGroupListView> createState() => _ModifierGroupListViewState();
}

class _ModifierGroupListViewState extends ConsumerState<ModifierGroupListView>
    with PaginatedControllerMixin<ItemModifierGroup> {
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
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.common.modifierGroups),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchHere,
              actions: [
                if (ref.can(PMKeys.modifierGroups, action: PermissionAction.create)) ...[
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.custom(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      return await context.router.push<void>(
                        ManageModifierGroupRoute(),
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

          // ModifierGroup List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, ItemModifierGroup>.separated(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<ItemModifierGroup>(
                  itemBuilder: (c, modifierGroup, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(text: modifierGroup.name),
                      subtitle: TextSpan(
                        text: '${context.t.common.modifier}: ${modifierGroup.totalModifier?.commaSeparated() ?? "N/A"}',
                        style: TextStyle(color: _theme.colorScheme.primary),
                      ),
                      onDelete: ref.canT(
                        PMKeys.modifierGroups,
                        action: PermissionAction.delete,
                        input: () async {
                          return _handleDelete(
                            context,
                            () => ref.read(itemsRepoProvider).deleteModifierGroup(modifierGroup.id!),
                          );
                        },
                      ),
                      onEdit: ref.canT(
                        PMKeys.modifierGroups,
                        action: PermissionAction.update,
                        input: () async {
                          return _handleEdit(context, modifierGroup);
                        },
                      ),
                      onTap: () async {
                        return _handleViewDetails(context, modifierGroup);
                      },
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noModifierGroupFound,
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

  Future<void> _handleEdit(BuildContext context, ItemModifierGroup data) async {
    return await context.router.push<void>(
      ManageModifierGroupRoute(editModel: data),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.prompt.deleteModifierGroup,
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
  Future<PaginatedListModel<ItemModifierGroup>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(itemsRepoProvider)
          .getItemModifierGroups(
            page: page,
            search: searchController.text,
          ),
    );
  }

  EventSub<ItemsApiEvent>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ItemsApiEvent>().listen((event) {
      if (event == ItemsApiEvent.modifierGroup) {
        pagingController.refresh();
      }
    });
    super.initRefreshListener();
  }

  Future<void> _handleViewDetails(
    BuildContext context,
    ItemModifierGroup data,
  ) async {
    return await showDialog(
      context: context,
      builder: (modalContext) {
        final _theme = Theme.of(context);

        final _labelStyle = _theme.textTheme.bodyMedium?.copyWith(
          color: _theme.paragraphColor,
        );
        final _valueStyle = _labelStyle?.copyWith(
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
            title: TextSpan(text: data.name ?? "N/A"),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.options?.isEmpty == true)
                    // const Text("No options found!").fMarginOnly(bottom: 12)
                    Text(context.t.exceptions.noOptionsFound).fMarginOnly(bottom: 12)
                  else
                    ...?data.options?.map((option) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.name ?? "N/A",
                              style: _labelStyle,
                            ),
                          ),
                          Text(
                            option.price?.quickCurrency() ?? "N/A",
                            style: _valueStyle,
                          ),
                        ],
                      ).fMarginOnly(bottom: 8);
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
