import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/core.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../../i18n/strings.g.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';

class PaymentSelectorFormField extends ConsumerWidget {
  const PaymentSelectorFormField({
    super.key,
    this.selectedPaymentMethod,
    this.onChanged,
    this.autoSelectFirst = false,
  });

  final int? selectedPaymentMethod;
  final void Function(int? value)? onChanged;
  final bool autoSelectFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _paymentMethodAsync = ref.watch(businessPaymentMethodDropdownProvider);

    return _paymentMethodAsync.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        if (autoSelectFirst && selectedPaymentMethod == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final _quickSelect = data.data?.data?.lastWhereOrNull(
              (element) => element.isView == true,
            );
            onChanged?.call(_quickSelect?.id);
          });
        }

        return _buildSelector(context, data: [...?data.data?.data]);
      },
      error: (err, st) {
        return Text.rich(
          RetryButtons.inlineText(
            err,
            onRetry: () => ref.invalidate(
              businessPaymentMethodDropdownProvider,
            ),
          ),
        );
      },
      loading: () => Skeletonizer(child: _buildSelector(context)),
    );
  }

  Widget _buildSelector(
    BuildContext context, {
    List<BusinessPaymentMethod> data = const [],
  }) {
    final _theme = Theme.of(context);

    final _buttonStyle = CustomSearchFieldActionButton.defaultStyle(context);

    final _quickPayments = data.where((e) => e.isView == true).toList();
    final _otherPayments = data.where((e) => e.isView != true).toList();

    return Consumer(
      builder: (_, ref, _) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 64,
            minWidth: double.maxFinite,
          ),
          child: Row(
            children: [
              // Other Payments
              Expanded(
                flex: 6,
                child: CustomDropdown<int>(
                  isExpanded: true,
                  showClearButton: false,
                  decoration: InputDecoration(
                    // hintText: 'Choose Online Payment',
                    hintText: context.t.pages.payment.choseOnlinePayment,
                    hintMaxLines: 1,
                  ),
                  value: _otherPayments.any((element) => element.id == selectedPaymentMethod)
                      ? selectedPaymentMethod
                      : null,
                  items: [
                    // Navigator
                    CustomDropdownMenuItem.navigator(
                      // label: 'Select Payment Method',
                      label: context.t.pages.payment.selectPaymentMethod,
                      // navLabel: '+ Add New',
                      navLabel: '+ ${context.t.common.addNew}',
                      onNavTap: () async {
                        if (ref.canSnackbar(context, PMKeys.paymentMethod, action: PermissionAction.create)) {
                          return await context.router
                              .push<BusinessPaymentMethod>(ManageBusinessPaymentMethodRoute())
                              .then(
                                (value) {
                                  if (value != null) {
                                    onChanged?.call(value.id);
                                  }
                                },
                              );
                        }
                      },
                    ),
                    ..._otherPayments.map(
                      (method) {
                        return CustomDropdownMenuItem(
                          value: method.id,
                          label: TextSpan(text: method.name),
                        );
                      },
                    ),
                  ],
                  onChanged: onChanged,
                ),
              ),

              // Quick Payments
              ...List.generate(
                _quickPayments.length,
                (index) {
                  final _method = _quickPayments[index];
                  final _isSelected = _method.id == selectedPaymentMethod;

                  return Expanded(
                    flex: 3,
                    child: OutlinedButton(
                      onPressed: () => onChanged?.call(_method.id),
                      style: _buttonStyle.copyWith(
                        minimumSize: WidgetStateProperty.all(
                          Size.fromHeight(64 - 16),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color?>(
                          _isSelected ? _theme.colorScheme.primary.withValues(alpha: 0.15) : null,
                        ),
                        foregroundColor: WidgetStateProperty.all<Color?>(
                          _isSelected ? _theme.colorScheme.primary : _theme.colorScheme.secondary,
                        ),
                        side: _isSelected
                            ? WidgetStateProperty.all<BorderSide?>(
                                BorderSide(color: _theme.colorScheme.primary),
                              )
                            : null,
                        textStyle: WidgetStateProperty.all<TextStyle?>(
                          _theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
                          EdgeInsets.zero,
                        ),
                      ),
                      child: Text(_method.name ?? 'N/A'),
                    ).fMarginOnly(right: index == 1 ? 0 : 8, left: 8),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static bool validate(BuildContext context, int? value) {
    if (value != null) return true;

    showCustomSnackBar(
      context,
      content: Text(context.t.pages.payment.pleaseSelectAPaymentMethod),
      customSnackBarType: CustomOverlayType.error,
    );
    return false;
  }
}
