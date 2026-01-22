// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeItemModelAdapter extends TypeAdapter<HomeItemModel> {
  @override
  final int typeId = 5;

  @override
  HomeItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeItemModel(
      note: fields[0] as String,
      createdOn: fields[1] as int,
      date: fields[2] as int,
      inputs: (fields[3] as List).cast<InputModel>(),
      output: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HomeItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.note)
      ..writeByte(1)
      ..write(obj.createdOn)
      ..writeByte(2)
      ..write(obj.date)
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
      other is HomeItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
