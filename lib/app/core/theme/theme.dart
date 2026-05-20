import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/services.dart';

export '_app_colors.dart';
export '_app_theme.dart';

class AppThemeNotifier extends ChangeNotifier {
  AppThemeNotifier._(this.ref);
  final Ref ref;

  static AppThemeNotifier? _instance;
  factory AppThemeNotifier.init(Ref ref) {
    _instance ??= AppThemeNotifier._(ref);
    _instance!._getSavedTheme();
    return _instance!;
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkTheme => _themeMode == ThemeMode.dark;
  void toggleTheme(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  late SharedPreferences prefs;
  Future<void> _getSavedTheme() async {
    prefs = ref.read(sharedPrefsProvider);
    _themeMode = ThemeMode.values.byName(
      prefs.getString('theme_mode') ?? 'system',
    );
    notifyListeners();
  }
}

final appThemeProvider = ChangeNotifierProvider(
  (ref) => AppThemeNotifier.init(ref),
);
