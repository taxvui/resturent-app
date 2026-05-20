import 'package:fdevs_pops/fdevs_pops.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fdevs_fitkit/fdevs_fitkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/data/repository/repository.dart' as repo;
import 'firebase_options.dart';

import 'app/core/theme/theme.dart';
import 'app/routes/app_routes.dart';
import 'app/services/services.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (_, prefs, _, _) = await (
    AppLocaleService.initializePluralResolvers(),
    SharedPreferences.getInstance(),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ).wait;

  final httpClient = HTTPDioClient.initClient(prefs: prefs);
  final appLocaleService = AppLocaleService(prefs);
  await PushNotificationService.I.initNotification();

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          httpDioClientProvider.overrideWithValue(httpClient),
          appLocaleServiceProvider.overrideWithValue(appLocaleService),
        ],
        child: const AcnooApp(),
      ),
    ),
  );
}

class AcnooApp extends ConsumerStatefulWidget {
  const AcnooApp({super.key});

  @override
  ConsumerState<AcnooApp> createState() => _AcnooAppState();
}

class _AcnooAppState extends ConsumerState<AcnooApp> {
  late final routes = AppRoutes(ref);

  ValueKey<String> appKey = ValueKey(DateTime.now().toIso8601String());
  void _updateAppKey() {
    setState(() => appKey = ValueKey(DateTime.now().toIso8601String()));
  }

  @override
  void initState() {
    ref.read(repo.modulesProvider.future);
    currencyNotifier.addListener(_updateAppKey);
    ref.read(authStateListenerProvider).initListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appThemeProv = ref.watch(appThemeProvider);

    return FPops.init(
      rootNavigatorKey: routes.navigatorKey,
      child: DSizeUtils.init(
        context,
        builder: (context) => MaterialApp.router(
          key: appKey,
          themeMode: appThemeProv.themeMode,
          theme: DAppTheme.kLightTheme,
          routerConfig: routes.config(),

          // Locale Config
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}
