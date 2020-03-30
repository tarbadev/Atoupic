import 'package:atoupic/domain/entity/turn.dart';
import 'package:equatable/equatable.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

class NotStarted extends GameState {}
class Initialized extends GameState {}
class SoloGameInitialized extends GameState {}
class TurnCreated extends GameState {
  final Turn turn;

  TurnCreated(this.turn);

  @override
  List<Object> get props => [turn];

  @override
  String toString() {
    return 'TurnCreated{turn: $turn}';
  }
}
class CreatingTurn extends GameState {}
