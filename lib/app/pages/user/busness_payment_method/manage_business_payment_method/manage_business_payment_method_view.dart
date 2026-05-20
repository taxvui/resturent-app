import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../widgets/widgets.dart';
import '../../.../../../../data/repository/repository.dart';

part '_manage_business_payment_method_view_provider.dart';

@RoutePage()
class ManageBusinessPaymentMethodView extends ConsumerStatefulWidget {
  const ManageBusinessPaymentMethodView({
    super.key,
    @QueryParam('editModel') this.editModel,
  });

  final BusinessPaymentMethod? editModel;
  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManageBusinessPaymentMethodView> createState() => _ManageBusinessPaymentMethodViewState();
}

class _ManageBusinessPaymentMethodViewState extends ConsumerState<ManageBusinessPaymentMethodView> {
  @override
  void initState() {
    if (widget.isEditMode) {
      ref.read(manageBusinessPaymentMethodViewProvider).initEdit(widget.editModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(manageBusinessPaymentMethodViewProvider);

    final _theme = Theme.of(context);

    return FormWrapper(
      builder: (formContext) {
        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              widget.isEditMode ? context.t.pages.payment.editPaymentMethod : context.t.pages.payment.editPaymentMethod,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '${context.t.form.payment.label} *',
                    hintText: context.t.form.payment.hint,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.t.form.payment.error.required;
                    }
                    return null;
                  },
                ),
                const SizedBox.square(dimension: 14),

                // Status
                Row(
                  children: [
                    // Status
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: context.t.pages.payment.methodStatus.title,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Tooltip(
                                message: context.t.pages.payment.methodStatus.message,
                                triggerMode: TooltipTriggerMode.tap,
                                preferBelow: false,
                                child: Icon(
                                  Icons.info,
                                  size: 16,
                                  color: _theme.colorScheme.secondary,
                                ).fMarginOnly(left: 4),
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: SizedBox.fromSize(
                                size: const Size(44, 24),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Switch.adaptive(
                                    value: controller.isQuickView == true ? true : controller.isActive,
                                    onChanged: controller.toggleIsActive,
                                  ),
                                ),
                              ).fMarginOnly(left: 12),
                            ),
                          ],
                        ),
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          color: _theme.colorScheme.secondary,
                        ),
                      ),
                    ),

                    // Quick View
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: context.t.common.quickView,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Checkbox(
                                value: controller.isQuickView,
                                onChanged: (value) {
                                  return controller.toggleQuickView(value!);
                                },
                                activeColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.end,
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          color: _theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox.square(dimension: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (FormWrapper.validate(formContext)) {
                      return _handleFormSubmit(context);
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
      asyncFunction: () =>
          ref.read(manageBusinessPaymentMethodViewProvider).handleManagePaymentMethod(widget.editModel),
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
