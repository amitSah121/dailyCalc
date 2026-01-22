import 'package:dailycalc/data/models/calc_history_model.dart';
import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/data/models/theme_settings_model.dart';
import 'package:dailycalc/domain/import/import_result.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/repository/history_repository.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:dailycalc/repository/settings_repository.dart';
import 'package:dailycalc/repository/spreadsheet_repository.dart';

class ImportService {
  final CardRepository cardRepo;
  final HomeRepository homeRepo;
  final SpreadSheetRepository sheetRepo;
  final HistoryRepository calcRepo;
  final SettingsRepository settingsRepo;

  ImportService({
    required this.cardRepo,
    required this.homeRepo,
    required this.calcRepo,
    required this.settingsRepo,
    required this.sheetRepo,
  });

  Future<ImportResult> importFromJson(Map<String, dynamic> json) async {
    int cardCount = 0;
    int homeCount = 0;
    int calcCount = 0;
    int sheetCount = 0;

    /// 1️⃣ Cards
    for (final cardMap in (json['cards'] as List? ?? [])) {
      final card = CardModel.fromMap(cardMap);

      final existing = cardRepo.getCardById(card.createdOn);
      if (existing == null) {
        await cardRepo.createCard(card);
      } else {
        await cardRepo.updateCard(card);
      }

      cardCount++;
    }

    /// 2️⃣ Homes
    for (final homeMap in (json['homes'] as List? ?? [])) {
      final home = HomeModel.fromMap(homeMap);

      final existing = homeRepo.getHomeById(home.createdOn);
      if (existing == null) {
        await homeRepo.createHome(home);
      } else {
        await homeRepo.updateHome(home);
      }
      
      homeCount++;
    }

    for (final sheetMap in (json['sheets'] as List? ?? [])) {
      final sheet = SpreadSheetModel.fromMap(sheetMap);

      final existing = sheetRepo.getCardById(sheet.createdOn);
      if (existing == null) {
        await sheetRepo.createCard(sheet);
      } else {
        await sheetRepo.updateCard(sheet);
      }

      sheetCount++;
    }

    /// 3️⃣ Calculator history
    for (final calcMap in (json['history'] as List? ?? [])) {
      final history = CalcHistoryModel.fromMap(calcMap);

      final existing = calcRepo.getHistoryByCard(history.createdOn);
      if (existing == null) {
        await calcRepo.addHistory(history);
      } else {
        await calcRepo.addHistory(history);
      }
      calcCount++;
    }

    /// 4️⃣ Settings
    if (json['settings'] != null) {
      await settingsRepo.saveTheme(
        ThemeSettingsModel.fromMap(json['settings']),
      );
    }

    return ImportResult(
      cardsImported: cardCount,
      homesImported: homeCount,
      calcHistoryImported: calcCount,
      sheetsImported: sheetCount,
    );
  }
}
