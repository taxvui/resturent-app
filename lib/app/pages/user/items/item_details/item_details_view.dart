import 'package:auto_route/auto_route.dart';
import 'package:expansion_widget/expansion_widget.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';

@RoutePage()
class ItemDetailsView extends ConsumerStatefulWidget {
  const ItemDetailsView({super.key, required this.itemId});
  final int itemId;
  @override
  ConsumerState<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends ConsumerState<ItemDetailsView> {
  late final imagePageController = PageController();

  @override
  Widget build(BuildContext context) {
    final itemDetailsAsync = ref.watch(itemDetailsProvider(widget.itemId));
    final itemDetails = itemDetailsAsync.value?.data;
    final images = [
      ...?itemDetails?.images?.map((image) => image.remote),
    ];
    final _itemType = ItemTypeEnum.fromString(itemDetails?.priceType);

    final _theme = Theme.of(context);

    final _sectionHeader = _theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      backgroundColor: _theme.colorScheme.primaryContainer,
      appBar: CustomAppBar(
        title: Text(context.t.pages.items.itemDetails.title),
        actions: [
          PermissionGate(
            moduleKey: PMKeys.products,
            action: PermissionAction.update,
            child: Skeletonizer(
              enabled: itemDetailsAsync.isLoading,
              child: TextButton.icon(
                onPressed: itemDetailsAsync.hasError ? null : () => _handleEditRoute(context, itemDetails!),
                icon: const Icon(IconlyBold.edit, size: 16),
                // label: const Text("Edit"),
                label: Text(context.t.common.edit),
                style: TextButton.styleFrom(
                  visualDensity: const VisualDensity(vertical: -2),
                  foregroundColor: _theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(itemDetailsProvider(widget.itemId).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              Skeletonizer(
                enabled: itemDetailsAsync.isLoading,
                child: ColoredBox(
                  color: _theme.scaffoldBackgroundColor,
                  child: SizedBox.fromSize(
                    size: const Size.fromHeight(210),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: PageView.builder(
                            controller: imagePageController,
                            itemCount: images.isEmpty ? 1 : images.length,
                            itemBuilder: (_, index) {
                              if (images.isEmpty) {
                                return Center(
                                  child: Text(context.t.pages.items.itemDetails.extra.noImageAvailable),
                                );
                              }
                              return CustomNetworkImage(
                                url: images[index],
                                fit: BoxFit.fitHeight,
                              );
                            },
                          ),
                        ),

                        // Page Indicator
                        if (images.isNotEmpty)
                          Container(
                            alignment: AlignmentDirectional.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SmoothPageIndicator(
                              controller: imagePageController,
                              count: images.length,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 12,
                                expansionFactor: 1.75,
                                dotColor: const Color(0xffFEE6D1),
                                activeDotColor: _theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Skeletonizer(
                enabled: itemDetailsAsync.isLoading,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      itemDetails?.productName ?? "N/A",
                      style: _theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox.square(dimension: 2),

                    if (!_itemType.isVariation) ...[
                      // Item Price
                      Text(
                        itemDetails?.salesPrice?.quickCurrency() ?? "N/A",
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox.square(dimension: 2),
                    ],

                    // Item Category & Food Type
                    Text(
                      '${ItemFoodTypeEnum.fromString(itemDetails?.foodType).label(context)} - ${itemDetails?.category?.categoryName ?? ''}',
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _theme.paragraphColor,
                      ),
                    ),
                    const SizedBox.square(dimension: 8),

                    // Menu
                    Text(
                      itemDetails?.menu?.name ?? "N/A",
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        color: _theme.paragraphColor,
                      ),
                    ),

                    // Preparation Time
                    Text.rich(
                      TextSpan(
                        text: 'Preparation Time: ',
                        children: [
                          TextSpan(
                            text: '${itemDetails?.preparationTime ?? '0'}mins',
                            style: TextStyle(
                              color: _theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _theme.paragraphColor,
                      ),
                    ),

                    // Description
                    if (itemDetails?.description != null) ...[
                      const SizedBox.square(dimension: 10),
                      ReadMore2(
                        itemDetails!.description!,
                        textStyle: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.paragraphColor,
                        ),
                      ),
                    ],
                    const Divider(),

                    if (_itemType.isVariation) ...[
                      // Item Variations
                      Text('Variations', style: _sectionHeader),
                      const SizedBox.square(dimension: 10),
                      ...?itemDetails?.variations?.map((variation) {
                        return _buildRow(
                          context,
                          label: variation.name ?? "N/A",
                          value: variation.price?.quickCurrency() ?? "N/A",
                        ).fMarginOnly(bottom: 8);
                      }),
                      const SizedBox.square(dimension: 10),
                    ],

                    // Modifier Options
                    ...?itemDetails?.modifiers?.map((modifier) {
                      return ExpansionWidget.autoSaveState(
                        initiallyExpanded: true,
                        titleBuilder: (av, ev, ie, tf) {
                          return InkWell(
                            onTap: () => tf(animated: true),
                            child: Row(
                              children: [
                                Icon(
                                  ie ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                  size: 20,
                                  color: _theme.colorScheme.primary,
                                ),
                                const SizedBox.square(dimension: 8),
                                Text(
                                  modifier.modifierGroup?.name ?? "N/A",
                                  style: _theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        expandedAlignment: Alignment.centerLeft,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox.square(dimension: 8),
                            ...?modifier.modifierGroup?.options?.map((option) {
                              return _buildRow(
                                context,
                                label: option.name ?? "N/A",
                                value: option.price?.quickCurrency() ?? "N/A",
                              ).fPaddingOnly(bottom: 8);
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ).fMarginLTRB(16, 6, 16, 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final _theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: _theme.textTheme.bodyLarge?.copyWith(
              color: _theme.paragraphColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: _theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEditRoute(BuildContext context, PItem data) async {
    return await context.router.push<void>(
      ManageItemRoute(editModel: data),
    );
  }
}
