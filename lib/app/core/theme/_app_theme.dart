import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_app_colors.dart';

abstract class DAppTheme {
  static final _baseLight = ThemeData.light();
  static final kLightTheme = _baseLight.copyWith(
    appBarTheme: _appBarTheme,
    textTheme: _textTheme(_baseLight.textTheme),
    scaffoldBackgroundColor: DAppColors.kPrimaryContainerLight,
    colorScheme: const ColorScheme.light(
      surface: DAppColors.kSurfaceLight,
      onSurface: DAppColors.kOnSurfaceLight,

      //
      primary: DAppColors.kPrimary,
      onPrimary: DAppColors.kOnPrimary,

      //
      secondary: DAppColors.kSecondary,
      onSecondary: DAppColors.kOnSecondary,

      //
      primaryContainer: DAppColors.kPrimaryContainerLight,
      onPrimaryContainer: DAppColors.kOnPrimaryContainerLight,

      outline: DAppColors.kBorder,
    ),

    // Buttons
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    floatingActionButtonTheme: floatingActionButtonThemeData,

    checkboxTheme: _checkboxTheme(DAppColors.kBorder),
    radioTheme: _radioThemeData,

    // Input Decoration
    inputDecorationTheme: _inputDecorationTheme(DAppColors.kBorder),

    // Tabbar Theme
    tabBarTheme: _tabBarTheme(
      dividerColor: DAppColors.kBorder.withValues(alpha: 0.20),
    ),

    // Divider Theme
    dividerTheme: _dividerTheme(DAppColors.kBorder.withValues(alpha: 0.25)),

    // Dropdown Theme
    canvasColor: DAppColors.kPrimaryContainerLight,
    dropdownMenuTheme: dropdownThemeData,

    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    ),
  );

  // static final _baseDark = ThemeData.dark();
  static final kDarkTheme = _baseLight;

  // Common AppBar Theme
  static const _appBarTheme = AppBarTheme(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: DAppColors.kPrimary,
    foregroundColor: DAppColors.kOnPrimary,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
  );

  // Common Text Theme
  static TextTheme _textTheme(TextTheme baseTheme) {
    return baseTheme.apply(fontFamily: 'Poppins');
  }

  // Common Elevated Button Theme
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: DAppColors.kOnPrimary,
      backgroundColor: DAppColors.kPrimary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      minimumSize: const Size.fromHeight(48),
    ),
  );

  // Common Elevated Button Theme
  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: DAppColors.kPrimary),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );

  // Common Filled Button Theme
  static final _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: DAppColors.kOnPrimary,
      backgroundColor: DAppColors.kPrimary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      minimumSize: const Size.fromHeight(48),
    ),
  );

  // Common Checkbox Theme
  static CheckboxThemeData _checkboxTheme([
    Color borderColor = const Color(0xFF000000),
  ]) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: BorderSide(
        color: borderColor,
        width: 1.5,
      ),
      visualDensity: const VisualDensity(
        horizontal: -4,
        vertical: -4,
      ),
    );
  }

  // Common Radio Theme
  static const RadioThemeData _radioThemeData = RadioThemeData();

  // Common Input Decoration Theme
  static InputDecorationTheme _inputDecorationTheme([
    Color enabledBorder = Colors.grey,
  ]) {
    final _border = OutlineInputBorder(
      borderSide: BorderSide(
        color: enabledBorder.withValues(alpha: 0.30),
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );
    const _errorBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
      ),
    );

    return InputDecorationTheme(
      border: _border,
      enabledBorder: _border,
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintStyle: TextStyle(color: enabledBorder),
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      errorStyle: const TextStyle(color: Colors.red),
      floatingLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  // Common Tabbar Theme
  static TabBarThemeData _tabBarTheme({Color? dividerColor}) {
    return TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: dividerColor,
      tabAlignment: TabAlignment.start,
      labelStyle: const TextStyle(
        color: DAppColors.kPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        color: DAppColors.kSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Common Divider Theme
  static DividerThemeData _dividerTheme([Color color = Colors.grey]) {
    return DividerThemeData(color: color);
  }

  // Common FAB Theme
  static const floatingActionButtonThemeData = FloatingActionButtonThemeData(
    backgroundColor: DAppColors.kPrimary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  );

  // Common Dropdown Theme
  static final dropdownThemeData = DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all<Color>(DAppColors.kOnPrimary),
      surfaceTintColor: WidgetStateProperty.all<Color>(DAppColors.kOnPrimary),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
    ),
  );
}

extension $ThemeDataExt on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get paragraphColor {
    return isDark ? DAppColors.kExtraColors.paragraphDark : DAppColors.kExtraColors.paragraphLight;
  }
}
