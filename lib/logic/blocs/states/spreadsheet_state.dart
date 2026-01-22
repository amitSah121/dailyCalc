

import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:equatable/equatable.dart';

abstract class SpreadSheetState extends Equatable{
  const SpreadSheetState();

  @override
  List<Object?> get props => [];
}


class SheetInitial extends SpreadSheetState{

}

class SheetLoading extends SpreadSheetState{

}

class SheetLoaded extends SpreadSheetState{
  final List<SpreadSheetModel> sheets;
  const SheetLoaded(this.sheets);


  @override
  List<Object?> get props => [sheets];
}

class SheetCreated extends SpreadSheetState{
  final SpreadSheetModel sheet;
  const SheetCreated(this.sheet);


  @override
  List<Object?> get props => [sheet];
}


class SheetError extends SpreadSheetState{
  final String message;
  const SheetError(this.message);

  
  @override
  List<Object?> get props => [message];
}