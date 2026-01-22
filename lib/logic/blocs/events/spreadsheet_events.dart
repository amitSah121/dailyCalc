

import 'package:dailycalc/data/models/home_item_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/input_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:equatable/equatable.dart';

abstract class SpreadsheetEvents extends Equatable{

  const SpreadsheetEvents();

  @override
  List<Object?> get props => [];
}

class LoadSheets extends SpreadsheetEvents{
}

class CreateSheet extends SpreadsheetEvents{
  final String name;
  final int cardId;
  final String cardName;
  final List<int>? homeItemsId;
  const CreateSheet(this.name, this.cardId, this.cardName, this.homeItemsId);


  @override
  List<Object?> get props => [name, cardId, cardName, homeItemsId];
}

class SaveSheet extends SpreadsheetEvents{
  final SpreadSheetModel sheet;
  const SaveSheet(this.sheet);


  @override
  List<Object?> get props => [sheet];
}

class AddSheet extends SpreadsheetEvents {
  final int sheetId;
  final SpreadSheetModel sheet;

  const AddSheet({
    required this.sheetId,
    required this.sheet,
  });

  @override
  List<Object?> get props => [sheetId, sheet];
}



// Delete a Sheet
class DeleteSheet extends SpreadsheetEvents {
  final int sheetId;
  const DeleteSheet(this.sheetId);

  @override
  List<Object?> get props => [sheetId];
}

// Search Sheets by name
class SearchSheets extends SpreadsheetEvents {
  final String query;
  const SearchSheets(this.query);

  @override
  List<Object?> get props => [query];
}

// Sort Sheets
enum SheetSort { nameAsc, nameDesc, dateAsc, dateDesc }
class SortSheets extends SpreadsheetEvents {
  final SheetSort sort;
  const SortSheets(this.sort);

  @override
  List<Object?> get props => [sort];
}

class UpdateSheetItem extends SpreadsheetEvents{
  final HomeModel home;
  final HomeItemModel homeItem;
  final List<InputModel> inputs;
  const UpdateSheetItem(this.home, this.homeItem, this.inputs);


  @override
  List<Object?> get props => [home, homeItem, inputs];
}


class UpdateSheetHomes extends SpreadsheetEvents {
  final SpreadSheetModel sheet;
  final List<int> homeIds;

  const UpdateSheetHomes({
    required this.sheet,
    required this.homeIds,
  });


  @override
  List<Object?> get props => [sheet, homeIds];
}


