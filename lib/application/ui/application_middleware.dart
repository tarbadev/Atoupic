import 'dart:math';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

List<Middleware<ApplicationState>> createApplicationMiddleware() => [
      TypedMiddleware<ApplicationState, StartSoloGameAction>(startSoloGame),
      TypedMiddleware<ApplicationState, SetPlayersInGameAction>(
          setPlayersInGame),
      TypedMiddleware<ApplicationState, StartTurnAction>(startTurn),
      TypedMiddleware<ApplicationState, TakeOrPassDecisionAction>(
          takeOrPassDecision),
      TypedMiddleware<ApplicationState, PassDecisionAction>(passDecision),
      TypedMiddleware<ApplicationState, TakeDecisionAction>(takeDecision),
      TypedMiddleware<ApplicationState, StartCardRoundAction>(startCardRound),
      TypedMiddleware<ApplicationState, ChooseCardDecisionAction>(
          chooseCardDecision),
      TypedMiddleware<ApplicationState, SetCardDecisionAction>(setCardDecision),
      TypedMiddleware<ApplicationState, ChooseCardForAiAction>(chooseCardForAi),
    ];

void startSoloGame(
  Store<ApplicationState> store,
  StartSoloGameAction action,
  NextDispatcher next,
) {
  final container = Container();
  final atoupicGame = container<AtoupicGame>();
  final GameService gameService = container<GameService>();

  final gameContext = gameService.startSoloGame();

  store.dispatch(SetRealPlayerAction(
      gameContext.players.firstWhere((player) => player.isRealPlayer)));
  store.dispatch(StartTurnAction(gameContext));

  atoupicGame.visible = true;

  next(action);
}

void setPlayersInGame(
  Store<ApplicationState> store,
  SetPlayersInGameAction action,
  NextDispatcher next,
) {
  final container = Container();
  final AtoupicGame atoupicGame = container.resolve();
  final bool didTake =
      action.context.lastTurn.playerDecisions.containsValue(Decision.Take);

  atoupicGame.setPlayers(action.context.players
      .map((player) => PlayerComponent.fromPlayer(
            player,
            passed: !didTake &&
                action.context.lastTurn.playerDecisions[player.position] ==
                    Decision.Pass,
            onCardSelected: action.realPlayerCanChooseCard
                ? (Card card) =>
                    store.dispatch(SetCardDecisionAction(card, player))
                : null,
            lastPlayed: action.context.lastTurn.lastCardRound == null
                ? null
                : action.context.lastTurn.lastCardRound.playedCards[player.position],
          ))
      .toList());

  next(action);
}

void startTurn(
  Store<ApplicationState> store,
  StartTurnAction action,
  NextDispatcher next,
) {
  final container = Container();
  final CardService cardService = container<CardService>()..initializeCards();

  action.gameContext.players
      .forEach((player) => player.cards = cardService.distributeCards(5));
  action.gameContext.players
      .firstWhere((player) => player.isRealPlayer)
      .initializeCards();

  final card = cardService.distributeCards(1).first;

  action.gameContext.lastTurn.card = card;

  store.dispatch(SetGameContextAction(action.gameContext));
  store.dispatch(SetTurnAction(action.gameContext.lastTurn.number));
  store.dispatch(SetTakeOrPassCard(card));
  store.dispatch(SetPlayersInGameAction(action.gameContext));
  store.dispatch(TakeOrPassDecisionAction(action.gameContext.nextPlayer()));

  next(action);
}

void takeOrPassDecision(
  Store<ApplicationState> store,
  TakeOrPassDecisionAction action,
  NextDispatcher next,
) {
  if (action.player.isRealPlayer) {
    store.dispatch(ShowTakeOrPassDialogAction(true));
  } else {
    store.dispatch(PassDecisionAction(action.player));
  }

  next(action);
}

void passDecision(
  Store<ApplicationState> store,
  PassDecisionAction action,
  NextDispatcher next,
) {
  final container = Container();
  final GameService gameService = container<GameService>();

  var gameContext =
      gameService.read().setDecision(action.player, Decision.Pass);
  var nextPlayer = gameContext.nextPlayer();
  if (nextPlayer == null && gameContext.lastTurn.round == 2) {
    gameContext = gameContext.nextTurn();
    store.dispatch(StartTurnAction(gameContext));
  } else {
    if (nextPlayer == null) {
      gameContext = gameContext.nextRound();
      nextPlayer = gameContext.nextPlayer();
    }

    store.dispatch(TakeOrPassDecisionAction(nextPlayer));
  }

  store.dispatch(SetGameContextAction(gameContext));
  store.dispatch(SetPlayersInGameAction(gameContext));

  next(action);
}

void takeDecision(
  Store<ApplicationState> store,
  TakeDecisionAction action,
  NextDispatcher next,
) {
  final container = Container();
  final GameService gameService = container<GameService>();
  final CardService cardService = container<CardService>();

  var gameContext =
      gameService.read().setDecision(action.player, Decision.Take);

  action.player.cards.add(gameContext.lastTurn.card);
  action.player.cards.addAll(cardService.distributeCards(2));

  gameContext.players.forEach((player) {
    if (player != action.player) {
      player.cards.addAll(cardService.distributeCards(3));
    }
  });
  gameContext.players
      .firstWhere((player) => player.isRealPlayer)
      .initializeCards();

  store.dispatch(SetGameContextAction(gameContext));
  store.dispatch(SetPlayersInGameAction(gameContext));
  store.dispatch(StartCardRoundAction(gameContext));

  next(action);
}

void startCardRound(
  Store<ApplicationState> store,
  StartCardRoundAction action,
  NextDispatcher next,
) {
  var newContext = action.context.newCardRound();

  store.dispatch(SetGameContextAction(newContext));
  store.dispatch(ChooseCardDecisionAction(newContext));

  next(action);
}

void chooseCardDecision(
  Store<ApplicationState> store,
  ChooseCardDecisionAction action,
  NextDispatcher next,
) {
  var nextPlayer = action.context.nextCardPlayer();

  if (nextPlayer == null) {
    store.dispatch(EndCardRoundAction(action.context));
  } else {
    if (nextPlayer.isRealPlayer) {
      store.dispatch(SetPlayersInGameAction(action.context,
          realPlayerCanChooseCard: true));
    } else {
      store.dispatch(ChooseCardForAiAction(nextPlayer));
    }
  }

  next(action);
}

void setCardDecision(
  Store<ApplicationState> store,
  SetCardDecisionAction action,
  NextDispatcher next,
) {
  final container = Container();
  final GameService gameService = container<GameService>();

  GameContext gameContext = gameService.read();
  gameContext = gameContext.setCardDecision(action.card, action.player);

  store.dispatch(SetPlayersInGameAction(gameContext));
  store.dispatch(SetGameContextAction(gameContext));
  store.dispatch(ChooseCardDecisionAction(gameContext));

  next(action);
}

void chooseCardForAi(
  Store<ApplicationState> store,
  ChooseCardForAiAction action,
  NextDispatcher next,
) {
  var player = action.player;

  store.dispatch(SetCardDecisionAction(
    player.cards[Random().nextInt(player.cards.length)],
    player,
  ));

  next(action);
}
