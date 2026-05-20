import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../../routes/app_routes.gr.dart';
import '../../../../common/widgets/widgets.dart';

@RoutePage()
class QuotationItemListView extends ConsumerWidget {
  const QuotationItemListView({super.key, this.getBack = false});
  final bool getBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartController = ref.watch(quotationCartProvider);

    return Scaffold(
      appBar: CustomAppBar(
        // title: const Text('Add New Quotation'),
        title: Text(context.t.common.addItems),
        actions: [
          IconButton(
            onPressed: () async {
              return await context.router.push<void>(
                ManageItemRoute(),
              );
            },
            icon: const Icon(HugeIconsStroke.packageAdd),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          CustomSearchField(
            controller: cartController.searchController,
            decoration: CustomSearchFieldDecoration(
              // hintText: 'Search items name',
              hintText: context.t.common.searchItemsName,
            ),
            onTapFilter: () async {
              final _result = await showItemFilterBottomModalSheet(
                context: context,
                selectedFilters: {...cartController.filters},
              );
              if (_result == null) {
                return;
              }

              return cartController.handleFilter(_result);
            },
            onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
              cartController.pagingController.refresh,
            ),
          ).fMarginLTRB(16, 16, 16, 0),

          // Items
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(cartController.pagingController.refresh),
              child: ItemCartWidget.boxWidget(
                controller: cartController,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavWrapper(
        padding: const EdgeInsets.all(16),
        child: ItemCartWidget.totalButton(
          totalAmount: cartController.cartAmountOverview.totalAmount,
          totalQuantity: cartController.cartAmountOverview.totalQuantity,
          onPressed: () async {
            if (ItemCartWidget.hasItems(context, cartController)) {
              if (getBack) return context.router.pop();

              return await context.router.replace<void>(ManageQuotationRoute());
            }
          },
        ),
      ),
    ).unfocusPrimary();
  }
}
