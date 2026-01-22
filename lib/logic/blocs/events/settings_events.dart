abstract class SettingsEvent {}

/// UI
class ToggleDarkMode extends SettingsEvent {}

/// Theme settings
class ChangeFont extends SettingsEvent {
  final String font;
  ChangeFont(this.font);
}

class ChangeFontSize extends SettingsEvent {
  final double fontSize;
  ChangeFontSize(this.fontSize);
}

class ChangeTheme extends SettingsEvent {
  final String theme;
  ChangeTheme(this.theme);
}

/// EXPORT
class OpenExportFilePicker extends SettingsEvent {}

class StartExport extends SettingsEvent {
  final String filePath;
  StartExport(this.filePath);
}

class ExportCompleted extends SettingsEvent {
  final String filePath;
  ExportCompleted(this.filePath);
}

class ExportFailed extends SettingsEvent {
  final String error;
  ExportFailed(this.error);
}

/// IMPORT
class OpenImportFilePicker extends SettingsEvent {}

class StartImport extends SettingsEvent {
  final String data;
  StartImport(this.data);
}

class ImportCompleted extends SettingsEvent {}

class ImportFailed extends SettingsEvent {
  final String error;
  ImportFailed(this.error);
}
