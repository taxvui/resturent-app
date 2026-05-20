import 'package:auto_route/auto_route.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:flutter/material.dart';
import 'package:universal_image/universal_image.dart';

import 'package:restaurant_pos/i18n/strings.g.dart';
import '../../core/core.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({
    super.key,
    this.title,
    required this.navigationTiles,
    this.onTap,
  });
  final Text? title;
  final List<NavDrawerTileItem> navigationTiles;
  final void Function(NavDrawerTileItem tile)? onTap;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Drawer(
        backgroundColor: _theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: _theme.colorScheme.primary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: _theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                boxShadow: [DAppBoxShadowStyles.boxShadow1],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 16),
                leading: SizedBox.square(
                  dimension: 32,
                  child: Image.asset(DAppImages.appIcon),
                ),
                horizontalTitleGap: 10,
                title: title,
                titleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                trailing: CloseButton(
                  onPressed: Scaffold.of(context).closeDrawer,
                ),
              ).fMarginOnly(bottom: 8, top: 24),
            ),
            const SizedBox.square(dimension: 8),

            // Navigation Routes
            Flexible(
              child: IconTheme(
                data: _theme.iconTheme.copyWith(size: 20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // Nav Items
                      ...List.generate(
                        navigationTiles.length,
                        (index) {
                          final _entry = navigationTiles[index];
                          if (_entry.tileType.isSubmenu) {
                            return ExpansionTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              clipBehavior: Clip.antiAlias,
                              leading: _getIcon(_entry.svgIconPath!),
                              title: Text(
                                _entry.title,
                                style: _theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              collapsedIconColor: _theme.colorScheme.secondary,
                              textColor: _theme.colorScheme.primary,
                              tilePadding: _tilePadding,
                              childrenPadding: const EdgeInsetsDirectional.only(
                                start: 40,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -2,
                              ),
                              children: [
                                ...?_entry.submenu?.map(
                                  (tile) => tile.build(onTap: onTap),
                                ),
                              ],
                            );
                          }

                          return _entry.build(
                            onTap: onTap,
                            isSelected:
                                _entry.tileType == NavDrawerTileType.bottomNav &&
                                _entry.bottomNavIndex == AutoTabsRouter.of(context).activeIndex,
                          );
                        },
                      ),
                      const SizedBox.square(dimension: 16),

                      // App Version
                      Text(
                        // 'Version: ${AppConfig.appVersion}',
                        context.t.common.version(version: AppConfig.appVersion),
                        style: _theme.textTheme.bodyLarge?.copyWith(
                          color: _theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsetsGeometry get _tilePadding => const EdgeInsets.symmetric(
    horizontal: 12,
  );

  Widget? _getIcon(String? iconPath) {
    if (iconPath == null) return null;
    return UniversalImage(iconPath);
  }
}

class NavDrawerTileItem {
  final String title;
  final String? svgIconPath;
  final PageRouteInfo<dynamic>? route;
  final NavDrawerTileType tileType;
  final int? bottomNavIndex;
  final List<NavDrawerTileItem>? submenu;

  const NavDrawerTileItem({
    required this.title,
    this.svgIconPath,
    this.route,
    this.tileType = NavDrawerTileType.route,
    this.bottomNavIndex,
    this.submenu,
  });

  Widget build({
    bool isSelected = false,
    ValueChanged<NavDrawerTileItem>? onTap,
  }) {
    return NavigationTileBuilder(
      tile: this,
      isSelected: isSelected,
      onTap: onTap,
      isSubmenu: tileType.isSubmenu,
    );
  }
}

enum NavDrawerTileType {
  bottomNav,
  route,
  submenu,
  action;

  bool get isSubmenu => this == NavDrawerTileType.submenu;
}

class NavigationTileBuilder extends StatelessWidget {
  const NavigationTileBuilder({
    super.key,
    this.onTap,
    required this.tile,
    this.isSelected = false,
    this.isSubmenu = false,
  });
  final ValueChanged<NavDrawerTileItem>? onTap;
  final NavDrawerTileItem tile;
  final bool isSubmenu;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        tileColor: isSelected ? _theme.colorScheme.secondary.withValues(alpha: 0.1) : null,
        onTap: () => onTap?.call(tile),
        leading: _getIcon(tile.svgIconPath),
        title: Text(tile.title),
        titleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: isSubmenu ? 14 : null,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        visualDensity: const VisualDensity(
          horizontal: -4,
          vertical: -2,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: _theme.colorScheme.secondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget? _getIcon(String? iconPath) {
    if (iconPath == null) return null;
    return UniversalImage(iconPath);
  }
}
