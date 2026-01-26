import 'dart:ui';

import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
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



const cardsConst = [
  CardModel(
    name: "Percentage",
    createdOn: 1704067100,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Amount", type: "number"),
      FieldModel(sym: "Percent", type: "number"),
    ],
    formulas: [
      FormulaModel(pos: 0, sym: "res", expression: "Amount*(100+Percent)/100")
    ],
    output: "res",
  ),
  CardModel(
    name: "Simple Interest",
    createdOn: 1704067200,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Amount", type: "number"),
      FieldModel(sym: "Percent", type: "number"),
      FieldModel(sym: "FromYear", type: "number"),
      FieldModel(sym: "FromMonth", type: "number"),
      FieldModel(sym: "FromDay", type: "number"),
      FieldModel(sym: "ToYear", type: "number"),
      FieldModel(sym: "ToMonth", type: "number"),
      FieldModel(sym: "ToDay", type: "number"),
    ],
    formulas: [

      FormulaModel(pos: 0, sym: "From", expression: "FromYear*365+FromMonth*30+FromDay"),
      FormulaModel(pos: 1, sym: "To", expression: "ToYear*365+ToMonth*30+ToDay"),
      FormulaModel(pos: 2, sym: "res", expression: "Amount+Amount*(Percent/100)*((To - From) / 365)")
    ],
    output: "res",
  ),
  
  
  CardModel(
    name: "Amount",
    createdOn: 1704067300,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Amount", type: "number"),
    ],
    formulas: [
      FormulaModel(pos: 0, sym: "res", expression: "Amount")
    ],
    output: "res",
  ),
  CardModel(
    name: "inch - cm",
    createdOn: 1704067400,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Inch", type: "number"),
    ],
    formulas: [
      FormulaModel(pos: 0, sym: "res", expression: "Inch*2.54")
    ],
    output: "res",
  ),
  CardModel(
    name: "cm - inch",
    createdOn: 1704067500,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Cm", type: "number"),
    ],
    formulas: [
      FormulaModel(pos: 0, sym: "res", expression: "Cm/2.54")
    ],
    output: "res",
  ),
  CardModel(
    name: "Compound Interest Monthly",
    createdOn: 1704067600,
    isFavourite: false,
    fields: [
      FieldModel(sym: "Amount", type: "number"),
      FieldModel(sym: "Percent", type: "number"),
      FieldModel(sym: "FromYear", type: "number"),
      FieldModel(sym: "FromMonth", type: "number"),
      FieldModel(sym: "ToYear", type: "number"),
      FieldModel(sym: "ToMonth", type: "number"),
    ],
    formulas: [

      FormulaModel(pos: 0, sym: "Months", expression: "(ToYear-FromYear)*12+(ToMonth-FromMonth)"),
      FormulaModel(pos: 1, sym: "res", expression: "Amount*(1+(Percent/100)/12)^Months")
    ],
    output: "res",
  ),
];