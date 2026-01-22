import 'package:get_it/get_it.dart';
import 'repository/card_repository.dart';
import 'repository/home_repository.dart';
import 'repository/history_repository.dart';
import 'repository/settings_repository.dart';
import 'data/datasources/card_hive_datasource.dart';
import 'data/datasources/home_hive_datasource.dart';
import 'data/datasources/history_hive_datasource.dart';
import 'data/datasources/settings_hive_datasource.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/card_model.dart';
import 'data/models/home_model.dart';
import 'data/models/calc_history_model.dart';
import 'data/models/theme_settings_model.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  // Boxes
  final cardBox = Hive.box<CardModel>('cards');
  final homeBox = Hive.box<HomeModel>('homes');
  final historyBox = Hive.box<CalcHistoryModel>('history');
  final settingsBox = Hive.box<ThemeSettingsModel>('settings');

  // DataSources
  sl.registerLazySingleton(() => CardHiveDataSource(cardBox));
  sl.registerLazySingleton(() => HomeHiveDataSource(homeBox));
  sl.registerLazySingleton(() => HistoryHiveDataSource(historyBox));
  sl.registerLazySingleton(() => SettingsHiveDataSource(settingsBox));

  // Repositories
  sl.registerLazySingleton(() => CardRepository(sl()));
  sl.registerLazySingleton(() => HomeRepository(sl()));
  sl.registerLazySingleton(() => HistoryRepository(sl()));
  sl.registerLazySingleton(() => SettingsRepository(sl()));
}
