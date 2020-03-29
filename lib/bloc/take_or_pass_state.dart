import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class TakeOrPassState extends Equatable {
  const TakeOrPassState();

  @override
  List<Object> get props => [];
}

class InitialTakeOrPassState extends TakeOrPassState {}
class PlayerTook extends TakeOrPassState {
  final Player player;

  PlayerTook(this.player);

  @override
  List<Object> get props => [player];

  @override
  String toString() {
    return 'PlayerTook{player: $player}';
  }
}
class PlayerPassed extends TakeOrPassState {
  final GameContext gameContext;

  PlayerPassed(this.gameContext);

  @override
  List<Object> get props => [gameContext];

  @override
  String toString() {
    return 'PlayerPassed{gameContext: $gameContext}';
  }
}

class ShowTakeOrPassDialog extends TakeOrPassState {
  final Player player;
  final Card card;

  ShowTakeOrPassDialog(this.player, this.card);

  @override
  List<Object> get props => [player, card];

  @override
  String toString() {
    return 'ShowTakeOrPassDialog{player: $player, card: $card}';
  }
}

class NoOneTook extends TakeOrPassState {}
