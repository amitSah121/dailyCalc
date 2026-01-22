import 'package:dailycalc/data/models/home_item_model.dart';
import 'package:dailycalc/data/models/home_model.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomes extends HomeEvent {}

class LoadHomesByCard extends HomeEvent {
  final int cardId;

  const LoadHomesByCard(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class AddHome extends HomeEvent {
  final HomeModel home;

  const AddHome(this.home);

  @override
  List<Object?> get props => [home];
}

class DeleteHome extends HomeEvent {
  final HomeModel home;

  const DeleteHome(this.home);

  @override
  List<Object?> get props => [home];
}


class UpdateHome extends HomeEvent {
  final HomeModel home;

  const UpdateHome(this.home);

  @override
  List<Object?> get props => [home];
}

class AddHomeItem extends HomeEvent {
  final int homeId;
  final HomeItemModel item;

  const AddHomeItem({
    required this.homeId,
    required this.item,
  });

  @override
  List<Object?> get props => [homeId, item];
}
