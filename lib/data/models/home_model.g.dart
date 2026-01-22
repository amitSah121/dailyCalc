// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeModelAdapter extends TypeAdapter<HomeModel> {
  @override
  final int typeId = 6;

  @override
  HomeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeModel(
      name: fields[0] as String,
      createdOn: fields[1] as int,
      type: fields[2] as CardModel,
      cardId: fields[3] as int,
      items: (fields[4] as List).cast<HomeItemModel>(),
      aggregateFunction: fields[5] as String,
      output: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HomeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.cardId)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.aggregateFunction)
      ..writeByte(6)
      ..write(obj.output);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
