import 'package:hive/hive.dart';

import '../models/spreadsheet_model.dart';

class SpreadSheetHiveDataSource {
  final Box<SpreadSheetModel> box;

  SpreadSheetHiveDataSource(this.box);

  Future<void> save(SpreadSheetModel sheet) async {
    await box.put(sheet.createdOn, sheet);
  }

  SpreadSheetModel? getById(int id) {
    return box.get(id);
  }

  List<SpreadSheetModel> getAll() {
    return box.values.toList();
  }

  Future<void> delete(int id) async {
    await box.delete(id);
  }
}
