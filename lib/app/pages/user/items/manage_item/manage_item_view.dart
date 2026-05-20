import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';

part '_manage_item_view_provider.dart';

@RoutePage()
class ManageItemView extends ConsumerStatefulWidget {
  const ManageItemView({super.key, this.editModel});
  final PItem? editModel;

  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageItemView> createState() => _ManageItemViewState();
}

class _ManageItemViewState extends ConsumerState<ManageItemView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageItemProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageItemProvider);
    final _itemMenuListAsync = ref.watch(itemMenuDropdownProvider);
    final _itemCategoryListAsync = ref.watch(itemCategoryDropdownProvider);
    final _itemModifierGroupListAsync = ref.watch(
      itemModifierGroupDropdownProvider,
    );

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.pages.items.manageItems.title2 : context.t.pages.items.manageItems.title,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Text.rich(
                  TextSpan(
                    text: '${context.t.common.image} ',
                    children: [
                      TextSpan(
                        text: '(${context.t.pages.items.manageItems.extra.maximum})',
                        style: TextStyle(
                          color: _theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox.square(dimension: 8),

                SizedBox(
                  width: double.maxFinite,
                  height: 75,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    itemCount: controller.images.length + 1,
                    itemBuilder: (context, index) {
                      const _previewSize = Size.square(70);
                      final _placeholderKey = GlobalKey<FormFieldState<DynamicFileType>>();

                      if (index == 0) {
                        return SizedBox.fromSize(
                          size: _previewSize,
                          child: InkWell(
                            onTap: () async {
                              return await _handleImagePicker(
                                context,
                                controller,
                              );
                            },
                            child: AbsorbPointer(
                              child: ImageFormField(
                                key: _placeholderKey,
                                previewSize: _previewSize,
                                decoration: ImageFieldDecoration(
                                  hintText: TextSpan(text: context.t.common.upload),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final _image = controller.images[index - 1];
                      return ImageFormField(
                        key: ValueKey(_image.hashCode),
                        previewSize: _previewSize,
                        initialValue: _image,
                        onSelectImage: (value) {
                          return controller.handleImage(
                            value,
                            value.local == null ? (index - 1) : null,
                          );
                        },
                      );
                    },
                    separatorBuilder: (c, i) {
                      return const SizedBox.square(dimension: 8);
                    },
                  ),
                ),
                const SizedBox.square(dimension: 24),

                // Item Name
                TextFormField(
                  controller: controller.itemNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    // labelText: 'Item Name*',
                    labelText: '${context.t.form.items.itemName.label}*',
                    // hintText: 'Enter item name',
                    hintText: context.t.form.items.itemName.hint,
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: context.t.form.items.itemName.extra.required,
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Item Menu
                AsyncCustomDropdown<int, ItemMenuList>(
                  asyncData: _itemMenuListAsync,
                  decoration: InputDecoration(
                    // labelText: 'Choose Menu*',
                    labelText: '${context.t.form.items.menu.label}*',
                    // hintText: 'Select one',
                    hintText: context.t.form.items.menu.hint,
                  ),
                  value: controller.dropdownValues['menu'],
                  items: _itemMenuListAsync.when(
                    data: (data) => [
                      // Navigator
                      CustomDropdownMenuItem.navigator(
                        // label: 'Select Item Menu',
                        label: context.t.form.items.menu.extra.selectNavLabel,
                        // navLabel: '+ Add New',
                        navLabel: "+ ${context.t.common.addNew}",
                        onNavTap: () async {
                          if (ref.canSnackbar(context, PMKeys.menus, action: PermissionAction.create)) {
                            return await context.router.push<ItemMenu>(ManageMenuRoute()).then(
                              (value) {
                                if (value != null) {
                                  controller.handleDropdownChange(
                                    MapEntry('menu', value.id),
                                  );
                                }
                              },
                            );
                          }
                        },
                      ),

                      ...?data.data?.data?.map((menu) {
                        return CustomDropdownMenuItem<int>(
                          value: menu.id,
                          label: TextSpan(text: menu.name ?? "N/A"),
                        );
                      }),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (v) => controller.handleDropdownChange(
                    MapEntry('menu', v),
                  ),
                  validator: FormBuilderValidators.required(
                    // errorText: 'Please select a menu.',
                    errorText: context.t.form.items.menu.errors.required,
                  ),
                  onRefresh: () => ref.refresh(itemMenuDropdownProvider),
                ),
                const SizedBox.square(dimension: 16),

                // Item Category
                AsyncCustomDropdown<int, ItemCategoryList>(
                  asyncData: _itemCategoryListAsync,
                  decoration: InputDecoration(
                    // labelText: 'Item Category*',
                    labelText: '${context.t.form.items.itemCategory.label}*',
                    // hintText: 'Select one',
                    hintText: context.t.form.items.itemCategory.hint,
                  ),
                  value: controller.dropdownValues['category'],
                  items: _itemCategoryListAsync.when(
                    data: (data) => [
                      // Navigator
                      CustomDropdownMenuItem.navigator(
                        // label: 'Select Item Category',
                        label: context.t.form.category.hint,
                        // navLabel: '+ Add New',
                        navLabel: '+ ${context.t.common.addNew}',
                        onNavTap: () async {
                          return await context.router.push<ItemCategory>(ManageCategoryRoute()).then(
                            (value) {
                              if (value != null) {
                                controller.handleDropdownChange(
                                  MapEntry('category', value.id),
                                );
                              }
                            },
                          );
                        },
                      ),

                      ...?data.data?.data?.map((category) {
                        return CustomDropdownMenuItem<int>(
                          value: category.id,
                          label: TextSpan(text: category.categoryName ?? "N/A"),
                        );
                      }),
                    ],
                    error: (_, _) => [],
                    loading: () => [],
                  ),
                  onChanged: (v) => controller.handleDropdownChange(
                    MapEntry('category', v),
                  ),
                  validator: FormBuilderValidators.required(
                    // errorText: 'Please select a category',
                    errorText: context.t.form.items.itemCategory.extra.required,
                  ),
                  onRefresh: () => ref.refresh(itemCategoryDropdownProvider),
                ),
                const SizedBox.square(dimension: 16),

                // Modifier Items
                MultiSelectFormField<int, ModifierGroupList>.dropdown(
                  asyncData: _itemModifierGroupListAsync,
                  decoration: InputDecoration(
                    // labelText: 'Modifier Items',
                    labelText: context.t.form.items.modifierItems.label,
                    // hintText: 'Select modifier items',
                    hintText: context.t.form.items.modifierItems.hint,
                  ),
                  value: controller.selectedModifierGroups,
                  items: _itemModifierGroupListAsync.when(
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
                  onChanged: controller.handleSelectModifierGroups,
                  onRefresh: () => ref.refresh(
                    itemModifierGroupDropdownProvider,
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Preparation Time (Minutes)
                NumberFormField(
                  controller: controller.preparationTimeController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    label: Text.rich(
                      TextSpan(
                        text: 'Preparation Time ',
                        children: [
                          TextSpan(
                            text: '(Minutes)',
                            style: TextStyle(
                              color: _theme.paragraphColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // hintText: 'Ex: 30',
                    hintText: context.t.form.items.preparationTime.hint,
                  ),
                  decimalDigits: 0,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox.square(dimension: 16),

                // Food Type
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    itemCount: ItemFoodTypeEnum.values.length,
                    itemBuilder: (_, index) {
                      final _foodType = ItemFoodTypeEnum.values[index];
                      final _isSelected = controller.foodType == _foodType;

                      return SelectedButton(
                        isSelected: _isSelected,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(_foodType.label(context)),
                        onPressed: () {
                          return controller.handleSelectFoodType(_foodType);
                        },
                      );
                    },
                    separatorBuilder: (_, _) {
                      return const SizedBox.square(dimension: 8);
                    },
                  ),
                ),
                const SizedBox.square(dimension: 16),

                // Item Type
                SizedBox(
                  height: 40,
                  child: RadioGroup<ItemTypeEnum>(
                    groupValue: controller.itemType,
                    onChanged: controller.handleSelectItemType,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ItemTypeEnum.values.length,
                      itemBuilder: (_, index) {
                        final _itemType = ItemTypeEnum.values[index];
                        final _isSelected = controller.itemType == _itemType;

                        return InkWell(
                          onTap: () => controller.handleSelectItemType(_itemType),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<ItemTypeEnum>(
                                value: _itemType,
                                visualDensity: const VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity,
                                ),
                                fillColor: WidgetStateColor.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return _theme.colorScheme.primary;
                                  }
                                  return _theme.paragraphColor.withValues(
                                    alpha: 0.75,
                                  );
                                }),
                              ),
                              const SizedBox.square(dimension: 4),
                              Text(
                                _itemType.label(context),
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _isSelected ? null : _theme.paragraphColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, _) {
                        return const SizedBox.square(dimension: 8);
                      },
                    ),
                  ),
                ),
                const SizedBox.square(dimension: 12),

                if (controller.itemType.isVariation)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      ...List.generate(controller.variations.length, (index) {
                        final vc = controller.variations[index];
                        return VariationFormBuilder(
                          controller: vc,
                          showAddButton: index == 0,
                          onAdd: controller.handleVariation,
                          onRemove: () => controller.handleVariation(index),
                        );
                      }),
                    ],
                  )
                else ...[
                  // Sale Price
                  NumberFormField(
                    controller: controller.salePriceController,
                    decoration: InputDecoration(
                      // labelText: 'Sale Price *',
                      labelText: '${context.t.form.items.salePrice.label} *',
                      // hintText: 'Ex: \$60',
                      hintText: context.t.form.items.salePrice.hint,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        // errorText: 'Please enter sale price.',
                        errorText: context.t.form.items.salePrice.error.required,
                      ),
                      FormBuilderValidators.notZeroNumber(),
                    ]),
                  ),
                ],

                const SizedBox.square(dimension: 16),
                // Description
                TextFormField(
                  controller: controller.descriptionController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 2,
                  decoration: InputDecoration(
                    // labelText: 'Description',
                    labelText: context.t.form.description.label,
                    // hintText: 'Enter description',
                    hintText: context.t.form.description.hint,
                    contentPadding: EdgeInsets.all(12),
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
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => ref
          .read(manageItemProvider)
          .handleManageItem(
            widget.editModel,
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

      context.router.maybePop();
      return;
    }
  }

  Future<void> _handleImagePicker(
    BuildContext context,
    ManageItemViewNotifier controller,
  ) async {
    void _showMaxAlert() {
      showCustomSnackBar(
        context,
        // content: const Text('You can only select up to 5 images.'),
        content: Text(context.t.exceptions.maxImageCountLimit),
        customSnackBarType: CustomOverlayType.info,
      );
    }

    if (controller.images.length >= 5) {
      return _showMaxAlert();
    }

    final pickedFile = await showImagePickerDialog(
      context,
      selectMultiple: true,
    );

    if (pickedFile == null || pickedFile.isEmpty) return;

    final totalImagesCount = controller.images.length + pickedFile.length;

    if (totalImagesCount > 5) {
      return _showMaxAlert();
    }

    for (var element in pickedFile) {
      controller.handleImage(
        DynamicFileType(local: element),
      );
    }
  }
}

class VariationFormBuilder extends StatelessWidget {
  const VariationFormBuilder({
    super.key,
    required this.controller,
    this.showAddButton = false,
    this.onAdd,
    this.onRemove,
  });
  final VariationFormController controller;
  final bool showAddButton;

  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (_, _, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  // labelText: 'Name*',
                  labelText: '${context.t.form.items.variation.name.label}*',
                  // hintText: 'Enter variation',
                  hintText: context.t.form.items.variation.name.hint,
                ),
                validator: FormBuilderValidators.required(
                  // errorText: 'Please enter variation name.',
                  errorText: context.t.form.items.variation.name.errors.required,
                ),
              ),
            ),
            const SizedBox.square(dimension: 12),
            Expanded(
              child: NumberFormField(
                controller: controller.priceController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  // labelText: 'Price*',
                  labelText: '${context.t.form.items.variation.price.label}*',
                  // hintText: 'Ex: \$30',
                  hintText: context.t.form.items.variation.price.hint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (value.plainNumber < 0) {
                    return FormBuilderLocalizations.of(context).positiveNumberErrorText;
                  }

                  return null;
                },
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
        );
      },
    );
  }
}

class VariationFormData {
  VariationFormData({
    this.name,
    this.price,
  });
  final String? name;
  final num? price;
}

class VariationFormController extends ValueNotifier<VariationFormData> {
  VariationFormController() : super(VariationFormData());

  late final nameController = TextEditingController();
  late final priceController = TextEditingController();

  VariationFormData get data {
    return VariationFormData(
      name: nameController.text,
      price: priceController.getNumber ?? 0,
    );
  }

  void initEdit(VariationFormData data) {
    nameController.text = data.name ?? '';
    priceController.text = data.price?.toString() ?? '';
    value = data;
    notifyListeners();
  }
}
