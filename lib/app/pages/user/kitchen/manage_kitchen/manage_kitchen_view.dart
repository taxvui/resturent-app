import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

class ManageKitchenView extends ConsumerStatefulWidget {
  const ManageKitchenView({super.key, this.editModel});
  final KitchenModel? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageKitchenView> createState() => _ManageKitchenViewState();
}

class _ManageKitchenViewState extends _$ManageKitchenViewState {
  @override
  void initState() {
    if (widget.isEditMode) {
      initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormWrapper(
      builder: (formContext) {
        return BottomModalSheetWrapper(
          title: TextSpan(
            text: widget.isEditMode
                ? context.t.pages.kitchen.manage.editKitchen
                : context.t.pages.kitchen.manage.addKitchen,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              // Image
              ValueListenableBuilder(
                valueListenable: selectedImageNotifier,
                builder: (_, value, _) {
                  return ImageFormField(
                    decoration: ImageFieldDecoration(
                      labelText: TextSpan(text: context.t.common.image),
                      hintText: TextSpan(text: context.t.common.upload),
                    ),
                    previewSize: const Size.square(70),
                    initialValue: value,
                    onSelectImage: selectedImageNotifier.set,
                  );
                },
              ),
              const SizedBox.square(dimension: 20),

              // Kitchen Name
              TextFormField(
                controller: kitchenNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.t.pages.kitchen.manage.kitchenName.label,
                  hintText: context.t.pages.kitchen.manage.kitchenName.hint,
                ),
                validator: FormBuilderValidators.required(
                  errorText: context.t.pages.kitchen.manage.kitchenName.error,
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsetsDirectional.all(10),
                  labelText: context.t.pages.kitchen.manage.description.label,
                  hintText: context.t.pages.kitchen.manage.description.hint,
                ),
              ),
              const SizedBox.square(dimension: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (FormWrapper.validate(formContext)) {
                    return handleFormSubmit(context);
                  }
                },
                child: Text(context.t.action.save),
              ),
            ],
          ),
        );
      },
    ).unfocusPrimary();
  }
}

abstract class _$ManageKitchenViewState extends ConsumerState<ManageKitchenView> {
  //-----------------------Form Field Props-----------------------//
  late final selectedImageNotifier = ValueNotifier<DynamicFileType?>(null),
      kitchenNameController = TextEditingController(),
      descriptionController = TextEditingController();
  //-----------------------Form Field Props-----------------------//

  void initEdit(KitchenModel data) {
    selectedImageNotifier.value = data.image;
    kitchenNameController.text = data.name ?? '';
    descriptionController.text = data.description ?? '';
  }

  Future<void> handleFormSubmit(BuildContext context) async {
    try {
      final _data = (widget.editModel ?? KitchenModel()).copyWith(
        image: selectedImageNotifier.value,
        name: kitchenNameController.text,
        description: descriptionController.text,
      );

      final _result = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(kitchenRepoProvider).manageKitchen(_data),
        ),
      );

      if (context.mounted) {
        context.router.maybePop(_result);
        return;
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
