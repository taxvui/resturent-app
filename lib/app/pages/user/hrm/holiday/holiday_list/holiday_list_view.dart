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
class HolidayListView extends ConsumerStatefulWidget {
  const HolidayListView({super.key});

  @override
  ConsumerState<HolidayListView> createState() => _HolidayListViewState();
}

class _HolidayListViewState extends ConsumerState<HolidayListView> with PaginatedControllerMixin<HolidayModel> {
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
        title: Text(context.t.hrm.pageTitles.holiday),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.holiday,
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

              // List of Holidays
              Expanded(
                child: PagedListView<int, HolidayModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<HolidayModel>(
                    itemBuilder: (c, item, i) {
                      return _HolidayListItem(
                        data: item,
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.holiday,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManageHolidayRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.holiday,
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
                            context.t.hrm.emptyStates.noHolidays,
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
            return context.router.push<void>(ManageHolidayRoute());
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addHoliday),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.holiday, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deleteHoliday,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => ref.read(holidayRepoProvider).deleteHoliday(id),
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

  Future<void> handleViewDetails(BuildContext context, HolidayModel item) async {
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
                  (label: context.t.hrm.form.labels.holidayName, value: item.name ?? 'N/A'),
                  (label: context.t.hrm.form.labels.startDate, value: item.startDate?.getFormatedString() ?? 'N/A'),
                  (label: context.t.hrm.form.labels.endDate, value: item.endDate?.getFormatedString() ?? 'N/A'),
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
  Future<HolidayListModel> fetchData(int page) async {
    return ref
        .read(holidayRepoProvider)
        .getHolidayList(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<HolidayModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<HolidayModel>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}

class _HolidayListItem extends StatelessWidget {
  const _HolidayListItem({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final HolidayModel data;
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
            // Holiday Name + Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.name ?? 'N/A',
                    style: _theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
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
              ],
            ),
            const SizedBox.square(dimension: 12),

            // Start Date / End Date
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...[
                        (
                          label: context.t.hrm.form.labels.startDate,
                          value: data.startDate?.getFormatedString() ?? 'N/A',
                        ),
                        (label: context.t.hrm.form.labels.endDate, value: data.endDate?.getFormatedString() ?? 'N/A'),
                      ].map((entry) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Date
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

                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
