// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'package:dailycalc/data/models/card_model.dart';

import 'input_model.dart';

part 'calc_history_model.g.dart';

@HiveType(typeId: 7)
class CalcHistoryModel extends Equatable {
  @HiveField(0)
  final CardModel? type;

  @HiveField(1)
  final int createdOn;

  @HiveField(2)
  final int? cardId;

  @HiveField(3)
  final List<InputModel> inputs;

  @HiveField(4)
  final double output;

  const CalcHistoryModel({
    this.type,
    required this.createdOn,
    this.cardId,
    required this.inputs,
    required this.output,
  });

  CalcHistoryModel copyWith({
    CardModel? type,
    int? createdOn,
    int? cardId,
    List<InputModel>? inputs,
    double? output,
  }) {
    return CalcHistoryModel(
      type: type ?? this.type,
      createdOn: createdOn ?? this.createdOn,
      cardId: cardId ?? this.cardId,
      inputs: inputs ?? this.inputs,
      output: output ?? this.output,
    );
  }
  
  @override
  List<Object> get props {
    return [
      ?type,
      createdOn,
      ?cardId,
      inputs,
      output,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type?.toMap(),
      'createdOn': createdOn,
      'cardId': cardId,
      'inputs': inputs.map((x) => x.toMap()).toList(),
      'output': output,
    };
  }

  factory CalcHistoryModel.fromMap(Map<String, dynamic> map) {
    return CalcHistoryModel(
      type: map['type'] != null ? CardModel.fromMap(map['type'] as Map<String,dynamic>) : null,
      createdOn: map['createdOn'] as int,
      cardId: map['cardId'] != null ? map['cardId'] as int : null,
      inputs: (map['inputs'] as List)
        .map((x) => InputModel.fromMap(x as Map<String, dynamic>))
        .toList(),
      output: map['output'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory CalcHistoryModel.fromJson(String source) => CalcHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
