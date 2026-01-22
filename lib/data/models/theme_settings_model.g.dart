// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeSettingsModelAdapter extends TypeAdapter<ThemeSettingsModel> {
  @override
  final int typeId = 8;

  @override
  ThemeSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeSettingsModel(
      font: fields[0] as String,
      fontSize: fields[1] as double,
      theme: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeSettingsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.font)
      ..writeByte(1)
      ..write(obj.fontSize)
      ..writeByte(2)
      ..write(obj.theme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
