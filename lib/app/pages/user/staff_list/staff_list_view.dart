import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/core.dart';
import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

part '_manage_staff_dialog.dart';

@RoutePage()
class StaffListView extends ConsumerStatefulWidget {
  const StaffListView({super.key});

  @override
  ConsumerState<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends ConsumerState<StaffListView> with PaginatedControllerMixin<StaffModel> {
  late final searchController = TextEditingController();

  final filters = ValueNotifier<Map<String, dynamic>>({});

  @override
  void initState() {
    initPaging();
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _eventListener?.cancel();
    pageDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        // title: const Text('All Staffs'),
        title: Text(context.t.pages.staffs.staffList.title),
      ),
      body: Column(
        children: [
          // Search Field
          ValueListenableBuilder(
            valueListenable: filters,
            builder: (_, selectedFilters, _) {
              return CustomSearchField(
                controller: searchController,
                decoration: CustomSearchFieldDecoration(
                  // hintText: 'Search here...',
                  hintText: context.t.common.searchHere,
                ),
                onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                  pagingController.refresh,
                ),
                onTapFilter: () async {
                  return await showFilterModalSheet<String, dynamic>(
                    context: context,
                    selectedFilters: selectedFilters,
                    filters: [
                      FilterModalData.dropdown(
                        key: 'designation',
                        // labelText: 'Designation',
                        labelText: context.t.pages.staffs.staffList.filters.designation.label,
                        // hintText: 'Select Designation',
                        hintText: context.t.pages.staffs.staffList.filters.designation.hint,
                        items: [
                          CustomDropdownMenuItem<StaffTypeEnum>(
                            value: null,
                            // label: TextSpan(text: 'All Staff'),
                            label: TextSpan(text: context.t.pages.staffs.staffList.title),
                          ),
                          ...StaffTypeEnum.values.map((designation) {
                            return CustomDropdownMenuItem<StaffTypeEnum>(
                              value: designation,
                              label: TextSpan(text: designation.label(context)),
                            );
                          }),
                        ],
                      ),
                    ],
                    onSave: (value) => filters.set(value),
                  );
                },
                appliedFilterCount: selectedFilters.values.where((element) => element != null).length,
              );
            },
          ).fMarginLTRB(16, 16, 16, 0),

          // Staff List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(pagingController.refresh),
              child: PagedListView<int, StaffModel>(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.only(top: 16, bottom: 72),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<StaffModel>(
                  itemBuilder: (c, staff, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(
                        text: staff.name ?? "N/A",
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: TextSpan(
                        text: staff.phone ?? "N/A",
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.paragraphColor,
                        ),
                      ),
                      onTap: () async {
                        return await showDialog<void>(
                          context: context,
                          builder: (popContext) => StaffDetailsDialog(
                            data: staff,
                          ),
                        );
                      },
                      onDelete: () async {
                        return await _handleDelete(
                          context,
                          () => ref.read(staffDesignationRepoProvider).deleteStaff(staff.id!),
                        );
                      },
                      onEdit: () async {
                        return await _handleManageStaff(
                          context,
                          editModel: staff,
                        );
                      },
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          // 'No stuff found!\n Please try adding a stuff',
                          context.t.exceptions.noStaffFound,
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
          onPressed: () async => await _handleManageStaff(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          // label: const Text('+ Add Staff'),
          label: Text('+ ${context.t.common.addStaff}'),
        ),
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleManageStaff(
    BuildContext context, {
    StaffModel? editModel,
  }) async {
    // ignore: unused_local_variable
    final _result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (popContext) {
        return ManageStaffDialog(editModel: editModel);
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Do you want to delete this staff?',
        title: context.t.prompt.deleteStaff,
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
  Future<PaginatedListModel<StaffModel>> fetchData(int page) {
    return ref
        .read(staffDesignationRepoProvider)
        .getStaffList(
          page: page,
          query: searchController.text,
          designation: (filters.value['designation'] as StaffTypeEnum?)?.stringValue,
        );
  }

  EventSub<StaffAE>? _eventListener;
  @override
  void initRefreshListener() {
    filters.addListener(pagingController.refresh);

    _eventListener = GlobalEventManager.I.on<StaffAE>().listen(
      (_) => pagingController.refresh(),
    );
    super.initRefreshListener();
  }
}

class StaffDetailsDialog extends StatelessWidget {
  const StaffDetailsDialog({super.key, required this.data});
  final StaffModel data;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    final _descStyle = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final _titleStyle = _descStyle?.copyWith(
      fontWeight: FontWeight.normal,
      color: _theme.colorScheme.secondary,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      backgroundColor: _theme.colorScheme.surface,
      child: BottomModalSheetWrapper(
        // title: const TextSpan(text: 'View Details'),
        title: TextSpan(text: context.t.common.viewDetails),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...{
                // "Name": data.name ?? "N/A",
                context.t.common.name: data.name ?? "N/A",
                // "Email": data.email ?? "N/A",
                context.t.common.email: data.email ?? "N/A",
                // "Phone": data.phone ?? "N/A",
                context.t.common.phoneNumber: data.phone ?? "N/A",
                // "Address": data.address ?? "N/A",
                context.t.common.address: data.address ?? "N/A",
                // "Designation": data.designation ?? "N/A",
                context.t.common.designation: data.designation ?? "N/A",
              }.entries.map(
                (entry) {
                  return KeyValueRow(
                    title: entry.key,
                    titleFlex: 3,
                    titleStyle: _titleStyle,
                    description: entry.value,
                    descriptionFlex: 5,
                    descriptionStyle: _descStyle,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
