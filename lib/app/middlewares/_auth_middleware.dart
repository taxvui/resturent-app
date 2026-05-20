import 'package:auto_route/auto_route.dart';

import '../data/repository/repository.dart';
import '../routes/app_routes.gr.dart';

class AuthGuard extends AutoRouteGuard {
  const AuthGuard(this.ref);
  final WidgetRef ref;

  @override
  Future<void> onNavigation(resolver, router) async {
    final _prefs = ref.read(sharedPrefsProvider);
    final _hasLanguage = _prefs.getString(DAppSPrefsKeys.savedLocale) != null;
    final _firstTour = _prefs.getBool(DAppSPrefsKeys.firstTour) ?? true;

    if (!_hasLanguage) {
      resolver.redirectUntil(LanguageRoute(), replace: true);
      return;
    }

    if (_firstTour) {
      resolver.redirectUntil(OnboardRoute(), replace: true);
      return;
    }

    final userState = await ref.read(userRepositoryProvider.future);

    if (userState == null) {
      resolver.redirectUntil(SignInRoute(), replace: true);
      return;
    }

    if (userState.business == null) {
      resolver.redirectUntil(SetupProfileRoute(), replace: true);
      return;
    }

    if (userState.role?.isKitchenOrChef == true) {
      return router.replacePath<void>('/user-panel/chef-bottom-nav');
    }

    return router.replacePath<void>('/user-panel/bottom-nav');
  }
}
