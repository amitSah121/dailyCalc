// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'field_model.g.dart';

@HiveType(typeId: 1)
class FieldModel extends Equatable {
  @HiveField(0)
  final String sym;

  @HiveField(1)
  final String type;

  const FieldModel({
    required this.sym,
    required this.type,
  });

  FieldModel copyWith({
    String? sym,
    String? type,
  }) {
    return FieldModel(
      sym: sym ?? this.sym,
      type: type ?? this.type,
    );
  }
  
  @override
  List<Object> get props => [sym, type];
  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sym': sym,
      'type': type,
    };
  }

  factory FieldModel.fromMap(Map<String, dynamic> map) {
    return FieldModel(
      sym: map['sym'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FieldModel.fromJson(String source) => FieldModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
