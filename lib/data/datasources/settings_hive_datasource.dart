import 'package:hive/hive.dart';

import '../models/theme_settings_model.dart';

class SettingsHiveDataSource {
  final Box<ThemeSettingsModel> box;

  SettingsHiveDataSource(this.box);

  ThemeSettingsModel? get() {
    return box.get('theme');
  }

  Future<void> save(ThemeSettingsModel settings) async {
    await box.put('theme', settings);
  }
}
