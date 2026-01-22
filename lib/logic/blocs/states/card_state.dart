import 'package:dailycalc/data/models/card_model.dart';
import 'package:equatable/equatable.dart';

abstract class CardState extends Equatable {
  const CardState();

  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<CardModel> cards;
  const CardLoaded(this.cards);

  @override
  List<Object?> get props => [cards];
}

class CardCreated extends CardState {
  final CardModel card;
  const CardCreated(this.card);

  @override
  List<Object?> get props => [card];
}


class CardError extends CardState {
  final String message;
  const CardError(this.message);

  @override
  List<Object?> get props => [message];
}
