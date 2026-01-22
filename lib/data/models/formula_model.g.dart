// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formula_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FormulaModelAdapter extends TypeAdapter<FormulaModel> {
  @override
  final int typeId = 2;

  @override
  FormulaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FormulaModel(
      pos: fields[0] as int,
      sym: fields[1] as String,
      expression: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FormulaModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pos)
      ..writeByte(1)
      ..write(obj.sym)
      ..writeByte(2)
      ..write(obj.expression);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormulaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
