import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../components/components.dart';
import '../../../../widgets/widgets.dart';
import '../../../../data/repository/repository.dart';

@RoutePage()
class TableListView extends ConsumerStatefulWidget {
  const TableListView({super.key});

  @override
  ConsumerState<TableListView> createState() => _TableListViewState();
}

class _TableListViewState extends ConsumerState<TableListView> with PaginatedControllerMixin<PTable> {
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
        title: Text(context.t.common.tableList),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: PagedListView<int, PTable>(
          padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<PTable>(
            itemBuilder: (c, table, i) {
              return ItemAttributeListTile(
                name: TextSpan(
                  text: table.name ?? "N/A",
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: table.status.statusColor?.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          table.status.label(context),
                          style: _theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: table.status.statusColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: TextSpan(
                  text: '${context.t.common.capacity}: ${table.capacity ?? 0}',
                ),
                onEdit: ref.canT(
                  PMKeys.tables,
                  action: PermissionAction.update,
                  input: () async {
                    return await showManageTableModal(
                      context,
                      editModel: table,
                    );
                  },
                ),
                onDelete: ref.canT(
                  PMKeys.tables,
                  action: PermissionAction.delete,
                  input: () async {
                    return await _handleDelete(
                      context,
                      () => ref.read(tableRepoProvider).deleteTable(table.id!),
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
                    context.t.exceptions.noTableFoundPleaseTryAgain,
                    onRetry: pagingController.refresh,
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: () async {
            return showManageTableModal(context);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.common.addTable),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.tables, action: PermissionAction.create),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.exceptions.doYouWantToDeleteThisTable,
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
  Future<PaginatedListModel<PTable>> fetchData(int page) {
    return ref.read(tableRepoProvider).getTables(page: page);
  }

  EventSub<TableAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<TableAE>().listen((event) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
