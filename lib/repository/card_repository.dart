import '../data/datasources/card_hive_datasource.dart';
import '../data/models/card_model.dart';
import '../data/models/field_model.dart';
import '../data/models/formula_model.dart';

class CardRepository {
  final CardHiveDataSource _local;

  CardRepository(this._local);

  Future<void> createCard(CardModel card) {
    return _local.save(card);
  }

  Future<void> updateCard(CardModel card) {
    return _local.save(card);
  }

  CardModel? getCardById(int id) {
    return _local.getById(id);
  }

  List<CardModel> getAllCards() {
    return _local.getAll();
  }

  Future<void> deleteCard(int id) async {
    await _local.delete(id);
  }

  /// ---- Domain helpers ----

  Future<void> addField({
    required int cardId,
    required FieldModel field,
  }) async {
    final card = _local.getById(cardId);
    if (card == null) return;

    final updated = CardModel(
      name: card.name,
      createdOn: card.createdOn,
      isFavourite: card.isFavourite,
      fields: [...card.fields, field],
      formulas: card.formulas,
      output: card.output,
    );

    await _local.save(updated);
  }

  Future<void> addFormula({
    required int cardId,
    required FormulaModel formula,
  }) async {
    final card = _local.getById(cardId);
    if (card == null) return;

    final updated = CardModel(
      name: card.name,
      createdOn: card.createdOn,
      isFavourite: card.isFavourite,
      fields: card.fields,
      formulas: [...card.formulas, formula],
      output: card.output,
    );

    await _local.save(updated);
  }
}
