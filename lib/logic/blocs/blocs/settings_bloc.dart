import 'dart:convert';
import 'package:dailycalc/data/models/theme_settings_model.dart';
import 'package:dailycalc/domain/export/export_service.dart';
import 'package:dailycalc/domain/import/import_service.dart';
import 'package:dailycalc/logic/blocs/events/settings_events.dart';
import 'package:dailycalc/logic/blocs/states/settings_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:dailycalc/repository/history_repository.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:dailycalc/repository/settings_repository.dart';
import 'package:dailycalc/repository/spreadsheet_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;
  late ImportService importService;
  late ExportService exportService;
  final CardRepository cardRepository;
  final HomeRepository homeRepository;
  final HistoryRepository calcRepository;
  final SpreadSheetRepository sheetRepository;
  
  SettingsBloc(
    this.repository,
    this.cardRepository,
    this.homeRepository,
    this.calcRepository,
    this.sheetRepository
    )
      : super(
          SettingsState(
            isDarkMode: false,
            themeSettings:
                repository.getTheme() ??
                const ThemeSettingsModel(
                  font: 'Roboto',
                  fontSize: 14,
                  theme: 'orange-bluegray',
                ),
          ),
        ) {
    /// Theme
    on<ToggleDarkMode>((event, emit) {
      emit(state.copyWith(isDarkMode: !state.isDarkMode));
    });

    on<ChangeFont>((event, emit) {
      final updated = state.themeSettings.copyWith(font: event.font);
      repository.saveTheme(updated);
      emit(state.copyWith(themeSettings: updated));
    });

    on<ChangeFontSize>((event, emit) {
      final updated =
          state.themeSettings.copyWith(fontSize: event.fontSize);
      repository.saveTheme(updated);
      emit(state.copyWith(themeSettings: updated));
    });

    on<ChangeTheme>((event, emit) {
      final updated = state.themeSettings.copyWith(theme: event.theme);
      repository.saveTheme(updated);
      emit(state.copyWith(themeSettings: updated));
    });

    /// Export
    on<StartExport>((event, emit) async {
      emit(state.copyWith(isBusy: true, message: null));

      final exportService = ExportService();

      final cards = cardRepository.getAllCards();
      final homes = homeRepository.getAll();
      final history = calcRepository.getAll();
      final theme = repository.getTheme();
      final sheets = sheetRepository.getAllCards();

      final result = await exportService.exportAll(
        cards: cards,
        homes: homes,
        history: history,
        theme: theme!,
        sheets: sheets
      );

      emit(state.copyWith(
        isBusy: false,
        message: result.message,
      ));
    });


    /// Import
    on<StartImport>((event, emit) async {
      emit(state.copyWith(isBusy: true, message: null));

      try {
        final json = event.data;
        final data = jsonDecode(json);

        importService = ImportService(cardRepo: cardRepository, homeRepo: homeRepository, calcRepo: calcRepository, settingsRepo: repository, sheetRepo: sheetRepository);
        final result = await importService.importFromJson(data);

        emit(state.copyWith(
          isBusy: false,
          message:
              "Imported ${result.cardsImported} cards, "
              "${result.homesImported} homes"
              "${result.calcHistoryImported} history"
              "${result.sheetsImported} sheets",
        ));
      } catch (e) {
        emit(state.copyWith(
          isBusy: false,
          message: "Import failed: ${e.toString()}}",
        ));
      }
    });
  }
  /// Hydration
  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toMap();
  }
}

 
