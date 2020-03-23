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
  String toString() => 'Start{players: $players}';
}

class NewTurn extends GameEvent {
  final List<Player> players;

  NewTurn(this.players);

  @override
  List<Object> get props => [players];

  @override
  String toString() => 'NewTurn{players: $players}';
}

class DisplayPlayerPassed extends GameEvent {
  final Position position;

  DisplayPlayerPassed(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() => 'DisplayPlayerPassed{position: $position}';
}
