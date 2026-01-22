

import 'package:dailycalc/sandbox/logic/events/test_1_events.dart';
import 'package:dailycalc/sandbox/logic/states/test_1_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Test1Bloc extends Bloc<Test1Events, Test1State>{
  Test1Bloc(): super(TestInitial()){
    on<Test1Load>((event, emit) async{
      emit(TestLoading());

      emit(TestLoaded("name"));
    });

    on<Test1Create>((event, emit) async{
      emit(Test1Created(event.newName));
    });
  }
  
}