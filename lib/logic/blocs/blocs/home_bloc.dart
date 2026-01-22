import 'package:dailycalc/logic/blocs/events/home_event.dart';
import 'package:dailycalc/logic/blocs/states/home_state.dart';
import 'package:dailycalc/repository/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<LoadHomes>((event, emit) async {
      emit(HomeLoading());
      try {
        final homes = repository.getAll();
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<LoadHomesByCard>((event, emit) async {
      emit(HomeLoading());
      try {
        final homes = repository.getHomesByCard(event.cardId);
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });


    on<AddHome>((event, emit) async {
      try {
        await repository.createHome(event.home);
        final homes = repository.getAll();
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<UpdateHome>((event, emit) async {
      try {
        await repository.updateHome(event.home);
        final homes = repository.getAll();
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<AddHomeItem>((event, emit) async {
      try {
        await repository.addItem(homeId: event.homeId, item: event.item);
        final homes = repository.getAll();
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<DeleteHome>((event, emit) async {
      try {
        await repository.deleteCard(event.home.createdOn);
        final homes = repository.getAll();
        emit(HomeLoaded(homes));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

  }
}
