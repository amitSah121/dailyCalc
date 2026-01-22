import 'package:hive/hive.dart';

import '../models/home_model.dart';

class HomeHiveDataSource {
  final Box<HomeModel> box;

  HomeHiveDataSource(this.box);

  Future<void> save(HomeModel home) async {
    await box.put(home.createdOn, home);
  }

  List<HomeModel> getByCardId(int cardId) {
    return box.values
        .where((home) => home.cardId == cardId)
        .toList();
  }

  HomeModel? getById(int id) {
    return box.get(id);
  }

  List<HomeModel> getAll() {
    return box.values.toList();
  }

  Future<void> delete(int id) async {
    await box.delete(id);
  }

}
