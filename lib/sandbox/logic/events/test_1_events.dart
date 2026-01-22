
import 'package:equatable/equatable.dart';

abstract class Test1Events extends Equatable{
  const Test1Events();

  @override
  List<Object?> get props => [];
}


class Test1Load extends Test1Events{

}

class Test1Create extends Test1Events{
  final String newName;
  const Test1Create(this.newName);
}