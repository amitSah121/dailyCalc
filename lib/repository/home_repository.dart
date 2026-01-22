import '../data/datasources/home_hive_datasource.dart';
import '../data/models/home_model.dart';
import '../data/models/home_item_model.dart';

class HomeRepository {
  final HomeHiveDataSource _local;

  HomeRepository(this._local);

  Future<void> createHome(HomeModel home) {
    return _local.save(home);
  }


  Future<void> updateHome(HomeModel home) {
    return _local.save(home);
  }

  HomeModel? getHomeById(int id) {
    return _local.getById(id);
  }


  Future<void> deleteCard(int id) async {
    await _local.delete(id);
  }
 
  List<HomeModel> getHomesByCard(int cardId) {
    return _local.getByCardId(cardId);
  }

  List<HomeModel> getAll() {
    return _local.getAll();
  }

  Future<void> addItem({
    required int homeId,
    required HomeItemModel item,
  }) async {
    final home = _local.getById(homeId);
    if (home == null) return;

    final updated = HomeModel(
      name: home.name,
      createdOn: home.createdOn,
      type: home.type,
      cardId: home.cardId,
      items: [...home.items, item],
      aggregateFunction: home.aggregateFunction,
      output: home.output,
    );

    await _local.save(updated);
  }
}
