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
    name: "Interest - Calculation",
    createdOn: 1704067200,
    isFavourite: false,
    fields: [
      FieldModel(sym: "principal", type: "number"),
      FieldModel(sym: "rate", type: "number"),       // Annual rate in %
      FieldModel(sym: "from", type: "date"),       // Time in years
      FieldModel(sym: "to", type: "date"),       // Time in years
      FieldModel(sym: "interestType", type: "options"), // simple, compound
      FieldModel(sym: "frequency", type: "options"),    // monthly, quarterly, half_yearly, yearly
    ],
    formulas: [
      // Options
      FormulaModel(pos: 0, sym: "interestType", expression: "simple,compound"),
      FormulaModel(pos: 1, sym: "frequency", expression: "monthly,quarterly,half_yearly,yearly"),


      FormulaModel(pos: 2, sym: "monthly", expression: "1"),
      FormulaModel(pos: 3, sym: "quarterly", expression: "2"),
      FormulaModel(pos: 4, sym: "half_yearly", expression: "3"),
      FormulaModel(pos: 5, sym: "yearly", expression: "4"),

      
      FormulaModel(pos: 6, sym: "ifmonthly", expression: "((quarterly-frequency)*(half_yearly-frequency)*(yearly-frequency))/((quarterly-monthly)*(half_yearly-monthly)*(yearly-monthly))"),
      FormulaModel(pos: 7, sym: "ifquarterly", expression: "((monthly-frequency)*(half_yearly-frequency)*(yearly-frequency))/((monthly-quarterly)*(half_yearly-monthly)*(yearly-monthly))"),
      FormulaModel(pos: 8, sym: "ifhalf_yearly", expression: "((quarterly-frequency)*(monthly-frequency)*(yearly-frequency))/((quarterly-monthly)*(monthly-half_yearly)*(yearly-monthly))"),
      FormulaModel(pos: 9, sym: "ifyearly", expression: "((quarterly-frequency)*(half_yearly-frequency)*(monthly-frequency))/((quarterly-monthly)*(half_yearly-monthly)*(monthly-yearly))"),

      // Frequency multiplier
      FormulaModel(pos: 10, sym: "n_monthly", expression: "ifmonthly * 12"),
      FormulaModel(pos: 11, sym: "n_quarterly", expression: "ifquarterly * 4"),
      FormulaModel(pos: 12, sym: "n_half_yearly", expression: "ifhalf_yearly * 2"),
      FormulaModel(pos: 13, sym: "n_yearly", expression: "ifyearly * 1"),
      
      // Total periods per year
      FormulaModel(pos: 14, sym: "n", expression: "n_monthly + n_quarterly + n_half_yearly + n_yearly"),


      // 
      FormulaModel(pos: 15, sym: "time", expression: "(to-from)/(1000*60*60*24*365)"),

      // Simple Interest
      FormulaModel(pos: 16, sym: "SI", expression: "principal * rate * time / 100"),

      // Compound Interest
      FormulaModel(pos: 17, sym: "CI", expression: "principal * ((1 + (rate/100)/n)^(n * time)) - principal"),

      // Interest type weighting

      FormulaModel(pos: 18, sym: "simple", expression: "1"),
      FormulaModel(pos: 19, sym: "compound", expression: "2"),

      FormulaModel(pos: 20, sym: "isSimple", expression: "(compound-interestType)/(compound-simple)"),
      FormulaModel(pos: 21, sym: "isCompound", expression: "(simple-interestType)/(simple-compound)"),

      // Final interest
      FormulaModel(pos: 500, sym: "res", expression: "SI*isSimple + CI*isCompound"),
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
    name: "Length - Conversion",
    createdOn: 1704067400,
    isFavourite: false,
    fields: [
      FieldModel(sym: "length", type: "number"),
      FieldModel(sym: "typeFrom", type: "options"),
      FieldModel(sym: "typeTo", type: "options"),
    ],
    formulas: [
      FormulaModel(pos: 0, sym: "typeFrom", expression: "km,m,deci,centi,mili,micro,nano,pico,nautical_mile,mile,furlong,fathom,yard,foot,inch,Li,zhang,chi,cun,fen,liihao,parsec,lunar_distance,astronomical_unit,light_year"),
      FormulaModel(pos: 1, sym: "typeTo", expression: "km,m,deci,centi,mili,micro,nano,pico,nautical_mile,mile,furlong,fathom,yard,foot,inch,Li,zhang,chi,cun,fen,liihao,parsec,lunar_distance,astronomical_unit,light_year"),
      FormulaModel(pos: 2, sym: "km", expression: "1000"),
      FormulaModel(pos: 3, sym: "m", expression: "1"),
      FormulaModel(pos: 4, sym: "deci", expression: "0.1"),
      FormulaModel(pos: 5, sym: "centi", expression: "0.01"),
      FormulaModel(pos: 6, sym: "mili", expression: "0.001"),
      FormulaModel(pos: 7, sym: "micro", expression: "0.000001"),
      FormulaModel(pos: 8, sym: "nano", expression: "0.000000001"),
      FormulaModel(pos: 9, sym: "pico", expression: "0.000000000001"),
      FormulaModel(pos: 10, sym: "nautical_mile", expression: "1852"),
      FormulaModel(pos: 11, sym: "mile", expression: "1609.344"),
      FormulaModel(pos: 12, sym: "furlong", expression: "201.168"),
      FormulaModel(pos: 13, sym: "fathom", expression: "1.8288"),
      FormulaModel(pos: 14, sym: "yard", expression: "0.9144"),
      FormulaModel(pos: 15, sym: "foot", expression: "0.3048"),
      FormulaModel(pos: 16, sym: "inch", expression: "0.0254"),
      FormulaModel(pos: 17, sym: "Li", expression: "500"),
      FormulaModel(pos: 18, sym: "zhang", expression: "3.333"),
      FormulaModel(pos: 19, sym: "chi", expression: "0.333"),
      FormulaModel(pos: 20, sym: "cun", expression: "0.0333"),
      FormulaModel(pos: 21, sym: "fen", expression: "0.00333"),
      FormulaModel(pos: 22, sym: "liihao", expression: "0.000333"),
      FormulaModel(pos: 23, sym: "parsec", expression: "30856775814913"),
      FormulaModel(pos: 24, sym: "lunar_distance", expression: "384400000"),
      FormulaModel(pos: 25, sym: "astronomical_unit", expression: "149597870700"),
      FormulaModel(pos: 26, sym: "light_year", expression: "9460730472580800"),
      FormulaModel(pos: 27, sym: "res", expression: "typeFrom/typeTo*length"),

    ],
    output: "res",
  ),

  CardModel(
    name: "Currency - Conversion",
    createdOn: 1704067500,
    isFavourite: false,
    fields: [
      FieldModel(sym: "amount", type: "number"),
      FieldModel(sym: "currencyFrom", type: "options"),
      FieldModel(sym: "currencyTo", type: "options"),
    ],
    formulas: [
      FormulaModel(
        pos: 0,
        sym: "currencyFrom",
        expression: "U_S_Dollar,Euro,British_Pound_Sterling,Swiss_Franc,Australian_Dollar,Canadian_Dollar,Singapore_Dollar,Japanese_Yen,Chinese_Yuan,Saudi_Riyal,Qatari_Rial,UAE_Dirham,Omani_Rial,Indian_Rupee,Malaysian_Ringgit,Thai_Baht,Kuwaiti_Dinar,South_Korean_Won,Nepali_Rupee"
      ),
      FormulaModel(
        pos: 1,
        sym: "currencyTo",
        expression: "U_S_Dollar,Euro,British_Pound_Sterling,Swiss_Franc,Australian_Dollar,Canadian_Dollar,Singapore_Dollar,Japanese_Yen,Chinese_Yuan,Saudi_Riyal,Qatari_Rial,UAE_Dirham,Omani_Rial,Indian_Rupee,Malaysian_Ringgit,Thai_Baht,Kuwaiti_Dinar,South_Korean_Won,Nepali_Rupee"
      ),

      // Values in terms of USD (USD = 1)
      FormulaModel(pos: 2, sym: "U_S_Dollar", expression: "1"),
      FormulaModel(pos: 3, sym: "Euro", expression: "1.19"), // 1 USD = 1.19 EUR
      FormulaModel(pos: 4, sym: "British_Pound_Sterling", expression: "1.416"),
      FormulaModel(pos: 5, sym: "Swiss_Franc", expression: "1.305"),
      FormulaModel(pos: 6, sym: "Australian_Dollar", expression: "0.966"),
      FormulaModel(pos: 7, sym: "Canadian_Dollar", expression: "0.920"),
      FormulaModel(pos: 8, sym: "Singapore_Dollar", expression: "0.856"),
      FormulaModel(pos: 9, sym: "Japanese_Yen", expression: "0.00652"), // per 1 JPY
      FormulaModel(pos: 10, sym: "Chinese_Yuan", expression: "0.0472"),
      FormulaModel(pos: 11, sym: "Saudi_Riyal", expression: "0.266"),
      FormulaModel(pos: 12, sym: "Qatari_Rial", expression: "0.247"),
      FormulaModel(pos: 13, sym: "UAE_Dirham", expression: "0.267"),
      FormulaModel(pos: 14, sym: "Omani_Rial", expression: "0.262"),
      FormulaModel(pos: 15, sym: "Indian_Rupee", expression: "0.01086"), // per 1 INR
      FormulaModel(pos: 16, sym: "Malaysian_Ringgit", expression: "0.0267"),
      FormulaModel(pos: 17, sym: "Thai_Baht", expression: "0.2128"),
      FormulaModel(pos: 18, sym: "Kuwaiti_Dinar", expression: "3.07"),
      FormulaModel(pos: 19, sym: "South_Korean_Won", expression: "0.0972"), // per 1 KRW
      FormulaModel(pos: 20, sym: "Nepali_Rupee", expression: "0.00681"), // per 1 KRW

      FormulaModel(pos: 21, sym: "a", expression: "1"),

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "a*currencyFrom / currencyTo * amount"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Mass - Conversion",
    createdOn: 1704067600,
    isFavourite: false,
    fields: [
      FieldModel(sym: "mass", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "tonne,kg,g,miligram,microgram,quintal,pound,ounce,carat,grain,long_ton,short_ton,uk_hundredweight,us_hundredweight,stone,dram,Dan,jin,qian,Liang,jin_Taiwan"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "tonne,kg,g,miligram,microgram,quintal,pound,ounce,carat,grain,long_ton,short_ton,uk_hundredweight,us_hundredweight,stone,dram,Dan,jin,qian,Liang,jin_Taiwan"
      ),

      // Base values in kilograms
      FormulaModel(pos: 2, sym: "tonne", expression: "1000"),
      FormulaModel(pos: 3, sym: "kg", expression: "1"),
      FormulaModel(pos: 4, sym: "g", expression: "0.001"),
      FormulaModel(pos: 5, sym: "miligram", expression: "0.000001"),
      FormulaModel(pos: 6, sym: "microgram", expression: "0.000000001"),
      FormulaModel(pos: 7, sym: "quintal", expression: "100"),
      FormulaModel(pos: 8, sym: "pound", expression: "0.45359237"),
      FormulaModel(pos: 9, sym: "ounce", expression: "0.0283495"),
      FormulaModel(pos: 10, sym: "carat", expression: "0.0002"),
      FormulaModel(pos: 11, sym: "grain", expression: "0.00006479891"),
      FormulaModel(pos: 12, sym: "long_ton", expression: "1016.0469088"),
      FormulaModel(pos: 13, sym: "short_ton", expression: "907.18474"),
      FormulaModel(pos: 14, sym: "uk_hundredweight", expression: "50.80234544"),
      FormulaModel(pos: 15, sym: "us_hundredweight", expression: "45.359237"),
      FormulaModel(pos: 16, sym: "stone", expression: "6.35029318"),
      FormulaModel(pos: 17, sym: "dram", expression: "0.0017718451953125"),
      FormulaModel(pos: 18, sym: "Dan", expression: "100"), // Chinese Dan
      FormulaModel(pos: 19, sym: "jin", expression: "0.5"), // Chinese jin
      FormulaModel(pos: 20, sym: "qian", expression: "0.05"), // 1/10 jin
      FormulaModel(pos: 21, sym: "Liang", expression: "0.005"), // 1/100 jin
      FormulaModel(pos: 22, sym: "jin_Taiwan", expression: "0.6"), // Taiwanese jin

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * mass"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Area - Conversion",
    createdOn: 1704067700,
    isFavourite: false,
    fields: [
      FieldModel(sym: "area", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "square_kilometer,hectare,are,square_meter,square_decimeter,square_centimeter,square_millimeter,acre,square_mile,square_yard,square_foot,square_inch,square_rod,quing,mu,square_chi,square_cun"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "square_kilometer,hectare,are,square_meter,square_decimeter,square_centimeter,square_millimeter,acre,square_mile,square_yard,square_foot,square_inch,square_rod,quing,mu,square_chi,square_cun"
      ),

      // Base values in square meters
      FormulaModel(pos: 2, sym: "square_kilometer", expression: "1000000"),
      FormulaModel(pos: 3, sym: "hectare", expression: "10000"),
      FormulaModel(pos: 4, sym: "are", expression: "100"),
      FormulaModel(pos: 5, sym: "square_meter", expression: "1"),
      FormulaModel(pos: 6, sym: "square_decimeter", expression: "0.01"),
      FormulaModel(pos: 7, sym: "square_centimeter", expression: "0.0001"),
      FormulaModel(pos: 8, sym: "square_millimeter", expression: "0.000001"),
      FormulaModel(pos: 9, sym: "acre", expression: "4046.8564224"),
      FormulaModel(pos: 10, sym: "square_mile", expression: "2589988.110336"),
      FormulaModel(pos: 11, sym: "square_yard", expression: "0.83612736"),
      FormulaModel(pos: 12, sym: "square_foot", expression: "0.09290304"),
      FormulaModel(pos: 13, sym: "square_inch", expression: "0.00064516"),
      FormulaModel(pos: 14, sym: "square_rod", expression: "25.29285264"),
      FormulaModel(pos: 15, sym: "quing", expression: "666.6666667"), // Chinese quing = 1/15 sq km
      FormulaModel(pos: 16, sym: "mu", expression: "666.6666667 / 15"), // 1 mu = 1/15 quing
      FormulaModel(pos: 17, sym: "square_chi", expression: "0.11111111"), // 1 chi = 1/3 m, square = 1/9, adjust
      FormulaModel(pos: 18, sym: "square_cun", expression: "0.0011111111"), // 1 cun = 1/30 m, square

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * area"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Time - Conversion",
    createdOn: 1704067800,
    isFavourite: false,
    fields: [
      FieldModel(sym: "time", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "year,week,day,hour,minute,second,millisecond,microsecond,picosecond"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "year,week,day,hour,minute,second,millisecond,microsecond,picosecond"
      ),

      // Base values in seconds
      FormulaModel(pos: 2, sym: "year", expression: "31536000"), // 365 days
      FormulaModel(pos: 3, sym: "week", expression: "604800"),   // 7 days
      FormulaModel(pos: 4, sym: "day", expression: "86400"),     // 24 hours
      FormulaModel(pos: 5, sym: "hour", expression: "3600"),     // 60 minutes
      FormulaModel(pos: 6, sym: "minute", expression: "60"),     
      FormulaModel(pos: 7, sym: "second", expression: "1"),      
      FormulaModel(pos: 8, sym: "millisecond", expression: "0.001"),  
      FormulaModel(pos: 9, sym: "microsecond", expression: "0.000001"),  
      FormulaModel(pos: 10, sym: "picosecond", expression: "0.000000000001"),  

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * time"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Data - Conversion",
    createdOn: 1704067900,
    isFavourite: false,
    fields: [
      FieldModel(sym: "data", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "byte,kilobyte,megabyte,gigabyte,terabyte,petabyte"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "byte,kilobyte,megabyte,gigabyte,terabyte,petabyte"
      ),

      // Base values in bytes
      FormulaModel(pos: 2, sym: "byte", expression: "1"),
      FormulaModel(pos: 3, sym: "kilobyte", expression: "1024"),
      FormulaModel(pos: 4, sym: "megabyte", expression: "1048576"),      // 1024^2
      FormulaModel(pos: 5, sym: "gigabyte", expression: "1073741824"),   // 1024^3
      FormulaModel(pos: 6, sym: "terabyte", expression: "1099511627776"),// 1024^4
      FormulaModel(pos: 7, sym: "petabyte", expression: "1125899906842624"), // 1024^5

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * data"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Date - Difference",
    createdOn: 1704068000,
    isFavourite: false,
    fields: [
      FieldModel(sym: "From", type: "date"),
      FieldModel(sym: "To", type: "date"),
      FieldModel(sym: "type", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "type",
        expression: "days,months,years"
      ),

      // Base values in bytes
      FormulaModel(pos: 1, sym: "days", expression: "1"),
      FormulaModel(pos: 2, sym: "months", expression: "2"),
      FormulaModel(pos: 3, sym: "years", expression: "3"),
      FormulaModel(pos: 4, sym: "ifdays", expression: "((months-type)*(years-type))/((months-days)*(years-days))"),
      FormulaModel(pos: 5, sym: "ifmonths", expression: "((days-type)*(years-type))/((days-months)*(years-days))"),
      FormulaModel(pos: 6, sym: "ifyears", expression: "((months-type)*(days-type))/((months-days)*(days-years))"),
      FormulaModel(pos: 7, sym: "todays", expression: "(To-From)/(1000*60*60*24)"),
      FormulaModel(pos: 8, sym: "tomonths", expression: "(To-From)/(1000*60*60*24*30)"),
      FormulaModel(pos: 9, sym: "toyears", expression: "(To-From)/(1000*60*60*24*365)"),

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "ifdays*todays+ifmonths*tomonths+ifyears*toyears"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Volume - Conversion",
    createdOn: 1704068100,
    isFavourite: false,
    fields: [
      FieldModel(sym: "volume", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "cubic_kilometer,cubic_meter,liter,milliliter,cubic_centimeter,cubic_millimeter,cubic_inch,cubic_foot,cubic_yard,gallon_US,quart_US,pint_US,cup_US,fluid_ounce_US,barrel_US"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "cubic_kilometer,cubic_meter,liter,milliliter,cubic_centimeter,cubic_millimeter,cubic_inch,cubic_foot,cubic_yard,gallon_US,quart_US,pint_US,cup_US,fluid_ounce_US,barrel_US"
      ),

      // Base values in cubic meters
      FormulaModel(pos: 2, sym: "cubic_kilometer", expression: "1000000000000"), // 10^12 m³
      FormulaModel(pos: 3, sym: "cubic_meter", expression: "1"),
      FormulaModel(pos: 4, sym: "liter", expression: "0.001"),
      FormulaModel(pos: 5, sym: "milliliter", expression: "0.000001"),
      FormulaModel(pos: 6, sym: "cubic_centimeter", expression: "0.000001"),
      FormulaModel(pos: 7, sym: "cubic_millimeter", expression: "0.000000001"),
      FormulaModel(pos: 8, sym: "cubic_inch", expression: "0.000016387064"),
      FormulaModel(pos: 9, sym: "cubic_foot", expression: "0.028316846592"),
      FormulaModel(pos: 10, sym: "cubic_yard", expression: "0.764554857984"),
      FormulaModel(pos: 11, sym: "gallon_US", expression: "0.003785411784"),
      FormulaModel(pos: 12, sym: "quart_US", expression: "0.000946352946"),
      FormulaModel(pos: 13, sym: "pint_US", expression: "0.000473176473"),
      FormulaModel(pos: 14, sym: "cup_US", expression: "0.0002365882365"),
      FormulaModel(pos: 15, sym: "fluid_ounce_US", expression: "0.0000295735295625"),
      FormulaModel(pos: 16, sym: "barrel_US", expression: "0.158987294928"), // 1 US barrel = 42 gallons

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * volume"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Speed - Conversion",
    createdOn: 1704068200,
    isFavourite: false,
    fields: [
      FieldModel(sym: "speed", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "meters_per_second,kilometer_per_hour,mile_per_hour,foot_per_second,knot,inch_per_second,centimeter_per_second"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "meters_per_second,kilometer_per_hour,mile_per_hour,foot_per_second,knot,inch_per_second,centimeter_per_second"
      ),

      // Base values in meters per second
      FormulaModel(pos: 2, sym: "meters_per_second", expression: "1"),
      FormulaModel(pos: 3, sym: "kilometer_per_hour", expression: "0.2777777778"), // 1 km/h = 1000/3600 m/s
      FormulaModel(pos: 4, sym: "mile_per_hour", expression: "0.44704"),          // 1 mph = 1609.344/3600 m/s
      FormulaModel(pos: 5, sym: "foot_per_second", expression: "0.3048"),         // 1 ft/s = 0.3048 m/s
      FormulaModel(pos: 6, sym: "knot", expression: "0.514444444"),                // 1 knot = 1852/3600 m/s
      FormulaModel(pos: 7, sym: "inch_per_second", expression: "0.0254"),         // 1 in/s = 0.0254 m/s
      FormulaModel(pos: 8, sym: "centimeter_per_second", expression: "0.01"),     // 1 cm/s = 0.01 m/s

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom / unitTo * speed"),
    ],
    output: "res",
  ),

  CardModel(
    name: "Temperature - Conversion",
    createdOn: 1704068300,
    isFavourite: false,
    fields: [
      FieldModel(sym: "temperature", type: "number"),
      FieldModel(sym: "unitFrom", type: "options"),
      FieldModel(sym: "unitTo", type: "options"),
    ],
    formulas: [
      // Options for dropdowns
      FormulaModel(
        pos: 0,
        sym: "unitFrom",
        expression: "Celsius,Fahrenheit,Kelvin,Rankine,Reaumur"
      ),
      FormulaModel(
        pos: 1,
        sym: "unitTo",
        expression: "Celsius,Fahrenheit,Kelvin,Rankine,Reaumur"
      ),

      // Base unit = Celsius
      FormulaModel(pos: 2, sym: "Celsius", expression: "temperature"),
      FormulaModel(pos: 3, sym: "Fahrenheit", expression: "(temperature * 9/5) + 32"),
      FormulaModel(pos: 4, sym: "Kelvin", expression: "temperature + 273.15"),
      FormulaModel(pos: 5, sym: "Rankine", expression: "(temperature + 273.15) * 9/5"),
      FormulaModel(pos: 6, sym: "Reaumur", expression: "temperature * 4/5"),

      // Result formula
      FormulaModel(pos: 500, sym: "res", expression: "unitFrom/unitTo"),
    ],
    output: "res",
  ),

  

];