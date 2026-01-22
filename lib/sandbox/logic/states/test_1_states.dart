

import 'package:equatable/equatable.dart';

abstract class Test1State extends Equatable{

  const Test1State();
  
  @override
  List<Object?> get props => [];
}

class TestInitial extends Test1State{}

class TestLoading extends Test1State{}

class TestLoaded extends Test1State{
  final String name;
  const TestLoaded(this.name);

  @override
  List<Object?> get props => [name];
}

class Test1Created extends Test1State{
  final String newName;
  const Test1Created(this.newName);

  @override
  List<Object?> get props => [newName];
}