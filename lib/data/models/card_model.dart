// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'field_model.dart';
import 'formula_model.dart';

part 'card_model.g.dart';

@HiveType(typeId: 3)
class CardModel extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int createdOn; // millisecondsSinceEpoch (used as ID)

  @HiveField(2)
  final bool isFavourite;

  @HiveField(3)
  final List<FieldModel> fields;

  @HiveField(4)
  final List<FormulaModel> formulas;

  @HiveField(5)
  final String output;

  const CardModel({
    required this.name,
    required this.createdOn,
    required this.isFavourite,
    required this.fields,
    required this.formulas,
    required this.output,
  });

  CardModel copyWith({
    String? name,
    int? createdOn,
    bool? isFavourite,
    List<FieldModel>? fields,
    List<FormulaModel>? formulas,
    String? output,
  }) {
    return CardModel(
      name: name ?? this.name,
      createdOn: createdOn ?? this.createdOn,
      isFavourite: isFavourite ?? this.isFavourite,
      fields: fields ?? this.fields,
      formulas: formulas ?? this.formulas,
      output: output ?? this.output,
    );
  }
  
  @override
  List<Object> get props {
    return [
      name,
      createdOn,
      isFavourite,
      fields,
      formulas,
      output,
    ];
  }
  
  @override
  bool? get stringify => true;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'createdOn': createdOn,
      'isFavourite': isFavourite,
      'fields': fields.map((x) => x.toMap()).toList(),
      'formulas': formulas.map((x) => x.toMap()).toList(),
      'output': output,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      name: map['name'] as String,
      createdOn: map['createdOn'] as int,
      isFavourite: map['isFavourite'] as bool,
      fields: (map['fields'] as List)
        .map((x) => FieldModel.fromMap(x as Map<String, dynamic>))
        .toList(),
      formulas: (map['formulas'] as List)
        .map((x) => FormulaModel.fromMap(x as Map<String, dynamic>))
        .toList(),
      output: map['output'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardModel.fromJson(String source) => CardModel.fromMap(json.decode(source) as Map<String, dynamic>);

}
