// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'theme_settings_model.g.dart';

@HiveType(typeId: 8)
class ThemeSettingsModel extends Equatable {
  @HiveField(0)
  final String font;

  @HiveField(1)
  final double fontSize;

  @HiveField(2)
  final String theme;

  const ThemeSettingsModel({
    required this.font,
    required this.fontSize,
    required this.theme,
  });

  ThemeSettingsModel copyWith({
    String? font,
    double? fontSize,
    String? theme,
  }) {
    return ThemeSettingsModel(
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
    );
  }
  
  @override
  List<Object> get props => [font, fontSize, theme];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'font': font,
      'fontSize': fontSize,
      'theme': theme,
    };
  }

  factory ThemeSettingsModel.fromMap(Map<String, dynamic> map) {
    return ThemeSettingsModel(
      font: map['font'] as String,
      fontSize: map['fontSize'] as double,
      theme: map['theme'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThemeSettingsModel.fromJson(String source) => ThemeSettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
