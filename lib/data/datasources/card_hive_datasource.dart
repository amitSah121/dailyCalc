import 'package:hive/hive.dart';

import '../models/card_model.dart';

class CardHiveDataSource {
  final Box<CardModel> box;

  CardHiveDataSource(this.box);

  Future<void> save(CardModel card) async {
    await box.put(card.createdOn, card);
  }

  CardModel? getById(int id) {
    return box.get(id);
  }

  List<CardModel> getAll() {
    return box.values.toList();
  }

  Future<void> delete(int id) async {
    await box.delete(id);
  }
}
