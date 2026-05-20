import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../../core/core.dart';
import '../../../../../../i18n/strings.g.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class ShiftListView extends ConsumerStatefulWidget {
  const ShiftListView({super.key});

  @override
  ConsumerState<ShiftListView> createState() => _ShiftListViewState();
}

class _ShiftListViewState extends ConsumerState<ShiftListView> with PaginatedControllerMixin<ShiftModel> {
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
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.hrm.form.labels.shift),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.shift,
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

              // List of Shifts
              Expanded(
                child: PagedListView<int, ShiftModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<ShiftModel>(
                    itemBuilder: (c, item, i) {
                      return _ShiftListItem(
                        shift: item,
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.shift,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManageShiftRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.shift,
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
                            context.t.hrm.emptyStates.noShifts,
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
            return context.router.push<void>(ManageShiftRoute());
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addShift),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.shift, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deleteShift,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(shiftRepoProvider).deleteShift(id),
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

  Future<void> handleViewDetails(BuildContext context, ShiftModel data) async {
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
                  (label: context.t.hrm.form.labels.shift, value: data.name ?? context.t.common.notAvailable),
                  (
                    label: context.t.hrm.form.labels.startTime,
                    value: data.startTime?.timeFormat12Hour ?? context.t.common.notAvailable,
                  ),
                  (
                    label: context.t.hrm.form.labels.endTime,
                    value: data.endTime?.timeFormat12Hour ?? context.t.common.notAvailable,
                  ),
                  if (data.hasBreak) ...[
                    (
                      label: context.t.hrm.form.labels.breakTime,
                      value:
                          "${data.startBreakTime?.timeFormat12Hour ?? ''} - ${data.endBreakTime?.timeFormat12Hour ?? ''}",
                    ),
                    (
                      label: context.t.hrm.form.labels.breakDuration,
                      value: data.breakTime ?? context.t.common.notAvailable,
                    ),
                  ],
                  (
                    label: context.t.common.status,
                    value: data.status ? context.t.hrm.dropdowns.active : context.t.hrm.dropdowns.inactive,
                  ),
                ].map(
                  (entry) {
                    return KeyValueRow(
                      title: entry.label,
                      titleFlex: 5,
                      titleStyle: _style?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                      description: entry.value,
                      descriptionFlex: 8,
                      descriptionStyle: _style?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Future<ShiftListModel> fetchData(int page) async {
    return ref
        .read(shiftRepoProvider)
        .getShiftList(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<ShiftModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<ShiftModel>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

class _ShiftListItem extends StatelessWidget {
  const _ShiftListItem({
    // ignore: unused_element_parameter
    super.key,
    required this.shift,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final ShiftModel shift;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: Divider.createBorderSide(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shift Name
            Text(
              shift.name ?? context.t.common.notAvailable,
              style: _theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox.square(dimension: 8),

            // Break Time (if applicable)
            if (shift.hasBreak) ...[
              Text.rich(
                TextSpan(
                  text: '${context.t.hrm.form.labels.breakTime}: ',
                  children: [
                    TextSpan(
                      text:
                          '${shift.startBreakTime?.timeFormat12Hour ?? context.t.common.notAvailable} - ${shift.endBreakTime?.timeFormat12Hour ?? context.t.common.notAvailable}',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: _theme.paragraphColor,
                ),
              ),
              const SizedBox.square(dimension: 12),
            ],

            // Start Time, End Time & Action
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...[
                        (
                          label: context.t.hrm.form.labels.startTime,
                          value: shift.startTime?.timeFormat12Hour ?? context.t.common.notAvailable,
                        ),
                        (
                          label: context.t.hrm.form.labels.endTime,
                          value: shift.endTime?.timeFormat12Hour ?? context.t.common.notAvailable,
                        ),
                      ].map((entry) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Time
                            Text(
                              entry.value,
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Label
                            Text(
                              entry.label,
                              style: _theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: _theme.paragraphColor,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // Actions
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(HugeIconsStroke.pencilEdit02),
                        color: DAppColors.kSuccess,
                      ),
                      IconButton(
                        onPressed: onDelete,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(HugeIconsStroke.delete03),
                        color: DAppColors.kError,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
