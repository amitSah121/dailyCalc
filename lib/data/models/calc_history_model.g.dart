// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calc_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalcHistoryModelAdapter extends TypeAdapter<CalcHistoryModel> {
  @override
  final int typeId = 7;

  @override
  CalcHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalcHistoryModel(
      type: fields[0] as CardModel?,
      createdOn: fields[1] as int,
      cardId: fields[2] as int?,
      inputs: (fields[3] as List).cast<InputModel>(),
      output: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CalcHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.cardId)
      ..writeByte(3)
      ..write(obj.inputs)
      ..writeByte(4)
      ..write(obj.output);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalcHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
