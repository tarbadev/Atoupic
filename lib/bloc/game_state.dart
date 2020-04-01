import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
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
class CreatingCardRound extends GameState {}
class CardAnimationStarted extends GameState {}
class CardAnimationEnded extends GameState {}
class TurnEnded extends GameState {
  final TurnResult turnResult;
  final bool isGameOver;

  TurnEnded(this.turnResult, {this.isGameOver = false});

  @override
  List<Object> get props => [turnResult, isGameOver];

  @override
  String toString() {
    return 'TurnEnded{turnResult: $turnResult, isGameOver: $isGameOver}';
  }
}

class GameScoreUpdated extends GameState {
  final int usScore;
  final int themScore;

  GameScoreUpdated(this.usScore, this.themScore);

  @override
  List<Object> get props => [usScore, themScore];

  @override
  String toString() {
    return 'GameScoreUpdated{usScore: $usScore, themScore: $themScore}';
  }
}

class GameEnded extends GameState {
  final int usScore;
  final int themScore;

  GameEnded(this.usScore, this.themScore);

  @override
  List<Object> get props => [usScore, themScore];

  @override
  String toString() {
    return 'GameEnded{usScore: $usScore, themScore: $themScore}';
  }
}

class CardRoundCreated extends GameState {
  final GameContext gameContext;

  CardRoundCreated(this.gameContext);

  @override
  List<Object> get props => [gameContext];

  @override
  String toString() {
    return 'CardRoundCreated{gameContext: $gameContext}';
  }
}

class CardPlayed extends GameState {
  final GameContext gameContext;

  CardPlayed(this.gameContext);

  @override
  List<Object> get props => [gameContext];

  @override
  String toString() {
    return 'CardPlayed{gameContext: $gameContext}';
  }
}