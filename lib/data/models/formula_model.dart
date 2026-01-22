// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'formula_model.g.dart';

@HiveType(typeId: 2)
class FormulaModel extends Equatable {
  @HiveField(0)
  final int pos;

  @HiveField(1)
  final String sym;

  @HiveField(2)
  final String expression;

  const FormulaModel({
    required this.pos,
    required this.sym,
    required this.expression,
  });

  FormulaModel copyWith({
    int? pos,
    String? sym,
    String? expression,
  }) {
    return FormulaModel(
      pos: pos ?? this.pos,
      sym: sym ?? this.sym,
      expression: expression ?? this.expression,
    );
  }
  
  @override
  List<Object> get props => [pos, sym, expression];
  
  @override
  // TODO: implement stringify
  bool? get stringify => throw UnimplementedError();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pos': pos,
      'sym': sym,
      'expression': expression,
    };
  }

  factory FormulaModel.fromMap(Map<String, dynamic> map) {
    return FormulaModel(
      pos: map['pos'] as int,
      sym: map['sym'] as String,
      expression: map['expression'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormulaModel.fromJson(String source) => FormulaModel.fromMap(json.decode(source) as Map<String, dynamic>);

}
