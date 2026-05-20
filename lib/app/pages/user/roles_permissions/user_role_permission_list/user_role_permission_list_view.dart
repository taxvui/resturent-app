import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../widgets/widgets.dart';

@RoutePage()
class UserRolePermissionListView extends ConsumerStatefulWidget {
  const UserRolePermissionListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserRolePermissionListViewState();
}

class _UserRolePermissionListViewState extends ConsumerState<UserRolePermissionListView>
    with PaginatedControllerMixin<PermittedStaff> {
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
        title: Text(context.t.common.roleNPermission),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchHere,
            ),
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // User Permission List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, PermittedStaff>(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<PermittedStaff>(
                  itemBuilder: (c, ps, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(
                        text: ps.name ?? "N/A",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: TextSpan(text: '${ps.availableFeaturesCount} Features'),
                      onEdit: () async {
                        return context.router.push<void>(
                          ManageUserRolePermissionRoute(editModel: ps),
                        );
                      },
                      onDelete: () => _handleDelete(
                        context,
                        () => ref.read(staffDesignationRepoProvider).deletePermittedStaff(ps.id!),
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noPermittedUserFound,
                          onRetry: pagingController.refresh,
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
      floatingActionButton: SizedBox(
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: () async {
            return context.router.push<void>(ManageUserRolePermissionRoute());
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text('+ ${context.t.action.addRole}'),
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: 'Do you want to delete this user permission?',
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
  Future<PaginatedListModel<PermittedStaff>> fetchData(int page) {
    return ref
        .read(staffDesignationRepoProvider)
        .getPermittedStaff(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<StaffPermissionAE>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<StaffPermissionAE>().listen((event) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

extension _PermittedStaffExt on PermittedStaff {
  int get availableFeaturesCount {
    if (permissions == null) return 0;

    return permissions!.toJson().entries.fold(0, (sum, entry) {
      final perm = entry.value != null ? Permission.fromJson(entry.value as Map<String, dynamic>) : null;

      if (perm != null && [perm.view, perm.create, perm.update, perm.delete].any((v) => v == true)) {
        return sum + 1;
      }

      return sum;
    });
  }
}
