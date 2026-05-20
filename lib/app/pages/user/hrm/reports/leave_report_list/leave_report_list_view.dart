import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../../i18n/strings.g.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../common/widgets/widgets.dart';

@RoutePage()
class LeaveReportListView extends ConsumerStatefulWidget {
  const LeaveReportListView({super.key});

  @override
  ConsumerState<LeaveReportListView> createState() => _LeaveReportListViewState();
}

class _LeaveReportListViewState extends ConsumerState<LeaveReportListView> with PaginatedControllerMixin<LeaveModel> {
  final searchController = TextEditingController();
  final selectedFilterNotifier = ValueNotifier<Map<String, dynamic>>({
    'employee_id': null,
    'month': null,
  });

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
    final employeeDropdownAsync = ref.watch(employeeDropdownProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.hrm.leave),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.leaveReport,
        fallback: PermissionGate.imageFallback(),
        child: RefreshIndicator.adaptive(
          onRefresh: () => Future.sync(pagingController.refresh),
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                child: ValueListenableBuilder(
                  valueListenable: selectedFilterNotifier,
                  builder: (_, selectedFilters, _) {
                    return CustomSearchField(
                      appliedFilterCount: selectedFilters.entries.where((element) => element.value != null).length,
                      controller: searchController,
                      decoration: CustomSearchFieldDecoration(
                        hintText: context.t.common.search,
                        actions: [
                          const SizedBox.square(dimension: 8),
                          CustomSearchFieldActionButton.pdf(
                            onPressed: () async {
                              return await showAsyncLoadingOverlay<void>(
                                context,
                                asyncFunction: () {
                                  return SharedWidgets.openFile(context, () {
                                    return ref.read(
                                      leaveReportPDFProvider((
                                        employeeId: selectedFilterNotifier.value['employee_id'],
                                        month: selectedFilterNotifier.value['month'],
                                      )).future,
                                    );
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox.square(dimension: 4),
                          CustomSearchFieldActionButton.print(
                            onPressed: () async {
                              return await showAsyncLoadingOverlay<void>(
                                context,
                                asyncFunction: () {
                                  return SharedWidgets.printPDF(
                                    context,
                                    () => ref.read(
                                      leaveReportPDFProvider((
                                        employeeId: selectedFilterNotifier.value['employee_id'],
                                        month: selectedFilterNotifier.value['month'],
                                      )).future,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      onTapFilter: () async {
                        return showFilterModalSheet<String, dynamic>(
                          context: context,
                          selectedFilters: {...selectedFilters},
                          filters: [
                            // Employee Filter
                            FilterModalData.custom(
                              key: 'employee_id',
                              value: selectedFilters['employee_id'],
                              builder: (_, {initialValue, required onChanged}) {
                                return AsyncCustomDropdown<int?, EmployeeListModel>(
                                  asyncData: employeeDropdownAsync,
                                  decoration: InputDecoration(
                                    labelText: context.t.hrm.form.labels.employee,
                                    hintText: context.t.hrm.form.hints.selectEmployee,
                                  ),
                                  value: initialValue,
                                  items: employeeDropdownAsync.when(
                                    data: (data) {
                                      return [
                                        CustomDropdownMenuItem<int>(
                                          value: null,
                                          label: TextSpan(text: context.t.hrm.form.hints.allEmployee),
                                        ),
                                        ...?data.data?.data?.map(
                                          (employee) {
                                            return CustomDropdownMenuItem(
                                              value: employee.id,
                                              label: TextSpan(text: employee.name ?? "N/A"),
                                            );
                                          },
                                        ),
                                      ];
                                    },
                                    error: (_, _) => [],
                                    loading: () => [],
                                  ),
                                  onChanged: onChanged,
                                );
                              },
                            ),

                            // Month Filter
                            FilterModalData.custom(
                              key: 'month',
                              value: selectedFilters['month'],
                              builder: (_, {initialValue, required onChanged}) {
                                return MonthFilterDropdown(
                                  decoration: InputDecoration(
                                    labelText: context.t.hrm.form.labels.month,
                                    hintText: context.t.hrm.form.hints.selectMonth,
                                  ),
                                  value: initialValue,
                                  onChanged: onChanged,
                                );
                              },
                            ),
                          ],
                          onSave: selectedFilterNotifier.set,
                        );
                      },
                      onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                        pagingController.refresh,
                      ),
                    );
                  },
                ),
              ),

              // List of Leaves
              Expanded(
                child: PagedListView<int, LeaveModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LeaveModel>(
                    itemBuilder: (context, item, index) {
                      return _LeaveListItem(
                        data: item,
                        onTap: () => handleViewDetails(context, item),
                      );
                    },
                    noItemsFoundIndicatorBuilder: (context) {
                      return EmptyWidget(
                        replaceDefault: false,
                        emptyBuilder: (context) {
                          return RetryButtons.scrollView(
                            context.t.hrm.emptyStates.noLeaves,
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
    ).unfocusPrimary();
  }

  Future<void> handleViewDetails(BuildContext context, LeaveModel item) async {
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
                  (label: context.t.hrm.form.labels.employee, value: item.employee?.name ?? 'N/A'),
                  (label: context.t.hrm.form.labels.department, value: item.department?.name ?? 'N/A'),
                  (label: context.t.hrm.form.labels.leaveType, value: item.leaveType?.name ?? 'N/A'),
                  (label: context.t.hrm.form.labels.month, value: item.month ?? 'N/A'),
                  (label: context.t.hrm.form.labels.startDate, value: item.startDate?.getFormatedString() ?? 'N/A'),
                  (label: context.t.hrm.form.labels.endDate, value: item.endDate?.getFormatedString() ?? 'N/A'),
                  (
                    label: context.t.hrm.form.labels.leaveDuration,
                    value: '${item.leaveDuration ?? 0} ${context.t.hrm.units.days}',
                  ),
                  (label: context.t.hrm.form.labels.status, value: item.status ?? 'N/A'),
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
  Future<LeaveListModel> fetchData(int page) async {
    return ref
        .read(leaveRepoProvider)
        .getLeaveReportList(
          page: page,
          search: searchController.text,
          employeeId: selectedFilterNotifier.value['employee_id'],
          month: selectedFilterNotifier.value['month']?.toLowerCase(),
        );
  }

  EventSub<LeaveModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<LeaveModel>().listen((_) {
      pagingController.refresh();
    });
    selectedFilterNotifier.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}

class _LeaveListItem extends StatelessWidget {
  const _LeaveListItem({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    this.onTap,
  });
  final LeaveModel data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: Divider.createBorderSide(context)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name + Leave Type + Actions
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Name
                      Text(
                        data.employee?.name ?? 'N/A',
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox.square(dimension: 4),
                      // Leave Type
                      Text(
                        data.leaveType?.name ?? 'N/A',
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: _theme.paragraphColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 16),

            // Month + Start Date + End Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...[
                  (label: context.t.hrm.form.labels.month, value: data.month ?? 'N/A'),
                  (label: context.t.hrm.form.labels.startDate, value: data.startDate?.getFormatedString() ?? "N/A"),
                  (label: context.t.hrm.form.labels.endDate, value: data.endDate?.getFormatedString() ?? "N/A"),
                ].map((entry) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Value
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
          ],
        ),
      ),
    );
  }
}
