import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../components/components.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

part '_party_list_view_provider.dart';

@RoutePage()
class PartyListView extends ConsumerWidget {
  const PartyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(partyListViewProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        for (final _tab in controller.notifiers) {
          _tab.initRefreshListener();
        }
      }
    });

    final _theme = Theme.of(context);

    return DefaultTabController(
      length: controller.notifiers.length,
      child: Builder(
        builder: (tabContext) {
          return Scaffold(
            appBar: CustomAppBar(
              // title: const Text('Parties List'),
              title: Text(context.t.pages.parties.title),
            ),
            body: Column(
              children: [
                ColoredBox(
                  color: _theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      ...[
                        // ("all_parties", "All Parties"),
                        ("all_parties", context.t.pages.parties.allParties),
                        // ("customer", "Customer"),
                        ("customer", context.t.pages.parties.customer),
                        // ("supplier", "Supplier"),
                        ("supplier", context.t.pages.parties.supplier),
                      ].map((entry) => Tab(text: entry.$2)),
                    ],
                  ),
                ),
                CustomSearchField(
                  controller: controller.searchController,
                  decoration: CustomSearchFieldDecoration(
                    // hintText: 'Search party name',
                    hintText: context.t.common.searchHere,
                  ),
                  onChanged: (_) => Future.delayed(Durations.medium3).whenComplete(() {
                    if (tabContext.mounted) {
                      return controller.notifiers[DefaultTabController.of(tabContext).index].pagingController.refresh();
                    }
                  }),
                ).fPaddingLTRB(16, 15, 16, 0),
                Expanded(
                  child: TabBarView(
                    children: List.generate(
                      controller.notifiers.length,
                      (tabIndex) {
                        final _tab = controller.notifiers[tabIndex];

                        return RefreshIndicator.adaptive(
                          onRefresh: () => Future.sync(controller.refreshAll),
                          child: PagedListView<int, Party>.separated(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            pagingController: _tab.pagingController,
                            builderDelegate: PagedChildBuilderDelegate<Party>(
                              itemBuilder: (c, party, i) {
                                final _partyType = PartyType.fromString(party.type);
                                final _tileData = PartyListTileData(
                                  partyName: party.name ?? 'N/A',
                                  amount: party.openingBalance ?? 0,
                                  partyType: _partyType,
                                  image: party.image,
                                );
                                return PartyListTile(
                                  data: _tileData,
                                  onTap: () async {
                                    return await context.router.push<void>(
                                      PartyDetailsRoute(partyId: party.id!),
                                    );
                                  },
                                  trailing: PopupMenuButton<String>(
                                    itemBuilder: (context) {
                                      return [
                                        if (ref.can(PMKeys.dueCollection))
                                          if (_partyType == PartyType.supplier && party.openingBalance != 0) ...[
                                            ("due", context.t.common.duePayment),
                                          ],
                                        ("view", context.t.common.view),
                                        if (ref.can(PMKeys.parties, action: PermissionAction.update)) ...[
                                          ("edit", context.t.common.edit),
                                        ],
                                        if (ref.can(PMKeys.parties, action: PermissionAction.delete)) ...[
                                          ("delete", context.t.common.delete),
                                        ],
                                      ].map((menu) {
                                        return PopupMenuItem<String>(
                                          value: menu.$1,
                                          child: Text(menu.$2),
                                        );
                                      }).toList();
                                    },
                                    onSelected: (v) async {
                                      return switch (v) {
                                        "due" => _handleDuePaymentNavigation(context, party),
                                        "view" => _handleDetailsNavigation(context, party.id!),
                                        "edit" => _handleEditNavigation(context, ref, party.id!),
                                        "delete" => _handleDelete(
                                          context,
                                          () => ref.read(partyRepoProvider).deleteParty(party.id!),
                                        ),
                                        _ => null,
                                      };
                                    },
                                    child: const Icon(Icons.more_vert),
                                  ),
                                );
                              },
                              noItemsFoundIndicatorBuilder: (context) {
                                return EmptyWidget(
                                  replaceDefault: false,
                                  emptyBuilder: (context) {
                                    return RetryButtons.scrollView(
                                      // 'No party found!\n Please try adding an party.',
                                      context.t.exceptions.noPartiesFound,
                                      onRetry: _tab.pagingController.refresh,
                                    );
                                  },
                                );
                              },
                            ),
                            separatorBuilder: (c, i) {
                              return const SizedBox.square(dimension: 6);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: SizedBox(
              height: 48,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  if (ref.canSnackbar(context, PMKeys.parties, action: PermissionAction.create)) {
                    return await context.router.push<void>(
                      ManagePartyRoute(),
                    );
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                // label: const Text('+ Add Parties'),
                label: Text('+ ${context.t.pages.parties.addParties}'),
              ),
            ).can(PMKeys.parties, action: PermissionAction.create),
          );
        },
      ),
    ).unfocusPrimary();
  }

  Future<void> _handleEditNavigation(BuildContext context, WidgetRef ref, int partyId) async {
    try {
      final _partyDetails = await showAsyncLoadingOverlay(
        context,
        asyncFunction: () => Future.microtask(
          () => ref.read(partyDetailsProvider(partyId).future),
        ),
      );

      if (context.mounted && _partyDetails.data != null) {
        return await context.router.push<void>(
          ManagePartyRoute(
            editModel: _partyDetails.data,
          ),
        );
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

  Future<void> _handleDetailsNavigation(BuildContext context, int partyId) async {
    return await context.router.push<void>(
      PartyDetailsRoute(partyId: partyId),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback,
  ) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Do you want to delete this party?',
        title: context.t.exceptions.doYouWantToDeleteThisParty,
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

  Future<void> _handleDuePaymentNavigation(BuildContext context, Party party) async {
    return await context.router.push<void>(
      ManageDueCollectionRoute(
        collection: DueCollection(
          partyId: party.id,
          party: party,
          dueAmountAfterPay: party.openingBalance,
        ),
      ),
    );
  }
}
