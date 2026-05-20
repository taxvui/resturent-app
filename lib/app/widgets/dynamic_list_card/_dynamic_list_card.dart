import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';

import '../key_value_row/key_value_row.dart';

class DynamicListCard extends StatelessWidget {
  const DynamicListCard._({
    super.key,
    required this.showHeader,
    required this.applyDividerPadding,
    this.title,
    this.subtitle,
    this.headerLeading,
    this.headerTrailing,
    this.children,
    this.onTap,
    this.actionButtonText,
    required this.showAction,
    this.onActionTap,
  });

  // Header Section
  final bool showHeader;
  final bool applyDividerPadding;
  final String? title;
  final String? subtitle;
  final Widget? headerLeading;
  final Widget? headerTrailing;

  // Body
  final List<Widget>? children;
  final void Function()? onTap;

  // Action Button
  final String? actionButtonText;
  final bool showAction;
  final void Function()? onActionTap;

  const DynamicListCard.keyValueBody({
    Key? key,
    // Header Section
    bool showHeader = true,
    bool applyDividerPadding = true,
    String? title,
    String? subtitle,
    Widget? headerLeading,
    Widget? headerTrailing,
    required List<KeyValueRow> keyValues,
    void Function()? onTap,
    String? actionButtonText,
    bool showAction = true,
    void Function()? onActionTap,
  }) : this._(
          key: key,
          showHeader: showHeader,
          applyDividerPadding: applyDividerPadding,
          title: title,
          subtitle: subtitle,
          headerLeading: headerLeading,
          headerTrailing: headerTrailing,
          children: keyValues,
          onTap: onTap,
          actionButtonText: actionButtonText,
          showAction: showAction,
          onActionTap: onActionTap,
        );

  const DynamicListCard.custom({
    Key? key,
    // Header Section
    bool showHeader = true,
    bool applyDividerPadding = true,
    String? title,
    String? subtitle,
    Widget? headerLeading,
    Widget? headerTrailing,
    required List<Widget> children,
    void Function()? onTap,
    String? actionButtonText,
    bool showAction = true,
    void Function()? onActionTap,
  }) : this._(
          key: key,
          showHeader: showHeader,
          applyDividerPadding: applyDividerPadding,
          title: title,
          subtitle: subtitle,
          headerLeading: headerLeading,
          headerTrailing: headerTrailing,
          children: children,
          onTap: onTap,
          actionButtonText: actionButtonText,
          showAction: showAction,
          onActionTap: onActionTap,
        );

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    const _horizontalPadding = 16.0;
    final _dividerIntent = applyDividerPadding ? _horizontalPadding : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _theme.colorScheme.primaryContainer,
          border: Border.all(
            color: _theme.colorScheme.secondary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (showHeader) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                leading: headerLeading,
                title: Text(
                  title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                titleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                subtitle: Text(
                  subtitle ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitleTextStyle: _theme.textTheme.bodyMedium?.copyWith(
                  color: _theme.colorScheme.secondary,
                ),
                trailing: headerTrailing,
                titleAlignment: ListTileTitleAlignment.top,
              ).fMarginLTRB(_horizontalPadding, 8, _horizontalPadding, 0),
              Divider(
                height: 0,
                endIndent: _dividerIntent,
                indent: _dividerIntent,
              ),
            ],
            const SizedBox.square(dimension: 8),

            // Body
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...?children,
                const SizedBox.square(dimension: 16),

                // Action Button
                if (showAction) ...[
                  SizedBox.fromSize(
                    size: const Size.fromHeight(45),
                    child: OutlinedButton(
                      onPressed: onActionTap,
                      child: Text(actionButtonText ?? "Action"),
                    ),
                  ),
                  const SizedBox.square(dimension: 16)
                ],
              ],
            ).fMarginSymmetric(horizontal: _horizontalPadding),
          ],
        ),
      ),
    );
  }
}
