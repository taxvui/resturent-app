import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../components/components.dart';

@RoutePage()
class AreaListView extends ConsumerStatefulWidget {
  const AreaListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AreaListViewState();
}

class _AreaListViewState extends ConsumerState<AreaListView> with PaginatedControllerMixin<AreaModel> {
  late final searchController = TextEditingController();

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Area List'),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: Column(
          children: [
            // Search Field
            CustomSearchField(
              controller: searchController,
              decoration: CustomSearchFieldDecoration(
                hintText: 'Search here...',
                actions: [
                  if (ref.can(PMKeys.areas, action: PermissionAction.create)) ...[
                    const SizedBox.square(dimension: 8),
                    CustomSearchFieldActionButton.custom(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        return showManageAreaModal(context);
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

            // Area List
            Expanded(
              child: PagedListView<int, AreaModel>(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<AreaModel>(
                  itemBuilder: (c, area, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(
                        text: area.name ?? "N/A",
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: TextSpan(
                        text: 'Tables: ${area.totalTable ?? 0}',
                      ),
                      onEdit: ref.canT(
                        PMKeys.areas,
                        action: PermissionAction.update,
                        input: () async {
                          return showManageAreaModal(
                            context,
                            editModel: area,
                          );
                        },
                      ),
                      onDelete: ref.canT(
                        PMKeys.areas,
                        action: PermissionAction.delete,
                        input: () async {
                          return _handleDelete(context, area);
                        },
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          'No areas found!\n Please try adding a area.',
                          onRetry: pagingController.refresh,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleDelete(BuildContext context, AreaModel area) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: 'Do you want to delete this area?',
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(tableRepoProvider).deleteArea(area.id!),
          ),
        );

        if (context.mounted) {
          showCustomSnackBar(
            context,
            content: Text(_result),
          );
          return;
        }
      } catch (e) {
        if (context.mounted) {
          showCustomSnackBar(
            context,
            content: Text(e.toString()),
            customSnackBarType: CustomOverlayType.error,
          );
          return;
        }
      }
    }
  }

  @override
  Future<PaginatedListModel<AreaModel>> fetchData(int page) {
    return Future.microtask(
      () => ref
          .read(tableRepoProvider)
          .getAreas(
            page: page,
            search: searchController.text,
          ),
    );
  }

  EventSub<AreaAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<AreaAE>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
