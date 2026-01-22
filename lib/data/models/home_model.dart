// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'package:dailycalc/data/models/card_model.dart';

import 'home_item_model.dart';

part 'home_model.g.dart';

@HiveType(typeId: 6)
class HomeModel extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int createdOn; // ID

  @HiveField(2)
  final CardModel type;

  @HiveField(3)
  final int cardId; // references CardModel.createdOn

  @HiveField(4)
  final List<HomeItemModel> items;

  @HiveField(5)
  final String aggregateFunction;

  @HiveField(6)
  final double output;

  const HomeModel({
    required this.name,
    required this.createdOn,
    required this.type,
    required this.cardId,
    required this.items,
    required this.aggregateFunction,
    required this.output,
  });

  HomeModel copyWith({
    String? name,
    int? createdOn,
    CardModel? type,
    int? cardId,
    List<HomeItemModel>? items,
    String? aggregateFunction,
    double? output,
  }) {
    return HomeModel(
      name: name ?? this.name,
      createdOn: createdOn ?? this.createdOn,
      type: type ?? this.type,
      cardId: cardId ?? this.cardId,
      items: items ?? this.items,
      aggregateFunction: aggregateFunction ?? this.aggregateFunction,
      output: output ?? this.output,
    );
  }
  
  @override
  List<Object> get props {
    return [
      name,
      createdOn,
      type,
      cardId,
      items,
      aggregateFunction,
      output,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'createdOn': createdOn,
      'type': type.toMap(),
      'cardId': cardId,
      'items': items.map((x) => x.toMap()).toList(),
      'aggregateFunction': aggregateFunction,
      'output': output,
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      name: map['name'] as String,
      createdOn: map['createdOn'] as int,
      type: CardModel.fromMap(map['type'] as Map<String,dynamic>),
      cardId: map['cardId'] as int,
      items: (map['items'] as List)
        .map((x) => HomeItemModel.fromMap(x as Map<String, dynamic>))
        .toList(),
      aggregateFunction: map['aggregateFunction'] as String,
      output: map['output'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeModel.fromJson(String source) => HomeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
