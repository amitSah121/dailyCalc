import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/data/models/input_model.dart';

abstract class CalculatorEvent {}

// Switch between calculator mode and card mode
class SwitchMode extends CalculatorEvent {
  final CardModel? card; // null = calculator
  SwitchMode({this.card});
}

// User input changed in calculator expression
class CalculatorInputChanged extends CalculatorEvent {
  final String expression;
  CalculatorInputChanged(this.expression);
}

// User updated a card field
class CardFieldUpdated extends CalculatorEvent {
  final String fieldSym;
  final dynamic value;
  CardFieldUpdated({required this.fieldSym, required this.value});
}

// Evaluate current input (calculator or card)
class Evaluate extends CalculatorEvent {}

// Save result to history (Hive)
class SaveToHistory extends CalculatorEvent {}


class LoadHistory extends CalculatorEvent {}

class ClearHistory extends CalculatorEvent {}

class OpenCardFromHistory extends CalculatorEvent {
  final CardModel? card;
  final List<InputModel> inputs;

  OpenCardFromHistory({
    required this.card,
    required this.inputs,
  });
}

