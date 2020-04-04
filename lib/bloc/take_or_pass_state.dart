import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class TakeOrPassState extends Equatable {
  const TakeOrPassState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class HideTakeOrPassDialog extends TakeOrPassState {}
class PlayerTook extends TakeOrPassState {}
class PlayerPassed extends TakeOrPassState {
  final GameContext gameContext;

  PlayerPassed(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}

class ShowTakeOrPassDialog extends TakeOrPassState {
  final Player player;
  final Card card;
  final bool isRound2;

  ShowTakeOrPassDialog(this.player, this.card, this.isRound2);

  @override
  List<Object> get props => [player, card, isRound2];
}

class NoOneTook extends TakeOrPassState {}
