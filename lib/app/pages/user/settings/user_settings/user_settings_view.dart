import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../core/core.dart';
import '../../../../data/repository/repository.dart';
import '../../../../widgets/widgets.dart';
import '../../../../routes/app_routes.gr.dart';
import '../../../common/widgets/widgets.dart';

@RoutePage()
class UserSettingsView extends ConsumerWidget {
  const UserSettingsView({super.key, this.scaffoldKey});
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userRepositoryProvider).value;
    final _theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: scaffoldKey,
        title: Text(context.t.common.profile),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => Future.wait([
          ref.read(userRepositoryProvider.notifier).getUser(),
          ref.refresh(modulesProvider.future),
        ]),
        child: PageNavigationListView(
          header: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: _theme.colorScheme.primaryContainer,
            child: Column(
              children: [
                // Profile Image
                SizedBox.square(
                  dimension: 72,
                  child: UserAvatarPicker(
                    image: user?.currentUser?.image,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox.square(dimension: 8),

                // Title
                Text(
                  user?.currentUser?.title ?? 'N/A',
                  style: _theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),

                // Subtitle
                Text(
                  user?.currentUser?.subtitle ?? "N/A",
                  style: _theme.textTheme.bodyLarge?.copyWith(
                    color: _theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          navTiles: [
            // User Profile
            PageNavigationNavTile(
              title: context.t.common.myProfile,
              svgIconPath: DAppSvgNavIcons.myProfile,
              route: EditProfileRoute(),
            ),

            // Printing Option
            if (ref.can(PMKeys.printingOption))
              PageNavigationNavTile(
                title: context.t.common.printingOption,
                svgIconPath: DAppSvgNavIcons.printingOption,
                route: const PrintingOptionRoute(),
              ),

            // Language
            PageNavigationNavTile(
              title: context.t.common.language,
              svgIconPath: DAppSvgNavIcons.language,
              route: LanguageRoute(getBack: true),
            ),

            // Currency
            if (ref.can(PMKeys.currency))
              PageNavigationNavTile(
                title: context.t.common.currency,
                svgIconPath: DAppSvgNavIcons.currency,
                route: const CurrencyRoute(),
              ),

            // Business Payment Method
            if (ref.can(PMKeys.paymentMethod))
              PageNavigationNavTile(
                title: context.t.common.paymentMethod,
                svgIconPath: DAppSvgNavIcons.paymentMethod,
                route: const BusinessPaymentMethodListRoute(),
              ),

            // User Role Permission
            if (ref.can(PMKeys.userRolePermission))
              PageNavigationNavTile(
                title: context.t.common.roleNPermission,
                svgIconPath: DAppSvgNavIcons.rolesPermissions,
                route: const UserRolePermissionListRoute(),
              ),

            // Rate Us
            PageNavigationNavTile(
              title: context.t.common.rateUs,
              svgIconPath: DAppSvgNavIcons.rateUs,
            ),

            // Terms & Condition
            PageNavigationNavTile(
              title: context.t.common.termsAndConditions,
              svgIconPath: DAppSvgNavIcons.termsConditions,
              route: const TermsConditionsRoute(),
            ),

            // Privacy & Policy
            PageNavigationNavTile(
              title: context.t.pages.privacyPolicy.title,
              svgIconPath: DAppSvgNavIcons.privacyPolicy,
              route: const PrivacyNPolicyRoute(),
            ),

            // About Us
            PageNavigationNavTile(
              title: context.t.pages.aboutUs.title,
              svgIconPath: DAppSvgNavIcons.aboutUs,
              route: const AboutUsRoute(),
            ),

            // Logout
            PageNavigationNavTile<String>(
              title: context.t.common.logout,
              svgIconPath: DAppSvgNavIcons.logOut,
              type: PageNavigationListTileType.function,
              value: 'log-out',
            ),
          ],
          onTap: (value) async {
            if (value.type == PageNavigationListTileType.navigation && value.route != null) {
              await context.router.push(value.route!);
            } else if (value.type == PageNavigationListTileType.function) {
              return await SharedWidgets.handleSignOut(context);
            }
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
