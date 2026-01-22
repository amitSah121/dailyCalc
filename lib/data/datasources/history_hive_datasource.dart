import 'package:hive/hive.dart';

import '../models/calc_history_model.dart';

class HistoryHiveDataSource {
  final Box<CalcHistoryModel> box;

  HistoryHiveDataSource(this.box);

  Future<void> add(CalcHistoryModel history) async {
    await box.add(history);
  }

  List<CalcHistoryModel> getByCardId(int cardId) {
    return box.values
        .where((h) => h.cardId == cardId)
        .toList();
  }

  List<CalcHistoryModel> getAll() {
    return box.values.toList();
  }


  Future<void> delete(int id) async {
    await box.delete(id);
  }
}
