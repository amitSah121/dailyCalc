import 'dart:io';

import 'package:dailycalc/data/models/field_model.dart';
import 'package:dailycalc/data/models/formula_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/datasources/card_hive_datasource.dart';
import 'package:dailycalc/repository/card_repository.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<CardModel> box;
  late CardHiveDataSource dataSource;
  late CardRepository repository;

  // Register adapters once
  Hive.registerAdapter(FieldModelAdapter());
  Hive.registerAdapter(FormulaModelAdapter());
  Hive.registerAdapter(CardModelAdapter());

  group("Cardrepository test",() {
    
    setUp(() async {
      // 1️⃣ Initialize Hive in temp folder
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);


      // 3️⃣ Open box
      box = await Hive.openBox<CardModel>('test_cards');

      // 4️⃣ Initialize datasource + repository
      dataSource = CardHiveDataSource(box);
      repository = CardRepository(dataSource);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    test('Create and read a card', () async {
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

      await repository.createCard(card);
      final fetched = repository.getCardById(1001);
      expect(fetched?.name, 'Interest');
      expect(fetched?.isFavourite, false);
      expect(fetched?.fields[0], FieldModel(sym: "Amount", type: "number"));
      expect(fetched?.fields[1], FieldModel(sym: "From", type: "date"));
      expect(fetched?.fields[2], FieldModel(sym: "To", type: "date"));

      expect(fetched?.formulas[0], FormulaModel(pos:0,sym: "a", expression: "Amount"));
      expect(fetched?.formulas[1], FormulaModel(pos:1,sym: "b", expression: "From"));
      expect(fetched?.formulas[2], FormulaModel(pos:2,sym: "c", expression: "To"));
      expect(fetched?.formulas[3], FormulaModel(pos:3,sym: "d", expression: "a*(c-b)"));

      expect(fetched?.output, "d");

      final field4 = FieldModel(sym: "FormulaName", type: "string");
      final updated = card.copyWith(fields: [field1, field2, field3, field4]);
      await repository.updateCard(updated);

      final fetched_2 = repository.getCardById(1001);
      expect(fetched_2?.fields[3], FieldModel(sym: "FormulaName", type: "string"));

      await repository.deleteCard(1001);

      final fetched_3 = repository.getCardById(3);
      expect(fetched_3, null);
    });
  });
}
