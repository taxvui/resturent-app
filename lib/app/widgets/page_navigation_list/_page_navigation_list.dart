import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import '../../core/core.dart' show SvgImageHolder;

class PageNavigationListView extends StatelessWidget {
  const PageNavigationListView({
    super.key,
    this.header,
    required this.navTiles,
    this.onTap,
  });

  final Widget? header;
  final List<PageNavigationNavTile> navTiles;
  final void Function(PageNavigationNavTile value)? onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Header
        ?header,

        // Nav Items
        Column(children: navTiles.map((tile) => _buildTile(context, tile)).toList()),
      ],
    );
  }

  Widget _buildTile(BuildContext context, PageNavigationNavTile tile) {
    final _theme = Theme.of(context);

    final _leading = tile.svgIconPath == null
        ? null
        : Container(
            constraints: BoxConstraints.tight(
              const Size.square(38),
            ),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: tile.svgIconPath?.baseColor?.withValues(
                alpha: 0.15,
              ),
            ),
            child: UniversalImage(tile.svgIconPath!.svgPath),
          );

    final _titleWidget = Text(tile.title, style: _theme.textTheme.bodyLarge);

    if (tile.submenus.isNotEmpty) {
      return ExpansionTile(
        leading: _leading,
        title: _titleWidget,
        tilePadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsetsDirectional.only(
          start: 56,
        ),
        shape: const RoundedRectangleBorder(),
        collapsedShape: BorderDirectional(bottom: Divider.createBorderSide(context)),
        backgroundColor: _theme.colorScheme.primaryContainer,
        collapsedBackgroundColor: _theme.colorScheme.primaryContainer,
        visualDensity: const VisualDensity(vertical: -2),
        collapsedIconColor: _theme.colorScheme.outline,
        children: tile.submenus.map((submenu) => _buildTile(context, submenu)).toList(),
      );
    }

    final _trailing = switch (tile.type) {
      PageNavigationListTileType.tool => tile.trailing,
      _ => Icon(Icons.arrow_forward_ios, size: 16, color: _theme.colorScheme.outline),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: ListTile(
        onTap: () => onTap?.call(tile),
        leading: _leading,
        title: _titleWidget,
        titleTextStyle: _theme.textTheme.bodyLarge,
        trailing: _trailing,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        tileColor: _theme.colorScheme.primaryContainer,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        visualDensity: const VisualDensity(vertical: -2),
      ),
    );
  }
}

class PageNavigationNavTile<T> {
  final String title;
  final Widget? trailing;
  final Color? color;
  final SvgImageHolder? svgIconPath;
  final PageNavigationListTileType type;
  final PageRouteInfo<dynamic>? route;
  final T? value;
  final List<PageNavigationNavTile<T>> submenus;

  const PageNavigationNavTile({
    required this.title,
    this.trailing,
    this.color,
    this.svgIconPath,
    this.type = PageNavigationListTileType.navigation,
    this.route,
    this.value,
    this.submenus = const [],
  }) : assert(
         type != PageNavigationListTileType.navigation || value == null,
         'value cannot be assigned in navigation type',
       );
}

enum PageNavigationListTileType { navigation, tool, function }
