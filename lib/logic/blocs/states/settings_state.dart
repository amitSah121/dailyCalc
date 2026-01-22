import 'package:dailycalc/data/models/theme_settings_model.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final ThemeSettingsModel themeSettings;
  final bool isBusy;
  final String? message;

  const SettingsState({
    required this.isDarkMode,
    required this.themeSettings,
    this.isBusy = false,
    this.message,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    ThemeSettingsModel? themeSettings,
    bool? isBusy,
    String? message,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeSettings: themeSettings ?? this.themeSettings,
      isBusy: isBusy ?? this.isBusy,
      message: message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      "themeSettings": themeSettings
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      isDarkMode: map['isDarkMode'] ?? false,
      themeSettings: map['themeSettings'] ?? ThemeSettingsModel(font: "roboto", fontSize: 14, theme: "orange-bluegray"),
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        themeSettings,
        isBusy,
        message,
      ];
}
