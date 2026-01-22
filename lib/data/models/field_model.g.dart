// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FieldModelAdapter extends TypeAdapter<FieldModel> {
  @override
  final int typeId = 1;

  @override
  FieldModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FieldModel(
      sym: fields[0] as String,
      type: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FieldModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.sym)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
