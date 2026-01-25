import 'package:dailycalc/data/models/spreadsheet_model.dart';
import 'package:dailycalc/logic/blocs/events/spreadsheet_events.dart';
import 'package:dailycalc/logic/blocs/states/spreadsheet_state.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:dailycalc/repository/spreadsheet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

class SpreadsheetBloc extends Bloc<SpreadsheetEvents, SpreadSheetState>{
  final SpreadSheetRepository repository;
  final HomeRepository homeRepo;
  List<SpreadSheetModel> _allSheets = [];

  SpreadsheetBloc(this.repository, this.homeRepo):super(SheetInitial()){
    on<LoadSheets>((event, emit) async {
      emit(SheetLoading());
      try {
        _allSheets = repository.getAllCards();
        emit(SheetLoaded(_allSheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

    on<SaveSheet>((event, emit) async {
      try {
        await repository.updateCard(event.sheet);
        _allSheets = repository.getAllCards();
        emit(SheetLoaded(_allSheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

    on<CreateSheet>((event, emit) async {
      final newSheet = SpreadSheetModel(
        name: event.name,
        createdOn: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        cardId: event.cardId,
        cardName: event.cardName,
        homeCardIds: event.homeItemsId == null ? [] : event.homeItemsId!,
        
      );

      await repository.createCard(newSheet);

      emit(SheetCreated(newSheet));
    });

    on<UpdateSheetItem>((event, emit) {
      emit(SheetLoading());

      final inputs = event.inputs;

      double output = 0.0;
      try {
        final parser = Parser();
        final cm = ContextModel();

        for (final input in inputs) {
          final numValue = double.tryParse(input.value.toString()) ?? 0;
          cm.bindVariable(Variable(input.name), Number(numValue));
        }

        String lastOutput = '';

        final formulas = List.from(event.home.type.formulas)
          ..sort((a, b) => a.pos.compareTo(b.pos));

        for (final formula in formulas) {
          final exp = parser.parse(formula.expression);
          final value = exp.evaluate(EvaluationType.REAL, cm);
          cm.bindVariable(Variable(formula.sym), Number(value));
          lastOutput = value.toString();
        }

        output = double.tryParse(lastOutput) ?? 0.0;
      } catch (_) {
        output = 0.0;
      }
      try {
        // 1️⃣ Update inputs immutably
        final updatedInputs = event.homeItem.inputs.map((item) {
          final updated = event.inputs.firstWhere(
            (i) => i.name == item.name,
            orElse: () => item,
          );

          return updated.name == item.name
              ? item.copyWith(value: updated.value)
              : item;
        }).toList();

        // 2️⃣ Create updated HomeItem
        final updatedHomeItem =
            event.homeItem.copyWith(inputs: updatedInputs,output: output);

        // 3️⃣ Replace item in HomeModel
        final updatedItems = event.home.items.map((i) {
          return i.createdOn == updatedHomeItem.createdOn
              ? updatedHomeItem
              : i;
        }).toList();

        // 4️⃣ Save once
        homeRepo.updateHome(
          event.home.copyWith(items: updatedItems),
        );

        _allSheets = repository.getAllCards();
        // 5️⃣ Emit success
        emit(SheetLoaded(_allSheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

    on<UpdateSheetName>((event, emit) async{
      try{
        repository.updateCard(event.sheet.copyWith(name: event.name));
        _allSheets = repository.getAllCards();
        // 5️⃣ Emit success
        emit(SheetLoaded(_allSheets));
      }catch(e){
        emit(SheetError(e.toString()));
      }

    });

    on<DuplicateSheet>((event, emit) async{
      try{
        final newSheet = event.sheet.copyWith(name: "new "+event.sheet.name,createdOn: DateTime.now().millisecondsSinceEpoch ~/ 1000);
        await repository.createCard(newSheet);
        // _allSheets = repository.getAllCards();
        // 5️⃣ Emit success
        emit(SheetCreated(newSheet));
      }catch(e){
        emit(SheetError(e.toString()));
      }

    });

    on<DeleteSheet>((event, emit) async {
      try {
        await repository.deleteCard(event.sheetId);
        _allSheets = repository.getAllCards();
        emit(SheetLoaded(_allSheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

    on<SearchSheets>((event, emit) {
      final filtered = _allSheets
          .where((c) =>
              c.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(SheetLoaded(filtered));
    });

    on<SortSheets>((event, emit) {
      final sorted = List<SpreadSheetModel>.from(_allSheets);
      switch (event.sort) {
        case SheetSort.nameAsc:
          sorted.sort((a, b) => (a.name.split("__%*%__")[0]).toLowerCase().compareTo((b.name.split("__%*%__")[0]).toLowerCase()));
          break;
        case SheetSort.nameDesc:
          sorted.sort((a, b) => (b.name.split("__%*%__")[0]).toLowerCase().compareTo((a.name.split("__%*%__")[0]).toLowerCase()));
          break;
        case SheetSort.dateAsc:
          sorted.sort((a, b) => a.createdOn.compareTo(b.createdOn));
          break;
        case SheetSort.dateDesc:
          sorted.sort((a, b) => b.createdOn.compareTo(a.createdOn));
          break;
      }
      emit(SheetLoaded(sorted));
    });

    on<AddSheet>((event, emit) async {
      try {
        await repository.createCard(event.sheet);
        final sheets = repository.getAllCards();
        emit(SheetLoaded(sheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

    on<UpdateSheetHomes>((event, emit) async {
      emit(SheetLoading());

      try {
        // 1️⃣ Create updated sheet immutably
        final updatedSheet = event.sheet.copyWith(
          homeCardIds: event.homeIds,
        );

        // 2️⃣ Persist
        await repository.updateCard(updatedSheet);

        // 3️⃣ Reload all sheets
        _allSheets = repository.getAllCards();

        // 4️⃣ Emit updated state
        emit(SheetLoaded(_allSheets));
      } catch (e) {
        emit(SheetError(e.toString()));
      }
    });

  }
}