import 'package:dailycalc/data/models/card_model.dart';
import 'package:dailycalc/logic/blocs/events/card_events.dart';
import 'package:dailycalc/logic/blocs/states/card_state.dart';
import 'package:dailycalc/repository/card_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardRepository repository;
  List<CardModel> _allCards = [];

  CardBloc(this.repository) : super(CardInitial()) {
    on<LoadCards>((event, emit) async {
      emit(CardLoading());
      try {
        _allCards = repository.getAllCards();
        emit(CardLoaded(_allCards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<SaveCard>((event, emit) async {
      try {
        await repository.updateCard(event.card);
        _allCards = repository.getAllCards();
        emit(CardLoaded(_allCards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<CreateCard>((event, emit) async {
      final newCard = CardModel(
        name: 'New Calculator',
        createdOn: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        isFavourite: false,
        fields: [],
        formulas: [],
        output: '',
      );

      await repository.createCard(newCard);

      emit(CardCreated(newCard));
    });

    on<DeleteCard>((event, emit) async {
      try {
        await repository.deleteCard(event.cardId);
        _allCards = repository.getAllCards();
        emit(CardLoaded(_allCards));
      } catch (e) {
        emit(CardError(e.toString()));
      }
    });

    on<SearchCards>((event, emit) {
      final filtered = _allCards
          .where((c) =>
              c.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(CardLoaded(filtered));
    });

    on<SortCards>((event, emit) {
      final sorted = List<CardModel>.from(_allCards);
      switch (event.sort) {
        case CardSort.nameAsc:
          sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case CardSort.nameDesc:
          sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
        case CardSort.dateAsc:
          sorted.sort((a, b) => a.createdOn.compareTo(b.createdOn));
          break;
        case CardSort.dateDesc:
          sorted.sort((a, b) => b.createdOn.compareTo(a.createdOn));
          break;
      }
      emit(CardLoaded(sorted));
    });
  }
}
