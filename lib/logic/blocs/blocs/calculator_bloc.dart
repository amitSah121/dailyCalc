import 'package:dailycalc/data/models/calc_history_model.dart';
import 'package:dailycalc/data/models/input_model.dart';
import 'package:dailycalc/helper.dart';
import 'package:dailycalc/logic/blocs/events/calculator_events.dart';
import 'package:dailycalc/logic/blocs/states/calculator_state.dart';
import 'package:dailycalc/repository/history_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final HistoryRepository historyRepository;

  CalculatorBloc(this.historyRepository)
      : super(CalculatorState(isCalculatorMode: true)) {
    

    on<LoadHistory>((event, emit) {
      List<CalcHistoryModel> allHistory = historyRepository.getAll();
      emit(state.copyWith(history: allHistory));
    });

    // Switch modes
    on<SwitchMode>((event, emit) async {
      // Load history for this card if card mode
      // List<CalcHistoryModel> history = [];
      // if (event.card != null) {
      //   history =
      //       historyRepository.getHistoryByCard(event.card!.createdOn) ?? [];
      // }

      emit(state.copyWith(
        setActiveCard: true,
        isCalculatorMode: event.card == null,
        activeCard: event.card,
        expression: '',
        cardValues: {},
        output: '',
        history: state.history,
      ));
    });

    // Update calculator expression
    on<CalculatorInputChanged>((event, emit) {
      emit(state.copyWith(expression: event.expression));
    });

    // Update a card field value
    on<CardFieldUpdated>((event, emit) {
      final updatedValues = Map<String, dynamic>.from(state.cardValues);
      updatedValues[event.fieldSym] = event.value;
      emit(state.copyWith(cardValues: updatedValues));
    });

    on<OpenCardFromHistory>((event, emit) {
      emit(
        state.copyWith(
          setActiveCard: true,
          isCalculatorMode: event.card == null,
          activeCard: event.card,
          expression: event.card == null ? event.inputs[0].value: "",
          output: '',
          cardValues: Map.fromEntries(
            event.inputs.map(
              (e) => MapEntry(e.name, e.value),
            ),
          ),
          history: state.history
        ),
      );
    });


    // Evaluate (calculator or card)
    
    on<Evaluate>((event, emit) {
      String result = '';

      try {
        final parser = Parser();
        final cm = ContextModel();

        // ---------------- Calculator Mode ----------------
        if (state.isCalculatorMode) {
          String text = rewriteCalculatorPercent(state.expression);
          final exp = parser.parse(text);
          final value = exp.evaluate(EvaluationType.REAL, cm);
          result = value.toString();
        }

        // ---------------- Card Mode ----------------
        else if (state.activeCard != null) {
          final options = {};
          // Bind input values
          state.cardValues.forEach((key, val) { 
            for(final i in state.activeCard!.fields){
              if((i.type == "number" || i.type == "date") && i.sym == key){
                final numValue = double.tryParse(val.toString()) ?? 0.0;
                cm.bindVariable(Variable(key), Number(numValue));
              }else if(i.sym == key){
                options.addAll({i.sym: val.split(",")});
              }
            }
          });

          String lastOutput = '';

          var formulas = [...state.activeCard!.formulas];

          for(final i in state.activeCard!.fields){
            if(i.type == "options"){
              formulas = formulas.where((e) => e.sym != i.sym).toList();
            }
          }

          for (final entry in options.entries) {
            final selectedSym = state.cardValues[entry.key];

            final item = formulas.firstWhere(
              (f) => f.sym == selectedSym
            );

            formulas = formulas.map((e) {
              return e.copyWith(
                expression:
                    e.expression.replaceAll(entry.key, item.expression),
              );
            }).toList();
          }


          formulas.sort((a, b) => a.pos.compareTo(b.pos));

          for (final formula in formulas) {
            final exp = parser.parse(formula.expression);
            final value = exp.evaluate(EvaluationType.REAL, cm);

            // Store computed variable for next formulas
            cm.bindVariable(Variable(formula.sym), Number(value));
            lastOutput = value.toString();
          }

          result = lastOutput;
        }
      } catch (e) {
        result = 'Error';
      }

      emit(state.copyWith(output: result));
    });



    // Save to Hive history
    on<SaveToHistory>((event, emit) async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // seconds
      final inputs = state.cardValues.entries
          .map((e) => InputModel(name: e.key, value: e.value.toString()))
          .toList();
      if(state.activeCard == null){
        inputs.clear();
        inputs.add(InputModel(name: "__calculator", value: state.expression));
      }

      final historyEntry = CalcHistoryModel(
        type: state.activeCard,
        createdOn: now,
        cardId: state.activeCard?.createdOn,
        inputs: inputs,
        output: double.tryParse(state.output.replaceAll('π', '${3.141592653589793}')) ?? 0, // or handle strings differently
      );

      await historyRepository.addHistory(historyEntry);

      // Update state with latest history
      // final updatedHistory = state.activeCard != null
      //     ? historyRepository.getHistoryByCard(state.activeCard!.createdOn) ?? []
      //     : state.history;

      emit(state.copyWith(history: historyRepository.getAll()));
    });

    on<ClearHistory>((event, emit) async {
      if (state.activeCard != null) {
        final cardId = state.activeCard!.createdOn;
        final cardHistory = historyRepository.getHistoryByCard(cardId) ?? [];
        for (var entry in cardHistory) {
          await historyRepository.deleteHistory(entry.createdOn);
        }
        emit(state.copyWith(history: []));
      } else {
        // Clear all history
        final allHistory = historyRepository.getAll();
        for (var entry in allHistory) {
          await historyRepository.deleteHistory(entry.createdOn);
        }
        emit(state.copyWith(history: []));
      }
    });
  }
}
