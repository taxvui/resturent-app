import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../widgets/widgets.dart';

part '_manage_menu_view_provider.dart';

@RoutePage()
class ManageMenuView extends ConsumerStatefulWidget {
  const ManageMenuView({super.key, this.editModel});
  final ItemMenu? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageMenuView> createState() => _ManageMenuViewState();
}

class _ManageMenuViewState extends ConsumerState<ManageMenuView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageMenuProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageMenuProvider);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? 'Edit Menu' : 'Add New Menu',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 16),
            child: Column(
              children: [
                // Menu Name
                TextFormField(
                  controller: controller.menuNameController,
                  decoration: const InputDecoration(
                    labelText: 'Menu Name',
                    hintText: 'Enter menu name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter menu name';
                    }
                    return null;
                  },
                ),
                const SizedBox.square(dimension: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return await _handleFormSubmit(context);
                    }
                  },
                  child: Text(context.t.action.save),
                ),
              ],
            ),
          ),
        );
      },
    ).unfocusPrimary();
  }

  Future<void> _handleFormSubmit(BuildContext context) async {
    final _result = await showAsyncLoadingOverlay(
      context,
      asyncFunction: () => Future.microtask(
        () => ref.read(manageMenuProvider).handleManageMenu(widget.editModel),
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
