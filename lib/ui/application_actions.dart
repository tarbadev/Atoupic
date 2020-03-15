import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
import 'package:atoupic/ui/entity/score_display.dart';
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

class StartSoloGameAction extends Equatable {
  @override
  List<Object> get props => ['StartSoloGameAction'];
}

class StartTurnAction extends Equatable {
  final bool turnAlreadyCreated;

  StartTurnAction({this.turnAlreadyCreated = false});

  @override
  List<Object> get props => [turnAlreadyCreated];
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

class StartCardRoundAction extends Equatable {
  final GameContext context;

  StartCardRoundAction(this.context);

  @override
  List<Object> get props => [context];
}

class EndCardRoundAction extends Equatable {
  final GameContext context;

  EndCardRoundAction(this.context);

  @override
  List<Object> get props => [context];
}

class EndTurnAction extends Equatable {
  final GameContext context;

  EndTurnAction(this.context);

  @override
  List<Object> get props => [context];
}

class ChooseCardDecisionAction extends Equatable {
  final GameContext context;

  ChooseCardDecisionAction(this.context);

  @override
  List<Object> get props => [context];
}

class SetCardDecisionAction extends Equatable {
  final Card card;
  final Player player;

  SetCardDecisionAction(this.card, this.player);

  @override
  List<Object> get props => [card, player];
}

class ChooseCardForAiAction extends Equatable {
  final List<Card> possibleCardsToPlay;
  final Player player;

  ChooseCardForAiAction(this.possibleCardsToPlay, this.player);

  @override
  List<Object> get props => [possibleCardsToPlay, player];

  @override
  String toString() {
    return 'ChooseCardForAiAction{possibleCardsToPlay: $possibleCardsToPlay, player: $player}';
  }
}

class SetTurnResultAction extends Equatable {
  final TurnResult turnResult;

  SetTurnResultAction(this.turnResult);

  @override
  List<Object> get props => [turnResult];

  @override
  String toString() {
    return 'SetTurnResultAction{turnResult: $turnResult}';
  }
}

class SetScoreAction extends Equatable {
  final ScoreDisplay newScore;

  SetScoreAction(this.newScore);

  @override
  List<Object> get props => [newScore];
}

class SetCurrentTurnAction extends Equatable {
  final Turn turn;

  SetCurrentTurnAction(this.turn);

  @override
  List<Object> get props => [turn];
}
