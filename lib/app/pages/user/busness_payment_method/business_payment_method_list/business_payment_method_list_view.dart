import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part '_business_payment_method_list_view_provider.dart';

@RoutePage()
class BusinessPaymentMethodListView extends ConsumerWidget {
  const BusinessPaymentMethodListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(businessPaymentMethodListViewProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        controller.initRefreshListener();
      }
    });

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          // 'Payment Method',
          context.t.pages.payment.title,
        ),
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: controller.searchController,
            decoration: CustomSearchFieldDecoration(
              hintText: context.t.common.searchHere,
              actions: [
                if (ref.can(PMKeys.paymentMethod, action: PermissionAction.create)) ...[
                  const SizedBox.square(dimension: 8),
                  CustomSearchFieldActionButton.custom(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      return await context.router.push<void>(
                        ManageBusinessPaymentMethodRoute(),
                      );
                    },
                    style: CustomSearchFieldActionButton.themeColored(context),
                  ),
                ],
              ],
            ),
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              controller.pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Payment Method List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(controller.pagingController.refresh),
              child: PagedListView<int, BusinessPaymentMethod>(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: controller.pagingController,
                builderDelegate: PagedChildBuilderDelegate<BusinessPaymentMethod>(
                  itemBuilder: (c, method, i) {
                    return ItemAttributeListTile(
                      name: TextSpan(
                        text: method.name,
                        children: [
                          if (method.isView == true)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: _theme.colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                child: Text(
                                  context.t.common.quickView,
                                  style: _theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _theme.colorScheme.primary,
                                  ),
                                ),
                              ).fMarginOnly(left: 10),
                            ),
                        ],
                      ),
                      onDelete: !ref.can(PMKeys.paymentMethod, action: PermissionAction.delete)
                          ? null
                          : () async {
                              return await _handleDelete(
                                context,
                                () => controller.repo.deleteBusinessPaymentMethod(method.id!),
                              );
                            },
                      onEdit: !ref.can(PMKeys.paymentMethod, action: PermissionAction.update)
                          ? null
                          : () async {
                              return await context.router.push<void>(
                                ManageBusinessPaymentMethodRoute(editModel: method),
                              );
                            },
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noPaymentMethodFoundPleaseTryAddingAPaymentMethod,
                          onRetry: controller.pagingController.refresh,
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
    ).unfocusPrimary();
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Do you want to delete this payment method?',
        title: context.t.prompt.paymentMethod.title,
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
}
