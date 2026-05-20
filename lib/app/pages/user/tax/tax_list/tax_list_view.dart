import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import 'components/components.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../../data/repository/repository.dart';

@RoutePage()
class TaxListView extends ConsumerStatefulWidget {
  const TaxListView({super.key});

  @override
  ConsumerState<TaxListView> createState() => _TaxListViewState();
}

class _TaxListViewState extends ConsumerState<TaxListView> {
  late final taxRateScrollController = ScrollController();
  late final taxGroupScrollController = ScrollController();

  @override
  void initState() {
    initRefreshListener();
    super.initState();
  }

  @override
  void dispose() {
    _apiEventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _taxList = ref.watch(taxListProvider);
    final _taxGroup = ref.watch(taxGroupProvider);

    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: Text(context.t.pages.tax.title)),
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.wait([
            ref.refresh(taxListProvider.future),
            ref.refresh(taxGroupProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Tax rates
              _buildHeader(
                _theme,
                title: context.t.pages.tax.buildHeaderTitle,
                onTap: () async {
                  return await context.router.push<void>(ManageTaxRoute());
                },
              ).fMarginLTRB(16, 16, 16, 12),

              // Data Table
              _taxList.when(
                data: (data) {
                  final _taxes = [...?data.data];

                  return RawScrollbar(
                    controller: taxRateScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: taxRateScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Skeletonizer(
                        enabled: _taxList.isLoading,
                        child: TaxRatesDataTable(
                          data: TaxRatesTableData(
                            headers: [
                              TextSpan(text: context.t.common.name),
                              TextSpan(text: context.t.common.vatRate),
                              TextSpan(text: context.t.common.status),
                              TextSpan(text: context.t.common.action),
                            ],
                            rows: List.generate(_taxes.length, (rowI) {
                              final _tax = _taxes[rowI];

                              return [
                                TextSpan(text: _tax.name ?? 'N/A'),
                                TextSpan(
                                  text: _tax.rate?.commaSeparated() ?? 'N/A',
                                ),
                                TextSpan(
                                  text: _tax.isVatOnSales == true
                                      ? 'On Sale'
                                      : _tax.status == true
                                      ? context.t.common.active
                                      : context.t.common.inActive,
                                ),
                                TaxRatesDataTable.defaultActions(
                                  onEdit: () async {
                                    return await context.router.push<void>(
                                      ManageTaxRoute(editModel: _tax),
                                    );
                                  },
                                  onDelete: () async {
                                    return _handleDelete(
                                      context,
                                      () => ref.read(taxRepoProvider).deleteTax(_tax.id!),
                                      isVATOnSales: _tax.isVatOnSales == true,
                                    );
                                  },
                                ),
                              ];
                            }),
                          ),
                        ),
                      ),
                    ).fMarginOnly(bottom: 5),
                  );
                },
                error: (error, _) {
                  return Text(error.toString()).fMarginSymmetric(
                    horizontal: 16,
                  );
                },
                loading: _buildLoadingShimmer,
              ),

              // VAT Group
              _buildHeader(
                _theme,
                title: context.t.pages.tax.vatGroup.title,
                subtitle: context.t.pages.tax.vatGroup.subTitle,
                onTap: () async {
                  return await context.router.push<void>(ManageTaxGroupRoute());
                },
              ).fMarginLTRB(16, 20, 16, 12),

              // Data Table
              _taxGroup.when(
                skipLoadingOnRefresh: false,
                data: (data) {
                  final _groupList = [...?data.data];
                  return RawScrollbar(
                    controller: taxGroupScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: taxGroupScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Skeletonizer(
                        enabled: _taxGroup.isLoading,
                        child: TaxRatesDataTable(
                          data: TaxRatesTableData(
                            headers: [
                              TextSpan(text: context.t.common.name),
                              TextSpan(text: context.t.common.vatRate),
                              TextSpan(text: context.t.common.subVats),
                              TextSpan(text: context.t.common.action),
                            ],
                            rows: List.generate(_groupList.length, (rowI) {
                              final _group = _groupList[rowI];
                              return [
                                TextSpan(text: _group.name ?? 'N/A'),
                                TextSpan(
                                  text: _group.rate?.commaSeparated() ?? 'N/A',
                                ),
                                TextSpan(
                                  text: _group.subTax
                                      ?.map(
                                        (e) {
                                          return '${e.name ?? 'N/A'} ${e.rate?.commaSeparated() ?? 'N/A'}%';
                                        },
                                      )
                                      .join(', '),
                                  children: [
                                    if (_group.isVatOnSales == true) TextSpan(text: ' (On Sale) '),
                                  ],
                                ),
                                TaxRatesDataTable.defaultActions(
                                  onEdit: () async {
                                    return await context.router.push<void>(
                                      ManageTaxGroupRoute(editModel: _group),
                                    );
                                  },
                                  onDelete: () async {
                                    return _handleDelete(
                                      context,
                                      () => ref.read(taxRepoProvider).deleteTax(_group.id!),
                                      isGroup: true,
                                    );
                                  },
                                ),
                              ];
                            }),
                          ),
                        ),
                      ),
                    ).fMarginOnly(bottom: 5),
                  );
                },
                error: (error, stackTrace) {
                  return Text(error.toString()).fMarginSymmetric(
                    horizontal: 16,
                  );
                },
                loading: _buildLoadingShimmer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.zero,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      titleTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      subtitle: subtitle != null ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.secondary,
      ),
      trailing: IntrinsicWidth(
        child: ElevatedButton(
          onPressed: ref.canT(PMKeys.vat, action: PermissionAction.create, input: onTap),
          style: ElevatedButton.styleFrom(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text('+ ${context.t.common.add}'),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Skeletonizer(
      child: TaxRatesDataTable(
        data: TaxRatesTableData(
          headers: [
            TextSpan(text: context.t.common.name),
            TextSpan(text: context.t.common.taxRate),
            TextSpan(text: context.t.common.subTaxes),
            TextSpan(text: context.t.common.action),
          ],
          rows: List.generate(3, (rowI) {
            return [
              TextSpan(text: 'demo'),
              TextSpan(text: 'demo'),
              TextSpan(text: 'demo'),
              TextSpan(text: 'demo'),
            ];
          }),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Future<Either<String, String>> Function() callback, {
    bool isGroup = false,
    bool isVATOnSales = false,
  }) async {
    final _confirmation = await showDialog(
      context: context,
      builder: (popContext) => InfoDialog.confirmation(
        // title: 'Are you sure you want to delete this ${isGroup ? 'group' : 'VAT'}?',
        title: context.t.exceptions.areYouSureYouSureWantToDeleteThisTaxType(
          taxType: isGroup ? context.t.common.group : context.t.common.VAT,
        ),
        description: isVATOnSales ? context.t.exceptions.thisVatIsBeingUsedOnSales : null,
        onDecide: Navigator.of(popContext).pop,
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

  EventSub<TaxApiEvent>? _apiEventSub;
  void initRefreshListener() {
    _apiEventSub = GlobalEventManager.I.on<TaxApiEvent>().listen((_) {
      ref.invalidate(taxListProvider);
      ref.invalidate(taxGroupProvider);
    });
  }
}
