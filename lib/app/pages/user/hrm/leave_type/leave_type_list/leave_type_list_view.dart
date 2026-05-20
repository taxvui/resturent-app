import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../../i18n/strings.g.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class LeaveTypeListView extends ConsumerStatefulWidget {
  const LeaveTypeListView({super.key});

  @override
  ConsumerState<LeaveTypeListView> createState() => _LeaveTypeListViewState();
}

class _LeaveTypeListViewState extends ConsumerState<LeaveTypeListView> with PaginatedControllerMixin<LeaveTypeModel> {
  final searchController = TextEditingController();

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
        title: Text(context.t.hrm.leaveType),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.leaveType,
        fallback: PermissionGate.imageFallback(),
        child: RefreshIndicator.adaptive(
          onRefresh: () => Future.sync(pagingController.refresh),
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                child: CustomSearchField(
                  controller: searchController,
                  decoration: CustomSearchFieldDecoration(
                    hintText: context.t.common.search,
                  ),
                  onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                    pagingController.refresh,
                  ),
                ),
              ),

              // List of Leave Types
              Expanded(
                child: PagedListView<int, LeaveTypeModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LeaveTypeModel>(
                    itemBuilder: (c, item, i) {
                      return ItemAttributeListTile(
                        name: TextSpan(
                          text: item.name,
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: TextSpan(
                          text: item.description ?? context.t.common.notAvailable,
                        ),
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.leaveType,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManageLeaveTypeRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.leaveType,
                          action: PermissionAction.delete,
                          input: () => handleDelete(context, item.id!),
                        ),
                      );
                    },
                    noItemsFoundIndicatorBuilder: (context) {
                      return EmptyWidget(
                        replaceDefault: false,
                        emptyBuilder: (context) {
                          return RetryButtons.scrollView(
                            context.t.hrm.emptyStates.noLeaveTypes,
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
      ),
      floatingActionButton: SizedBox(
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: () async {
            return context.router.push<void>(ManageLeaveTypeRoute());
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addLeaveType),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.leaveType, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deleteLeaveType,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => ref.read(leaveTypeRepoProvider).deleteLeaveType(id),
        );

        if (context.mounted) {
          showCustomSnackBar(
            context,
            content: Text(_result),
          );
        }
      } catch (e) {
        if (context.mounted) {
          showCustomSnackBar(
            context,
            content: Text(e.toString()),
            customSnackBarType: CustomOverlayType.error,
          );
        }
      }
    }
  }

  Future<void> handleViewDetails(BuildContext context, LeaveTypeModel item) async {
    return await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (modalContext) {
        final _theme = Theme.of(context);
        final _style = _theme.textTheme.bodyLarge;

        return BottomModalSheetWrapper(
          title: TextSpan(text: t.common.viewDetails),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                  (label: context.t.hrm.leaveType, value: item.name ?? context.t.common.notAvailable),
                  (
                    label: context.t.common.status,
                    value: item.status ? context.t.hrm.dropdowns.active : context.t.hrm.dropdowns.inactive,
                  ),
                ].map(
                  (entry) {
                    return KeyValueRow(
                      title: entry.label,
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
                const SizedBox.square(dimension: 8),

                // Description
                Text(
                  context.t.form.description.label,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox.square(dimension: 2),
                Text(
                  item.description ?? context.t.hrm.fallbacks.noDescriptionAvailable,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    color: _theme.paragraphColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Future<LeaveTypeListModel> fetchData(int page) async {
    return ref
        .read(leaveTypeRepoProvider)
        .getLeaveTypeList(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<LeaveTypeModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<LeaveTypeModel>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
