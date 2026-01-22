// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spreadsheet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpreadSheetAdapter extends TypeAdapter<SpreadSheetModel> {
  @override
  final int typeId = 9;

  @override
  SpreadSheetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpreadSheetModel(
      name: fields[0] as String,
      cardName: fields[1] as String,
      cardId: fields[2] as int,
      createdOn: fields[3] as int,
      homeCardIds: (fields[4] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, SpreadSheetModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.cardName)
      ..writeByte(2)
      ..write(obj.cardId)
      ..writeByte(3)
      ..write(obj.createdOn)
      ..writeByte(4)
      ..write(obj.homeCardIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpreadSheetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
