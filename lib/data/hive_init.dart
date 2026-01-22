
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/calc_history_model.dart';
import 'models/card_model.dart';
import 'models/field_model.dart';
import 'models/formula_model.dart';
import 'models/home_item_model.dart';
import 'models/home_model.dart';
import 'models/input_model.dart';
import 'models/theme_settings_model.dart';


Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(FieldModelAdapter());
  Hive.registerAdapter(FormulaModelAdapter());
  Hive.registerAdapter(CardModelAdapter());
  Hive.registerAdapter(InputModelAdapter());
  Hive.registerAdapter(HomeItemModelAdapter());
  Hive.registerAdapter(HomeModelAdapter());
  Hive.registerAdapter(CalcHistoryModelAdapter());
  Hive.registerAdapter(ThemeSettingsModelAdapter());
  Hive.registerAdapter(SpreadSheetAdapter());

  await Hive.openBox<CardModel>('cards');
  await Hive.openBox<HomeModel>('homes');
  await Hive.openBox<CalcHistoryModel>('history');
  await Hive.openBox<ThemeSettingsModel>('settings');
  await Hive.openBox<SpreadSheetModel>('sheets');
}
