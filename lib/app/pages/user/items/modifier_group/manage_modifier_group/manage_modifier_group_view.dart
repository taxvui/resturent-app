import 'package:auto_route/auto_route.dart';
import 'package:expansion_widget/expansion_widget.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../../core/core.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../data/repository/repository.dart';

part '_manage_modifier_group_view_provider.dart';

@RoutePage()
class ManageModifierGroupView extends ConsumerStatefulWidget {
  const ManageModifierGroupView({super.key, this.editModel});
  final ItemModifierGroup? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageModifierGroupView> createState() => _ManageModifierGroupViewState();
}

class _ManageModifierGroupViewState extends ConsumerState<ManageModifierGroupView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageModifierGroupViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageModifierGroupViewProvider);

    final _itemListAsync = ref.watch(itemsDropdownProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? 'Edit Modifier Group' : 'Add Modifier Group',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Modifier Name
                TextFormField(
                  controller: controller.modifierNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Modifier Name',
                    hintText: 'Enter modifier name',
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'Please enter modifier name.',
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Description
                TextFormField(
                  controller: controller.descriptionController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Location
                if (!widget.isEditMode) ...[
                  MultiSelectFormField<int, PItemList>.dropdown(
                    asyncData: _itemListAsync,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Select location',
                    ),
                    value: controller.selectedLocations,
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
                    onChanged: controller.handleSelectLocations,
                    onRefresh: () => ref.refresh(itemsDropdownProvider),
                  ),
                  const SizedBox.square(dimension: 16),
                ],

                // Modifier Options
                ExpansionWidget.autoSaveState(
                  initiallyExpanded: true,
                  titleBuilder: (av, ev, ie, tf) {
                    return InkWell(
                      onTap: () => tf(animated: true),
                      child: Row(
                        children: [
                          Icon(
                            ie ? Icons.remove_circle_outline : Icons.add_circle_outline,
                            size: 20,
                            color: _theme.colorScheme.primary,
                          ),
                          const SizedBox.square(dimension: 8),
                          Text(
                            'Modifier Options',
                            style: _theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  content: Column(
                    spacing: 16,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(dimension: 8),
                      ...List.generate(
                        controller.modifierOptions.length,
                        (index) {
                          final oc = controller.modifierOptions[index];
                          return ModifierOptionFormBuilder(
                            key: ValueKey(oc.hashCode),
                            controller: oc,
                            showAddButton: (index == 0),
                            onAdd: controller.handleModifierOption,
                            onRemove: () => controller.handleModifierOption(
                              index,
                            ),
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
            child: const Text('Save'),
          ).fMarginLTRB(16, 12, 16, 16),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => Future.microtask(
        () => ref.read(manageModifierGroupViewProvider).handleManageModifierGroup(widget.editModel),
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

class ModifierOptionFormBuilder extends StatelessWidget {
  const ModifierOptionFormBuilder({
    super.key,
    required this.controller,
    this.showAddButton = false,
    this.onAdd,
    this.onRemove,
  });
  final ModifierOptionFormController controller;
  final bool showAddButton;

  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, _, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name*',
                      hintText: 'Ex: Extra cheese',
                    ),
                    validator: FormBuilderValidators.required(
                      errorText: 'Please enter name.',
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 12),
                Expanded(
                  child: NumberFormField(
                    controller: controller.priceController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Price*',
                      hintText: 'Ex: \$30',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Please enter price.',
                      ),
                      FormBuilderValidators.positiveNumber(),
                    ]),
                  ),
                ),
                IconButton(
                  onPressed: showAddButton ? onAdd : onRemove,
                  icon: Icon(
                    showAddButton ? Icons.add : HugeIconsStroke.delete03,
                    color: showAddButton ? DAppColors.kSuccess : DAppColors.kError,
                  ),
                ),
              ],
            ),
            const SizedBox.square(dimension: 8),
            Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SizedBox.square(
                      dimension: 16,
                      child: Checkbox(
                        value: controller.isAvailable,
                        onChanged: controller.toggleAvailability,
                      ),
                    ).fMarginOnly(right: 8),
                  ),
                  TextSpan(
                    text: 'Is Available',
                    recognizer: TapGestureRecognizer()..onTap = controller.toggleAvailability,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ModifierOptionFormData {
  ModifierOptionFormData({
    this.name,
    this.price,
    this.isAvailable = false,
  });
  final String? name;
  final num? price;
  final bool isAvailable;
}

class ModifierOptionFormController extends ValueNotifier<ModifierOptionFormData> {
  ModifierOptionFormController() : super(ModifierOptionFormData());

  late final nameController = TextEditingController();
  late final priceController = TextEditingController();

  bool isAvailable = false;
  void toggleAvailability([bool? value]) {
    isAvailable = value ?? !isAvailable;
    notifyListeners();
  }

  void initEdit(ModifierOptionFormData data) {
    nameController.text = data.name ?? '';
    priceController.text = data.price?.toString() ?? '';
    isAvailable = data.isAvailable;
    value = data;
    notifyListeners();
  }

  ModifierOptionFormData get data {
    return ModifierOptionFormData(
      name: nameController.text,
      price: priceController.getNumber ?? 0,
      isAvailable: isAvailable,
    );
  }
}
