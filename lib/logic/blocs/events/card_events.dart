import 'package:dailycalc/data/models/card_model.dart';
import 'package:equatable/equatable.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => [];
}

// Load all cards
class LoadCards extends CardEvent {}

// Add / Update a card
class SaveCard extends CardEvent {
  final CardModel card;
  const SaveCard(this.card);

  @override
  List<Object?> get props => [card];
}

class CreateCard extends CardEvent {
  const CreateCard();
}


// Delete a card
class DeleteCard extends CardEvent {
  final int cardId;
  const DeleteCard(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

// Search cards by name
class SearchCards extends CardEvent {
  final String query;
  const SearchCards(this.query);

  @override
  List<Object?> get props => [query];
}

// Sort cards
enum CardSort { nameAsc, nameDesc, dateAsc, dateDesc }
class SortCards extends CardEvent {
  final CardSort sort;
  const SortCards(this.sort);

  @override
  List<Object?> get props => [sort];
}
