// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'input_model.dart';

part 'home_item_model.g.dart';

@HiveType(typeId: 5)
class HomeItemModel extends Equatable {
  @HiveField(0)
  final String note;

  @HiveField(1)
  final int createdOn; // ID

  @HiveField(2)
  final int date; // millisecondsSinceEpoch

  @HiveField(3)
  final List<InputModel> inputs;

  @HiveField(4)
  final double output;

  const HomeItemModel({
    required this.note,
    required this.createdOn,
    required this.date,
    required this.inputs,
    required this.output,
  });

  HomeItemModel copyWith({
    String? note,
    int? createdOn,
    int? date,
    List<InputModel>? inputs,
    double? output,
  }) {
    return HomeItemModel(
      note: note ?? this.note,
      createdOn: createdOn ?? this.createdOn,
      date: date ?? this.date,
      inputs: inputs ?? this.inputs,
      output: output ?? this.output,
    );
  }
  
  @override
  List<Object> get props {
    return [
      note,
      createdOn,
      date,
      inputs,
      output,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'note': note,
      'createdOn': createdOn,
      'date': date,
      'inputs': inputs.map((x) => x.toMap()).toList(),
      'output': output,
    };
  }

  factory HomeItemModel.fromMap(Map<String, dynamic> map) {
    return HomeItemModel(
      note: map['note'] as String,
      createdOn: map['createdOn'] as int,
      date: map['date'] as int,
      inputs: (map['inputs'] as List)
        .map((x) => InputModel.fromMap(x as Map<String, dynamic>))
        .toList(),
      output: map['output'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeItemModel.fromJson(String source) => HomeItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
