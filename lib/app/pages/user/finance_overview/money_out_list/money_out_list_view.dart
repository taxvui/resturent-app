import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../_money_in_out_list_view_provider.dart';

@RoutePage()
class MoneyOutListView extends ConsumerWidget {
  const MoneyOutListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(moneyInOutListViewProvider('money_out'));

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.moneyOut.title),
        actions: [
          DropdownDateFilter(
            value: controller.selectedDateFilter,
            onChanged: controller.updateDateFilter,
          ).fMarginSymmetric(horizontal: 10, vertical: 12),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              // Overview
              OverviewContainer(
                label: context.t.pages.moneyOut.totalMoneyOut,
                value: controller.totalAmount,
                color: Color(0xffFFDADA),
                isCurrency: true,
                decimalDigits: 1,
              ),
              const SizedBox.square(dimension: 16),

              // Search Field
              CustomSearchField(
                controller: controller.searchController,
                decoration: CustomSearchFieldDecoration(
                  hintText: context.t.common.searchInvoiceNumber,
                ),
                onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(
                  controller.pagingController.refresh,
                ),
              ),
            ],
          ).fMarginLTRB(16, 16, 16, 0),

          // Transaction List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => Future.sync(controller.pagingController.refresh),
              child: PagedListView<int, MoneyInOutModel>.separated(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                pagingController: controller.pagingController,
                builderDelegate: PagedChildBuilderDelegate<MoneyInOutModel>(
                  itemBuilder: (c, item, i) {
                    return TransactionCard(
                      cardData: TransactionCardData(
                        cardType: TransactionCardType.purchaseList(
                          status: item.hasDue ? TransactionCardStatus.due : TransactionCardStatus.paid,
                        ),
                        invoiceNumber: item.invoiceNumber ?? "N/A",
                        paymentType: item.paymentType?.name,
                        transactionDate: item.purchaseDate,
                        primaryValue: item.totalAmount ?? 0,
                        secondaryValue: item.paidAmount ?? 0,
                      ),
                    );
                  },
                  noItemsFoundIndicatorBuilder: (context) {
                    return EmptyWidget(
                      replaceDefault: false,
                      emptyBuilder: (context) {
                        return RetryButtons.scrollView(
                          context.t.exceptions.noTransactionFound,
                          onRetry: controller.pagingController.refresh,
                        );
                      },
                    );
                  },
                ),
                separatorBuilder: (c, i) {
                  return const SizedBox.square(dimension: 6);
                },
              ),
            ),
          ),
        ],
      ),
    ).unfocusPrimary();
  }
}
