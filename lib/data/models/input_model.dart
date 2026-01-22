// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'input_model.g.dart';

@HiveType(typeId: 4)
class InputModel extends Equatable {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String value;

  const InputModel({
    required this.name,
    required this.value,
  });

  InputModel copyWith({
    String? name,
    String? value,
  }) {
    return InputModel(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
  
  @override
  List<Object> get props => [name, value];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'value': value,
    };
  }

  factory InputModel.fromMap(Map<String, dynamic> map) {
    return InputModel(
      name: map['name'] as String,
      value: map['value'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory InputModel.fromJson(String source) => InputModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
