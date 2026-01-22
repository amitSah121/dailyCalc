import '../data/datasources/settings_hive_datasource.dart';
import '../data/models/theme_settings_model.dart';

class SettingsRepository {
  final SettingsHiveDataSource _local;

  SettingsRepository(this._local);

  ThemeSettingsModel? getTheme() {
    return _local.get();
  }

  Future<void> saveTheme(ThemeSettingsModel settings) {
    return _local.save(settings);
  }
}
