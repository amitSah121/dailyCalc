import '../data/datasources/history_hive_datasource.dart';
import '../data/models/calc_history_model.dart';

class HistoryRepository {
  final HistoryHiveDataSource _local;

  HistoryRepository(this._local);

  Future<void> addHistory(CalcHistoryModel history) {
    return _local.add(history);
  }

  Future<void> deleteHistory(int id) {
    return _local.delete(id);
  }

  List<CalcHistoryModel>? getHistoryByCard(int cardId) {
    return _local.getByCardId(cardId);
  }

  List<CalcHistoryModel> getAll() {
    return _local.getAll();
  }

  
}
