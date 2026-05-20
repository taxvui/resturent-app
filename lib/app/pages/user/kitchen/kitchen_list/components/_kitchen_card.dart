import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../../../../../i18n/strings.g.dart';
import '../../../../../core/core.dart';
import '../../../../../data/model/model.dart' as model;
import '../../../../../widgets/widgets.dart';

class KitchenCard extends StatelessWidget {
  const KitchenCard({
    super.key,
    required this.data,
    this.onStatusChanged,
    this.onManageItem,
    this.onDeleteItem,
    this.onEdit,
    this.onDelete,
  });
  final model.KitchenModel data;
  final ValueChanged<bool>? onStatusChanged;
  final VoidCallback? onManageItem;
  final ValueChanged<({int kitchenId, int itemId})>? onDeleteItem;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.fromBorderSide(Divider.createBorderSide(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: SizedBox.square(
                  dimension: 40,
                  child: UniversalImage(
                    data.image?.remote ?? DAppImages.emptyImagePlaceholder,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox.square(dimension: 12),

              Expanded(
                child: Column(
                  children: [
                    // Name & Status
                    DefaultTextStyle.merge(
                      style: _theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      child: Row(
                        children: [
                          // Name
                          Expanded(
                            child: Text(data.name ?? "N/A"),
                          ),

                          // Status
                          Text.rich(
                            TextSpan(
                              text: data.status ? context.t.common.active : context.t.common.inActive,
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: SizedBox.square(
                                    dimension: 20,
                                    child: Checkbox(
                                      value: data.status,
                                      onChanged: (value) => onStatusChanged?.call(value!),
                                      visualDensity: const VisualDensity(
                                        horizontal: VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity,
                                      ),
                                    ),
                                  ).fMarginOnly(left: 8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox.square(dimension: 4),

                    // Description & Total Items
                    DefaultTextStyle.merge(
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.paragraphColor,
                      ),
                      child: Row(
                        children: [
                          // Description
                          Expanded(
                            child: Text(data.description ?? "N/A"),
                          ),

                          // Item Count
                          Flexible(
                            flex: 0,
                            child: Text(
                              '${context.t.common.totalItems}: ${data.totalProducts.commaSeparated()}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox.square(dimension: 8),

          // Items
          Container(
            constraints: BoxConstraints.tight(Size.fromHeight(205)),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(Divider.createBorderSide(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Header
                DefaultTextStyle.merge(
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  child: Container(
                    color: DAppColors.kSurfaceLight,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(child: Text(context.t.pages.kitchen.card.itemName)),
                        InkWell(
                          onTap: onManageItem,
                          child: Text(
                            context.t.pages.kitchen.card.manageItems,
                            style: TextStyle(color: DAppColors.kSuccess),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Items
                if (data.products.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: RetryButtons.scrollView(
                        context.t.pages.kitchen.manageItems.noItemsAdded,
                        buttonText: context.t.common.add,
                        icon: const Icon(Icons.add),
                        onRetry: () => onManageItem?.call(),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.products.length,
                      itemBuilder: (_, index) {
                        final item = data.products[index];

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(bottom: Divider.createBorderSide(context)),
                          ),
                          child: Row(
                            spacing: 12,
                            children: [
                              Text((index + 1).commaSeparated()),

                              // Name
                              Expanded(
                                child: Text(item.productName ?? "N/A"),
                              ),

                              // Price
                              Flexible(
                                flex: 0,
                                child: Text(
                                  item.currentPrice.quickCurrency(),
                                  textAlign: TextAlign.end,
                                ),
                              ),

                              // Delete Action
                              IconButton(
                                onPressed: () {
                                  return onDeleteItem?.call((kitchenId: data.id!, itemId: item.id!));
                                },
                                style: IconButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                    horizontal: VisualDensity.minimumDensity,
                                    vertical: VisualDensity.minimumDensity,
                                  ),
                                  iconSize: 16,
                                  foregroundColor: DAppColors.kError,
                                ),
                                icon: const Icon(FeatherIcons.trash2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox.square(dimension: 14),

          // Actions
          Row(
            children: [
              // Delete
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: Divider.createBorderSide(context),
                    foregroundColor: _theme.paragraphColor,
                  ),
                  label: Text(context.t.common.delete),
                  icon: const Icon(FeatherIcons.trash2),
                ),
              ),
              const SizedBox.square(dimension: 16),

              // Edit Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  label: Text(context.t.common.edit),
                  icon: const Icon(FeatherIcons.edit3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
