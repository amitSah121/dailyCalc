import 'dart:io';

import 'package:dailycalc/data/datasources/home_hive_datasource.dart';
import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
import 'package:dailycalc/data/models/home_item_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/input_model.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/datasources/card_hive_datasource.dart';
import 'package:dailycalc/repository/card_repository.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<CardModel> box;
  late Box<HomeModel> boxx;
  late CardHiveDataSource dataSource_card;
  late HomeHiveDataSource dataSource_home;
  late CardRepository repository_card;
  late HomeRepository repository_home;

  // Register adapters once
  Hive.registerAdapter(FieldModelAdapter());
  Hive.registerAdapter(FormulaModelAdapter());
  Hive.registerAdapter(CardModelAdapter());
  Hive.registerAdapter(InputModelAdapter());
  Hive.registerAdapter(HomeItemModelAdapter());
  Hive.registerAdapter(HomeModelAdapter());

  group("Homerepository test",() {
    
    setUp(() async {
      // 1️⃣ Initialize Hive in temp folder
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);


      // 3️⃣ Open box
      box = await Hive.openBox<CardModel>('test_cards');
      boxx = await Hive.openBox<HomeModel>("test_home");

      // 4️⃣ Initialize datasource + repository
      dataSource_card = CardHiveDataSource(box);
      repository_card = CardRepository(dataSource_card);


      dataSource_home = HomeHiveDataSource(boxx);
      repository_home = HomeRepository(dataSource_home);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
      await boxx.clear();
      await boxx.close();
    });

    test('Create and read a home and its items', () async {
      final field1 = FieldModel(sym: "Amount", type: "number");
      final field2 = FieldModel(sym: "From", type: "date");
      final field3 = FieldModel(sym: "To", type: "date");

      final formula1 = FormulaModel(pos: 0, sym: "a", expression: "Amount");
      final formula2 = FormulaModel(pos: 1, sym: "b", expression: "From");
      final formula3 = FormulaModel(pos: 2, sym: "c", expression: "To");
      final formula4 = FormulaModel(pos: 3, sym: "d", expression: "a*(c-b)");
      final card = CardModel(
        name: 'Interest',
        createdOn: 1001,
        isFavourite: false,
        fields: [field1,field2,field3],
        formulas: [formula1, formula2, formula3, formula4],
        output: "d",
      );

      await repository_card.createCard(card);
      final fetched_card = repository_card.getCardById(1001);

      final input1 = InputModel(name: "Amount", value: "5");
      final input2 = InputModel(name: "From", value: "100");
      final input3 = InputModel(name: "To", value: "150");


      final input4 = InputModel(name: "Amount", value: "50");
      final input5 = InputModel(name: "From", value: "1000");
      final input6 = InputModel(name: "To", value: "1500");

      final homeitem1 = HomeItemModel(note: "Hello buddy", createdOn: 1002, date: 100, inputs: [input1, input2, input3], output: 50);
      final homeitem2 = HomeItemModel(note: "Hello buddy", createdOn: 1002, date: 100, inputs: [input4, input5, input6], output: 50);

      final home = HomeModel(name: "Shyam", createdOn: 1003, type: fetched_card!, cardId: 1001, items: [homeitem1], aggregateFunction: "sum", output: 300);
      
      await repository_home.createHome(home);
      await repository_home.addItem(homeId: 1003, item: homeitem2);

      // --- Fetch and verify ---
      final fetchedHome = repository_home.getHomeById(1003);
      expect(fetchedHome, isNotNull);
      expect(fetchedHome!.name, "Shyam");
      expect(fetchedHome.cardId, 1001);
      expect(fetchedHome.items.length, 2);

      // Check first home item
      final fetchedItem1 = fetchedHome.items[0];
      expect(fetchedItem1.note, "Hello buddy");
      expect(fetchedItem1.createdOn, 1002);
      expect(fetchedItem1.date, 100);
      expect(fetchedItem1.output, 50);
      expect(fetchedItem1.inputs[0], InputModel(name: "Amount", value: "5"));
      expect(fetchedItem1.inputs[1], InputModel(name: "From", value: "100"));
      expect(fetchedItem1.inputs[2], InputModel(name: "To", value: "150"));

      // Check second home item
      final fetchedItem2 = fetchedHome.items[1];
      expect(fetchedItem2.inputs[0], InputModel(name: "Amount", value: "50"));
      expect(fetchedItem2.inputs[1], InputModel(name: "From", value: "1000"));
      expect(fetchedItem2.inputs[2], InputModel(name: "To", value: "1500"));

      // --- Test searching home items ---
      final searchResults1 = fetchedHome.items.where(
        (item) => item.inputs.any((input) => input.name.contains("Amount")),
      ).toList();
      expect(searchResults1.length, 2); // both items have "Amount" input

      final searchResults2 = fetchedHome.items.where(
        (item) => item.inputs.any((input) => input.value.contains("1000")),
      ).toList();
      expect(searchResults2.length, 1);
      expect(searchResults2.first.inputs[1].value, "1000");
      
    });
  });
}
