import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../../i18n/strings.g.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

@RoutePage()
class EmployeeListView extends ConsumerStatefulWidget {
  const EmployeeListView({super.key});

  @override
  ConsumerState<EmployeeListView> createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends ConsumerState<EmployeeListView> with PaginatedControllerMixin<EmployeeModel> {
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
        title: Text(context.t.hrm.employee),
      ),
      body: PermissionGate(
        moduleKey: PMKeys.employee,
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

              // List of Employees
              Expanded(
                child: PagedListView<int, EmployeeModel>(
                  padding: const EdgeInsetsDirectional.only(bottom: 72),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  pagingController: pagingController,
                  builderDelegate: PagedChildBuilderDelegate<EmployeeModel>(
                    itemBuilder: (c, item, i) {
                      return ItemAttributeListTile(
                        leading: SizedBox.square(
                          dimension: 40,
                          child: UserAvatarPicker(
                            showBorder: false,
                            showInitialsPlaceholder: true,
                            image: item.image,
                            userName: item.name,
                            fit: BoxFit.cover,
                          ),
                        ),
                        name: TextSpan(
                          text: item.name ?? 'N/A',
                          style: _theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: TextSpan(text: item.phone ?? 'N/A'),
                        onTap: () => handleViewDetails(context, item),
                        onEdit: ref.canT(
                          PMKeys.employee,
                          action: PermissionAction.update,
                          input: () async {
                            return context.router.push<void>(
                              ManageEmployeeRoute(editModel: item),
                            );
                          },
                        ),
                        onDelete: ref.canT(
                          PMKeys.employee,
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
                            context.t.hrm.emptyStates.noEmployees,
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
              ManageEmployeeRoute(),
            );
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          label: Text(context.t.hrm.pageTitles.addEmployee),
          icon: const Icon(Icons.add, size: 18),
        ),
      ).can(PMKeys.employee, action: PermissionAction.create),
    ).unfocusPrimary();
  }

  Future<void> handleDelete(BuildContext context, int id) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        title: context.t.hrm.confirmations.deleteEmployee,
        onDecide: (value) => Navigator.of(popContext).pop(value),
      ),
    );
    if (_confirmation != true) return;

    if (context.mounted) {
      try {
        final _result = await showAsyncLoadingOverlay<String>(
          context,
          asyncFunction: () => Future.microtask(
            () => ref.read(employeeRepoProvider).deleteEmployee(id),
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

  Future<void> handleViewDetails(BuildContext context, EmployeeModel data) async {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Image
                SizedBox.square(
                  dimension: 100,
                  child: UserAvatarPicker(
                    showInitialsPlaceholder: true,
                    image: data.image,
                    userName: data.name,
                  ),
                ),
                const SizedBox.square(dimension: 24),

                // All Employee Details
                ...[
                  (label: context.t.form.fullName.label, value: data.name ?? 'N/A'),
                  (label: context.t.common.designation, value: data.designation?.name ?? 'N/A'),
                  (label: context.t.hrm.department, value: data.department?.name ?? 'N/A'),
                  (label: context.t.common.email, value: data.email ?? 'N/A'),
                  (label: context.t.form.phone.label, value: data.phone ?? 'N/A'),
                  (label: context.t.hrm.form.labels.country, value: data.country ?? 'N/A'),
                  (
                    label: context.t.hrm.form.labels.salary,
                    value: data.salary != null ? data.salary!.quickCurrency() : 'N/A',
                  ),
                  (label: context.t.hrm.form.labels.gender, value: data.gender ?? 'N/A'),
                  (label: context.t.hrm.shift, value: data.shift?.name ?? 'N/A'),
                  (label: context.t.hrm.form.labels.birthDate, value: data.dateOfBirth?.backSlashDateFormat ?? 'N/A'),
                  (label: context.t.hrm.form.labels.joinDate, value: data.joiningDate?.backSlashDateFormat ?? 'N/A'),
                  (label: context.t.common.status, value: data.status ?? 'N/A'),
                ].map(
                  (entry) {
                    return KeyValueRow(
                      title: entry.label,
                      titleFlex: 4,
                      titleStyle: _style?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                      description: entry.value,
                      descriptionFlex: 8,
                      descriptionStyle: _style?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: _theme.colorScheme.onSurface,
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
  Future<EmployeeListModel> fetchData(int page) async {
    return ref
        .read(employeeRepoProvider)
        .getEmployeeList(
          page: page,
          search: searchController.text,
        );
  }

  EventSub<EmployeeModel>? _apiEventSub;
  @override
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<EmployeeModel>().listen((_) {
      pagingController.refresh();
    });
    super.initRefreshListener();
  }
}
