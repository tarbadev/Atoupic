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

class HideTakeOrPass extends TakeOrPassState {}

class PlayerTook extends TakeOrPassState {}

class PlayerPassed extends TakeOrPassState {
  final GameContext gameContext;

  PlayerPassed(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}

class ShowTakeOrPassRound1 extends TakeOrPassState {
  final Player player;

  ShowTakeOrPassRound1(this.player);

  @override
  List<Object> get props => [player];
}

class ShowTakeOrPassRound2 extends TakeOrPassState {
  final Player player;

  ShowTakeOrPassRound2(this.player);

  @override
  List<Object> get props => [player];
}

class NoOneTook extends TakeOrPassState {}
