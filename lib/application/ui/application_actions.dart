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

class TakeOrPassAction extends Equatable {
  final GameContext gameContext;

  TakeOrPassAction(this.gameContext);

  @override
  List<Object> get props => [gameContext];
}

class TakeOrPassDecisionAction extends Equatable {
  final Player player;

  TakeOrPassDecisionAction(this.player);

  @override
  List<Object> get props => [this.player];
}

class PassDecisionAction extends Equatable {
  final Player player;

  PassDecisionAction(this.player);

  @override
  List<Object> get props => [this.player];
}

class SetTakeOrPassCard extends Equatable {
  final Card newCard;

  SetTakeOrPassCard(this.newCard);

  @override
  List<Object> get props => [this.newCard];
}