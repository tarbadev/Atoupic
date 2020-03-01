import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

import 'atoupic_app.dart';

class ShowTakeOrPassDialogAction extends Equatable {
  final bool show;

  ShowTakeOrPassDialogAction(this.show);

  @override
  List<Object> get props => [show];
}

class SetCurrentViewAction extends Equatable {
  final AtoupicView view;

  SetCurrentViewAction(this.view);

  @override
  List<Object> get props => [view];
}

class SetPlayersInGame extends Equatable {
  final GameContext context;

  SetPlayersInGame(this.context);

  @override
  List<Object> get props => [context];
}

class StartSoloGameAction extends Equatable {
  @override
  List<Object> get props => ['StartSoloGameAction'];
}

class StartTurnAction extends Equatable {
  final GameContext gameContext;

  StartTurnAction(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}

class TakeOrPassDecisionAction extends Equatable {
  final Player player;

  TakeOrPassDecisionAction(this.player);

  @override
  List<Object> get props => [this.player];
}

class DecisionAction extends Equatable {
  final Player player;

  DecisionAction(this.player);

  @override
  List<Object> get props => [this.player];
}

class PassDecisionAction extends DecisionAction {
  PassDecisionAction(Player player) : super(player);
}

class TakeDecisionAction extends DecisionAction {
  final CardColor color;

  TakeDecisionAction(Player player, this.color) : super(player);

  @override
  List<Object> get props => [this.player, this.color];
}

class SetTakeOrPassCard extends Equatable {
  final Card newCard;

  SetTakeOrPassCard(this.newCard);

  @override
  List<Object> get props => [this.newCard];
}

class SetRealPlayerAction extends Equatable {
  final Player player;

  SetRealPlayerAction(this.player);

  @override
  List<Object> get props => [this.player];
}

class SetTurnAction extends Equatable {
  final int newTurn;

  SetTurnAction(this.newTurn);

  @override
  List<Object> get props => [this.newTurn];
}

class SetGameContextAction extends Equatable {
  final GameContext newGameContext;

  SetGameContextAction(this.newGameContext);

  @override
  List<Object> get props => [this.newGameContext];

  @override
  String toString() {
    return 'SetGameContextAction{newGameContext: $newGameContext}';
  }
}