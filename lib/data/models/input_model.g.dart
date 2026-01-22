// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InputModelAdapter extends TypeAdapter<InputModel> {
  @override
  final int typeId = 4;

  @override
  InputModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InputModel(
      name: fields[0] as String,
      value: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InputModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
