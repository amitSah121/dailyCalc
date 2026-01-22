// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardModelAdapter extends TypeAdapter<CardModel> {
  @override
  final int typeId = 3;

  @override
  CardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardModel(
      name: fields[0] as String,
      createdOn: fields[1] as int,
      isFavourite: fields[2] as bool,
      fields: (fields[3] as List).cast<FieldModel>(),
      formulas: (fields[4] as List).cast<FormulaModel>(),
      output: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CardModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.isFavourite)
      ..writeByte(3)
      ..write(obj.fields)
      ..writeByte(4)
      ..write(obj.formulas)
      ..writeByte(5)
      ..write(obj.output);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
