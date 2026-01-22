import 'dart:ui';

import 'package:flutter/material.dart';

class ThemeColors {
  final Color divider;
  final Color secondaryText;
  final Color primaryText;
  final Color accent;
  final Color textIcons;
  final Color primary;
  final Color lightPrimary;
  final Color darkPrimary;

  const ThemeColors({
    required this.divider,
    required this.secondaryText,
    required this.primaryText,
    required this.accent,
    required this.textIcons,
    required this.primary,
    required this.lightPrimary,
    required this.darkPrimary,
  });
}

ThemeData themeDataFromColors(ThemeColors colors) {
  return ThemeData(
    useMaterial3: true,

    primaryColor: colors.primary,
    primaryColorLight: colors.lightPrimary,
    primaryColorDark: colors.darkPrimary,

    dividerColor: colors.divider,
    hintColor: colors.accent,

    scaffoldBackgroundColor: Colors.white,

    textTheme: TextTheme(
      // Old bodyText1 → primary text
      bodyLarge: TextStyle(color: colors.primaryText),
      bodyMedium: TextStyle(color: colors.primaryText),

      // Old bodyText2 → secondary text
      bodySmall: TextStyle(color: colors.secondaryText),

      // Titles / headlines → primary text
      titleLarge: TextStyle(color: colors.primaryText),
      titleMedium: TextStyle(color: colors.primaryText),
      titleSmall: TextStyle(color: colors.secondaryText),

      headlineLarge: TextStyle(color: colors.primaryText),
      headlineMedium: TextStyle(color: colors.primaryText),
      headlineSmall: TextStyle(color: colors.primaryText),

      // Labels (buttons, inputs, captions)
      labelLarge: TextStyle(color: colors.textIcons),
      labelMedium: TextStyle(color: colors.secondaryText),
      labelSmall: TextStyle(color: colors.secondaryText),

      // Optional display styles
      displayLarge: TextStyle(color: colors.primaryText),
      displayMedium: TextStyle(color: colors.primaryText),
      displaySmall: TextStyle(color: colors.primaryText),
    ),

    iconTheme: IconThemeData(color: colors.textIcons),
  );
}



// Orange - BlueGray theme
const orangeBlueGrayTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),
  secondaryText: Color(0xFF757575),
  primaryText: Color(0xFF212121),
  accent: Color(0xFF607D8B),
  textIcons: Color(0xFFFFFFFF),
  primary: Color(0xFFFF5722),
  lightPrimary: Color(0xFFFFCCBC),
  darkPrimary: Color(0xFFE64A19),
);

// Teal - Blue theme
const tealBlueTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),
  secondaryText: Color(0xFF757575),
  primaryText: Color(0xFF212121),
  accent: Color(0xFF448AFF),
  textIcons: Color(0xFFFFFFFF),
  primary: Color(0xFF009688),
  lightPrimary: Color(0xFFB2DFDB),
  darkPrimary: Color(0xFF00796B),
);

// Amber - Red theme
const amberRedTheme = ThemeColors(
  divider: Color(0xFFBDBDBD),
  secondaryText: Color(0xFF757575),
  primaryText: Color(0xFF212121),
  accent: Color(0xFFFF5252),
  textIcons: Color(0xFF212121),
  primary: Color(0xFFFFC107),
  lightPrimary: Color(0xFFFFECB3),
  darkPrimary: Color(0xFFFFA000),
);
