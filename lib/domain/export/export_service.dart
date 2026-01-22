import 'dart:convert';

import 'package:dailycalc/data/models/calc_history_model.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/data/models/theme_settings_model.dart';
import 'package:dailycalc/domain/export/export_result.dart';
import 'package:flutter/services.dart';

class ExportService {
  Future<ExportResult> exportAll({
    required List<CardModel> cards,
    required List<HomeModel> homes,
    required List<SpreadSheetModel> sheets,
    required List<CalcHistoryModel> history,
    required ThemeSettingsModel theme,
    // required String filePath,
  }) async {
    try {
      final exportMap = {
        'cards': cards.map((e) => _cardToMap(e)).toList(),
        'homes': homes.map((e) => _homeToMap(e)).toList(),
        'sheets': sheets.map((e) => _sheetToMap(e)).toList(),
        'history': history.map((e) => _historyToMap(e)).toList(),
        'settings': theme.toMap()
      };

      final jsonString = jsonEncode(exportMap);


      await Clipboard.setData(ClipboardData(text: jsonString));
      

      // final file = File(filePath);
      // if (!await file.exists()) {
      //   await file.create(recursive: true);
      // }
      // await file.writeAsString(jsonString);

      return const ExportResult(
        status: ExportStatus.success,
        message: 'Export completed to clipboard',
      );
    } catch (e) {
      return ExportResult(
        status: ExportStatus.failure,
        message: 'Export failed',
      );
    }
  }

  // ---- Mappers ----

  Map<String, dynamic> _cardToMap(CardModel card) => {
    'name': card.name,
    'createdOn': card.createdOn,
    'isFavourite': card.isFavourite,
    'fields': card.fields.map((f) => {'sym': f.sym, 'type': f.type}).toList(),
    'formulas': card.formulas
        .map((f) => {'pos': f.pos, 'sym': f.sym, 'expression': f.expression})
        .toList(),
    'output': card.output,
  };

  Map<String, dynamic> _homeToMap(HomeModel home) => {
    'name': home.name,
    'createdOn': home.createdOn,
    'type': home.type.toMap(),
    'cardId': home.cardId,
    'aggregateFunction': home.aggregateFunction,
    'output': home.output,
    'items': home.items
        .map(
          (i) => {
            'note': i.note,
            'createdOn': i.createdOn,
            'date': i.date,
            'inputs': i.inputs
                .map((inpt) => {'name': inpt.name, 'value': inpt.value})
                .toList(),
            'output': i.output,
          },
        )
        .toList(),
  };

  Map<String, dynamic> _historyToMap(CalcHistoryModel h) => {
    'type': h.type?.toMap(),
    'cardId': h.cardId,
    'createdOn':h.createdOn,
    'inputs': h.inputs.map((i) => {'name': i.name, 'value': i.value}).toList(),
    'output': h.output,
  };

  Map<String, dynamic> _sheetToMap(SpreadSheetModel s) => {
    'name': s.name,
    'cardName': s.cardName,
    'cardId': s.cardId,
    'createdOn': s.createdOn,
    'homeCardIds': s.homeCardIds,
  };


  // Map<String, dynamic> _themeToMap(ThemeSettingsModel t) => {
  //   'font': t.font,
  //   'fontSize': t.fontSize,
  //   'theme': t.theme
  // };
}
