import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:equatable/equatable.dart';

abstract class TakeOrPassEvent extends Equatable {
  const TakeOrPassEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class RealPlayerTurn extends TakeOrPassEvent {
  final Player player;
  final Turn turn;

  RealPlayerTurn(this.player, this.turn);

  @override
  List<Object> get props => [player, turn];
}

class ComputerPlayerTurn extends TakeOrPassEvent {
  final Player player;
  final Turn turn;

  ComputerPlayerTurn(this.player, this.turn);

  @override
  List<Object> get props => [player, turn];
}

class Take extends TakeOrPassEvent {
  final Player player;
  final CardColor color;

  Take(this.player, this.color);

  @override
  List<Object> get props => [this.player, this.color];
}

class Pass extends TakeOrPassEvent {
  final Player player;

  Pass(this.player);

  @override
  List<Object> get props => [this.player];
}