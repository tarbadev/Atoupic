import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class Start extends GameEvent {
  final List<Player> players;

  Start(this.players);

  @override
  List<Object> get props => [players];

  @override
  String toString() {
    return 'Start{players: $players}';
  }
}

class NewTurn extends GameEvent {
  final List<Player> players;

  NewTurn(this.players);

  @override
  List<Object> get props => [players];

  @override
  String toString() {
    return 'NewTurn{players: $players}';
  }
}