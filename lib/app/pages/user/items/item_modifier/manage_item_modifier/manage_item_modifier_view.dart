import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../data/repository/repository.dart';

part '_manage_item_modifier_view_provider.dart';

@RoutePage()
class ManageItemModifierView extends ConsumerStatefulWidget {
  const ManageItemModifierView({super.key, this.editModel});
  final ItemModifier? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManageItemModifierViewState();
}

class _ManageItemModifierViewState extends ConsumerState<ManageItemModifierView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageItemModifierViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageItemModifierViewProvider);

    final _itemListAsync = ref.watch(itemsDropdownProvider);
    final _modifierGroupsAsync = ref.watch(itemModifierGroupDropdownProvider);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              // widget.isEditMode ? 'Edit Item Modifiers' : 'Add Item Modifiers',
              widget.isEditMode
                  ? context.t.pages.itemModifier.manageItemModifier.title2
                  : context.t.pages.itemModifier.manageItemModifier.title1,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Dropdown
                AsyncCustomDropdown<int, PItemList>(
                  asyncData: _itemListAsync,
                  decoration: InputDecoration(
                    // labelText: 'Item*',
                    labelText: '${context.t.form.item.label}*',
                    // hintText: 'Select item',
                    hintText: context.t.form.item.hint,
                  ),
                  value: controller.dropdownValues['item_id'],
                  items: _itemListAsync.when(
                    data: (data) => [
                      ...?data.data?.data?.map((item) {
                        return CustomDropdownMenuItem(
                          value: item.id,
                          label: TextSpan(text: item.productName ?? "N/A"),
                        );
                      }),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (v) {
                    return controller.handleDropdownChange(
                      MapEntry('item_id', v),
                    );
                  },
                  validator: FormBuilderValidators.required(
                    // errorText: 'Please select an item.',
                    errorText: context.t.form.item.errors.required,
                  ),
                  onRefresh: () => ref.refresh(itemsDropdownProvider),
                ),
                const SizedBox.square(dimension: 16),

                // Modifier Group Dropdown
                AsyncCustomDropdown<int, ModifierGroupList>(
                  asyncData: _modifierGroupsAsync,
                  decoration: InputDecoration(
                    // labelText: 'Modifier Group*',
                    labelText: '${context.t.form.modifierGroup.label}*',
                    // hintText: 'Select modifier group',
                    hintText: context.t.form.modifierGroup.hint,
                  ),
                  value: controller.dropdownValues['modifier_group_id'],
                  items: _modifierGroupsAsync.when(
                    data: (data) => [
                      ...?data.data?.data?.map((group) {
                        return CustomDropdownMenuItem(
                          value: group.id,
                          label: TextSpan(text: group.name ?? "N/A"),
                        );
                      }),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (v) => controller.handleDropdownChange(
                    MapEntry('modifier_group_id', v),
                  ),
                  onRefresh: () => ref.refresh(
                    itemModifierGroupDropdownProvider,
                  ),
                  validator: FormBuilderValidators.required(
                    // errorText: 'Please select a modifier group.',
                    errorText: context.t.form.modifierGroup.errors.required,
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Allow Multiple Selection For Sales
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SizedBox.square(
                          dimension: 16,
                          child: Checkbox(
                            value: controller.isMultiSelect,
                            onChanged: controller.handleToggleMultiSelect,
                          ),
                        ).fMarginOnly(right: 8),
                      ),
                      TextSpan(
                        // text: 'Allow Multiple Selection For Sales',
                        text: context.t.common.allowMultiSelectionForSale,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            controller.handleToggleMultiSelect(
                              !controller.isMultiSelect,
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Is Required
                Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SizedBox.square(
                          dimension: 16,
                          child: Checkbox(
                            value: controller.isRequired,
                            onChanged: controller.handleToggleRequired,
                          ),
                        ).fMarginOnly(right: 8),
                      ),
                      TextSpan(
                        // text: 'Is Required',
                        text: context.t.common.isRequired,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            controller.handleToggleRequired(
                              !controller.isRequired,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ElevatedButton(
            onPressed: () async {
              if (FormWrapper.validate(formContext)) {
                return _handleFormSubmit(context);
              }
            },
            // child: const Text('Save'),
            child: Text(context.t.action.save),
          ).fMarginLTRB(16, 12, 16, 16),
        );
      },
    );
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => Future.microtask(
        () => ref.read(manageItemModifierViewProvider).handleManageItemModifier(widget.editModel),
      ),
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

      context.router.maybePop(_result.right);
      return;
    }
  }
}
