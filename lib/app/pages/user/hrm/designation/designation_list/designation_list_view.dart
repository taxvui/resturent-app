import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../../i18n/strings.g.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class DesignationListView extends ConsumerStatefulWidget {
  const DesignationListView({super.key});

  @override
  ConsumerState<DesignationListView> createState() => _DesignationListViewState();
}

class _DesignationListViewState extends ConsumerState<DesignationListView>
    with PaginatedControllerMixin<DesignationModel> {
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
        title: Text(context.t.hrm.pageTitles.designation),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.designation,
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

              // List of Designations
              Expanded(
                child: PagedListView<int, DesignationModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<DesignationModel>(
                    itemBuilder: (c, item, i) {
                      return ItemAttributeListTile(
                        name: TextSpan(
                          text: item.name ?? "N/A",
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: TextSpan(text: item.description ?? "N/A"),
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.designation,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManageDesignationRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.designation,
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
                            context.t.hrm.emptyStates.noDesignations,
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
            return context.router.push<void>(
              ManageDesignationRoute(),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addDesignation),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.designation, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deleteDesignation,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(designationRepoProvider).deleteDesignation(id),
          ),
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

  Future<void> handleViewDetails(BuildContext context, DesignationModel data) async {
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
                  (label: context.t.hrm.designation, value: data.name ?? "N/A"),
                  (
                    label: context.t.common.status,
                    value: data.status ? context.t.hrm.dropdowns.active : context.t.hrm.dropdowns.inactive,
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
                  context.t.hrm.form.labels.description,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox.square(dimension: 2),
                Text(
                  data.description ?? "N/A",
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
  Future<DesignationListModel> fetchData(int page) async {
    return ref
        .read(designationRepoProvider)
        .getDesignationList(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<DesignationModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<DesignationModel>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
