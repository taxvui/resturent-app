import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../widgets/widgets.dart';

import '_manage_area_modal.dart';

class ManageTableModal extends ConsumerStatefulWidget {
  const ManageTableModal({super.key, this.editModel});
  final PTable? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageTableModalState();
}

class _ManageTableModalState extends ConsumerState<ManageTableModal> {
  //-------------------------Form Field Props-------------------------//
  late final tableNameController = TextEditingController();
  late final tableCapacityController = TextEditingController();
  int? selectedAreaId;
  bool isEnabled = true;
  //-------------------------Form Field Props-------------------------//

  void initEdit() {
    tableNameController.text = widget.editModel?.name ?? "";
    tableCapacityController.text = widget.editModel?.capacity?.toString() ?? "";
    selectedAreaId = widget.editModel?.areaId;
    isEnabled = widget.editModel?.activeStatus == 1;
  }

  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final areaListAsync = ref.watch(areasDropdownProvider);

    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(text: widget.isEditMode ? context.t.pages.table.editTable : context.t.pages.table.title),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Table Name
                TextFormField(
                  controller: tableNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.t.form.table.name.label,
                    hintText: context.t.form.table.name.hint,
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.form.table.name.error.required,
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Table Capacity
                NumberFormField(
                  controller: tableCapacityController,
                  decimalDigits: 0,
                  decoration: InputDecoration(
                    labelText: context.t.form.table.capacity.label,
                    hintText: context.t.form.table.capacity.hint,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.notZeroNumber(
                      errorText: context.t.form.table.capacity.error.required,
                    ),
                    FormBuilderValidators.positiveNumber(),
                  ]),
                ),
                const SizedBox.square(dimension: 20),

                // Areas Dropdown
                AsyncCustomDropdown<int, AreaList>(
                  asyncData: areaListAsync,
                  decoration: const InputDecoration(
                    labelText: 'Area*',
                    hintText: 'Select area',
                  ),
                  value: selectedAreaId,
                  items: areaListAsync.when(
                    data: (data) {
                      return [
                        CustomDropdownMenuItem.navigator(
                          label: 'Select an Area',
                          navLabel: '+ Add New',
                          onNavTap: () async {
                            if (ref.canSnackbar(context, PMKeys.areas, action: PermissionAction.create)) {
                              return showManageAreaModal(context);
                            }
                          },
                        ),
                        ...?data.data?.data?.map(
                          (area) {
                            return CustomDropdownMenuItem(
                              value: area.id,
                              label: TextSpan(text: area.name ?? 'N/A'),
                            );
                          },
                        ),
                      ];
                    },
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (value) => setState(() => selectedAreaId = value),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'Please select an area',
                    ),
                  ]),
                ),
                const SizedBox.square(dimension: 20),

                // Status
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text.rich(
                    TextSpan(
                      text: 'Status ',
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox.fromSize(
                            size: const Size(40, 22),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Switch(
                                value: isEnabled,
                                onChanged: (value) => setState(() => isEnabled = value),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return handleFormSubmit(context);
                    }
                  },
                  child: Text(widget.isEditMode ? 'Update' : 'Save'),
                ),

                // Keyboard Spacer
                SizedBox.square(
                  dimension: MediaQuery.viewInsetsOf(context).bottom,
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? PTable()).copyWith(
        name: tableNameController.text,
        capacity: tableCapacityController.getNumber?.toInt(),
        areaId: selectedAreaId,
        activeStatus: isEnabled ? 1 : 0,
      );

      await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(tableRepoProvider).manageTable(_data),
        ),
      );

      if (context.mounted) {
        return Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackBar(
          context,
          content: Text(e.toString()),
          customSnackBarType: CustomOverlayType.error,
        );
        return Navigator.of(context).pop();
      }
    }
  }
}

Future<void> showManageTableModal(BuildContext context, {PTable? editModel}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    builder: (_) => ManageTableModal(editModel: editModel),
  );
}
