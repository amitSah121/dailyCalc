// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'spreadsheet_model.g.dart';

@HiveType(typeId: 9)
class SpreadSheetModel extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String cardName;

  /// uses createdOn as id
  @HiveField(2)
  final int cardId;

  @HiveField(3)
  final int createdOn;

  @HiveField(4)
  final List<int> homeCardIds;

  SpreadSheetModel({
    required this.name,
    required this.cardName,
    required this.cardId,
    required this.createdOn,
    required this.homeCardIds,
  });
  
  @override
  List<Object> get props {
    return [
      name,
      cardName,
      cardId,
      createdOn,
      homeCardIds,
    ];
  }

  SpreadSheetModel copyWith({
    String? name,
    String? cardName,
    int? cardId,
    int? createdOn,
    List<int>? homeCardIds,
  }) {
    return SpreadSheetModel(
      name: name ?? this.name,
      cardName: cardName ?? this.cardName,
      cardId: cardId ?? this.cardId,
      createdOn: createdOn ?? this.createdOn,
      homeCardIds: homeCardIds ?? this.homeCardIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cardName': cardName,
      'cardId': cardId,
      'createdOn': createdOn,
      'homeCardIds': homeCardIds,
    };
  }

  factory SpreadSheetModel.fromMap(Map<String, dynamic> map) {
    return SpreadSheetModel(
      name: map['name'] as String,
      cardName: map['cardName'] as String,
      cardId: map['cardId'] as int,
      createdOn: map['createdOn'] as int,
      homeCardIds: List<int>.from((map['homeCardIds'] as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory SpreadSheetModel.fromJson(String source) => SpreadSheetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
