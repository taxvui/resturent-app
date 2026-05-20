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
class PayrollListView extends ConsumerStatefulWidget {
  const PayrollListView({super.key});

  @override
  ConsumerState<PayrollListView> createState() => _PayrollListViewState();
}

class _PayrollListViewState extends ConsumerState<PayrollListView> with PaginatedControllerMixin<PayrollModel> {
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
        title: Text(context.t.hrm.payroll),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.payroll,
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

              // Payroll List
              Expanded(
                child: PagedListView<int, PayrollModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<PayrollModel>(
                    itemBuilder: (context, item, index) {
                      return _PayrollListItem(
                        data: item,
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.payroll,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManagePayrollRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.payroll,
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
                            context.t.hrm.emptyStates.noPayrollRecords,
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
            return context.router.push<void>(ManagePayrollRoute());
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addPayroll),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.payroll, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deletePayroll,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => ref.read(payrollRepoProvider).deletePayroll(id),
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

  Future<void> handleViewDetails(BuildContext context, PayrollModel item) async {
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
                  (
                    label: context.t.hrm.form.labels.employee,
                    value: item.employee?.name ?? context.t.common.notAvailable,
                  ),
                  (
                    label: context.t.hrm.form.labels.paymentYear,
                    value: item.paymentYear ?? context.t.common.notAvailable,
                  ),
                  (label: context.t.hrm.form.labels.month, value: item.month ?? context.t.common.notAvailable),
                  (
                    label: context.t.common.date,
                    value: item.date?.getFormatedString() ?? context.t.common.notAvailable,
                  ),
                  (
                    label: context.t.hrm.form.labels.amount,
                    value: item.amount?.quickCurrency() ?? context.t.common.notAvailable,
                  ),
                  (
                    label: context.t.hrm.form.labels.paymentType,
                    value: item.paymentType?.name ?? context.t.common.notAvailable,
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
                const SizedBox.square(dimension: 8),

                // Note
                Text(
                  context.t.common.note,
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox.square(dimension: 2),
                Text(
                  item.note ?? context.t.hrm.fallbacks.noNoteAvailable,
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
  Future<PayrollListModel> fetchData(int page) async {
    return ref
        .read(payrollRepoProvider)
        .getPayrollList(
          page: page,
          search: searchController.text,
          employeeId: selectedFilterNotifier.value['employee_id'],
          month: selectedFilterNotifier.value['month']?.toLowerCase(),
        );
  }

  EventSub<PayrollModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<PayrollModel>().listen((_) {
      pagingController.refresh();
    });
    selectedFilterNotifier.addListener(pagingController.refresh);
    super.initRefreshListener();
  }
}

class _PayrollListItem extends StatelessWidget {
  const _PayrollListItem({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final PayrollModel data;
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
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Name + Date + Action
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        data.employee?.name ?? context.t.common.notAvailable,
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox.square(dimension: 4),

                      // Date
                      Text(
                        data.date?.getFormatedString() ?? context.t.common.notAvailable,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: _theme.paragraphColor,
                        ),
                      ),
                    ],
                  ),
                ),

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
            const SizedBox.square(dimension: 16),

            // Amount + Payment + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...[
                  (
                    label: context.t.hrm.form.labels.amount,
                    value: data.amount?.quickCurrency() ?? context.t.common.notAvailable,
                  ),
                  (
                    label: context.t.hrm.form.labels.payment,
                    value: data.paymentType?.name ?? context.t.common.notAvailable,
                  ),
                  (label: context.t.hrm.form.labels.status, value: data.amount != null && data.amount! > 0),
                ].map((entry) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Value
                      Text(
                        switch (entry.value) {
                          final _v when _v is bool =>
                            _v ? context.t.hrm.dropdowns.paid : context.t.hrm.dropdowns.unpaid,
                          _ => entry.value.toString(),
                        },
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: switch (entry.value) {
                            final _v when _v is bool => _v ? DAppColors.kSuccess : DAppColors.kError,
                            _ => null,
                          },
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
