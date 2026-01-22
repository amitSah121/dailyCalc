import 'package:dailycalc/data/datasources/spreadsheet_hive_datasource.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';

class SpreadSheetRepository {
  final SpreadSheetHiveDataSource _local;

  SpreadSheetRepository(this._local);

  Future<void> createCard(SpreadSheetModel sheet) {
    return _local.save(sheet);
  }

  Future<void> updateCard(SpreadSheetModel card) {
    return _local.save(card);
  }

  SpreadSheetModel? getCardById(int id) {
    return _local.getById(id);
  }

  List<SpreadSheetModel> getAllCards() {
    return _local.getAll();
  }

  Future<void> deleteCard(int id) async {
    await _local.delete(id);
  }

  /// ---- Domain helpers ----

  Future<void> addHomeItem({
    required int sheetId, // createdOn
    required int homeCardId,
  }) async {
    final sheet = _local.getById(sheetId);
    if (sheet == null) return;

    final updated = SpreadSheetModel(
      name: sheet.name,
      cardName: sheet.cardName,
      cardId: sheet.cardId,
      createdOn: sheet.createdOn,
      homeCardIds: [
        ...sheet.homeCardIds,
        homeCardId,
      ],
    );

    await _local.save(updated);
  }

  Future<void> removeHomeItem({
    required int sheetId, // createdOn
    required String homeCardId,
  }) async {
    final sheet = _local.getById(sheetId);
    if (sheet == null) return;

    final updated = SpreadSheetModel(
      name: sheet.name,
      cardName: sheet.cardName,
      cardId: sheet.cardId,
      createdOn: sheet.createdOn,
      homeCardIds: sheet.homeCardIds
          .where((id) => id != homeCardId)
          .toList(),
    );

    await _local.save(updated);
  }

}
