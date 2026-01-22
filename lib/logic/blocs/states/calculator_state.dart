import 'package:dailycalc/data/models/calc_history_model.dart';
import 'package:dailycalc/data/models/card_model.dart';

class CalculatorState {
  final bool isCalculatorMode;
  final CardModel? activeCard;
  final String expression;
  final Map<String, dynamic> cardValues;
  final String output;
  final List<CalcHistoryModel> history;

  CalculatorState({
    required this.isCalculatorMode,
    this.activeCard,
    this.expression = '',
    Map<String, dynamic>? cardValues,
    this.output = '',
    List<CalcHistoryModel>? history,
  })  : cardValues = cardValues ?? {},
        history = history ?? [];

  CalculatorState copyWith({
    CardModel? activeCard,
    bool setActiveCard = false,
    bool? isCalculatorMode,
    String? expression,
    Map<String, dynamic>? cardValues,
    String? output,
    List<CalcHistoryModel>? history,
  }) {
    return CalculatorState(
      activeCard: setActiveCard ? activeCard : this.activeCard,
      isCalculatorMode: isCalculatorMode ?? this.isCalculatorMode,
      expression: expression ?? this.expression,
      cardValues: cardValues ?? this.cardValues,
      output: output ?? this.output,
      history: history ?? this.history,
    );
  }
}
