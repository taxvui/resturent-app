import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

import '../../core/core.dart';

class ItemAttributeListTile extends StatelessWidget {
  const ItemAttributeListTile({
    super.key,
    required this.name,
    this.subtitle,
    this.leading,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: 16,
      vertical: 6,
    ),
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.putTrailingFirst = true,
    this.trailing,
  });
  final InlineSpan name;
  final InlineSpan? subtitle;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool putTrailingFirst;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: Divider.createBorderSide(context)),
        ),
        child: Row(
          children: [
            // Leading widget (e.g., avatar)
            if (leading != null) ...[
              leading!,
              const SizedBox.square(dimension: 12),
            ],

            // Item Name
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(name, style: _theme.textTheme.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox.square(dimension: 2),
                    Text.rich(
                      subtitle!,
                      style: _theme.textTheme.bodyMedium?.copyWith(
                        color: _theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (trailing != null && putTrailingFirst) trailing!,
            // Actions
            IconButton(
              onPressed: onEdit,
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(HugeIconsStroke.pencilEdit02),
              color: DAppColors.kSuccess,
            ),
            IconButton(
              onPressed: onDelete,
              visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(HugeIconsStroke.delete03),
              color: DAppColors.kError,
            ),

            if (trailing != null && !putTrailingFirst) trailing!,
          ],
        ),
      ),
    );
  }
}
