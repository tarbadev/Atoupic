import 'dart:math';

import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

List<Middleware<ApplicationState>> createApplicationMiddleware() => [
      TypedMiddleware<ApplicationState, StartSoloGameAction>(startSoloGame),
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
      TypedMiddleware<ApplicationState, EndCardRoundAction>(endCardRound),
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

  atoupicGame.setDomainPlayers(gameContext.players);
  atoupicGame.visible = true;

  store.dispatch(SetRealPlayerAction(
      gameContext.players.firstWhere((player) => player.isRealPlayer)));
  store.dispatch(StartTurnAction(gameContext));

  next(action);
}

void startTurn(
  Store<ApplicationState> store,
  StartTurnAction action,
  NextDispatcher next,
) {
  final container = Container();
  final AtoupicGame atoupicGame = container.resolve();
  final CardService cardService = container<CardService>()..initializeCards();

  action.gameContext.players
      .forEach((player) => player.cards = cardService.distributeCards(5));
  action.gameContext.players
      .firstWhere((player) => player.isRealPlayer)
      .initializeCards();

  action.gameContext.players.forEach(
      (player) => atoupicGame.addPlayerCards(player.cards, player.position));

  final card = cardService.distributeCards(1).first;

  action.gameContext.lastTurn.card = card;

  store.dispatch(SetGameContextAction(action.gameContext));
  store.dispatch(SetTurnAction(action.gameContext.lastTurn.number));
  store.dispatch(SetTakeOrPassCard(card));
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
  final AtoupicGame atoupicGame = container.resolve();
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

  atoupicGame.setPlayerPassed(action.player.position);

  store.dispatch(SetGameContextAction(gameContext));

  next(action);
}

void takeDecision(
  Store<ApplicationState> store,
  TakeDecisionAction action,
  NextDispatcher next,
) {
  final container = Container();
  final AtoupicGame atoupicGame = container.resolve();
  final GameService gameService = container<GameService>();
  final CardService cardService = container<CardService>();

  var gameContext =
      gameService.read().setDecision(action.player, Decision.Take);

  action.player.cards.add(gameContext.lastTurn.card);
  var takerCards = cardService.distributeCards(2);
  action.player.cards.addAll(takerCards);

  atoupicGame.setTrumpColor(action.color, action.player.position);
  atoupicGame.addPlayerCards(takerCards, action.player.position);

  gameContext.players.forEach((player) {
    if (player != action.player) {
      var newCards = cardService.distributeCards(3);
      player.cards.addAll(newCards);
      atoupicGame.addPlayerCards(newCards, player.position);
    }
  });
  var realPlayer =
      gameContext.players.firstWhere((player) => player.isRealPlayer);
  realPlayer.initializeCards();

  atoupicGame.resetPlayersPassed();
  atoupicGame.resetRealPlayersCards(realPlayer.cards);

  store.dispatch(SetGameContextAction(gameContext));
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
      final container = Container();
      AtoupicGame atoupicGame = container.resolve();
      atoupicGame.realPlayerCanChooseCard(
        true,
        possiblePlayableCards:
            action.context.getPossibleCardsToPlay(nextPlayer),
      );
    } else {
      store.dispatch(ChooseCardForAiAction(
          action.context.getPossibleCardsToPlay(nextPlayer), nextPlayer));
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
  final AtoupicGame atoupicGame = container<AtoupicGame>();
  final GameService gameService = container<GameService>();

  GameContext gameContext = gameService.read();
  gameContext = gameContext.setCardDecision(action.card, action.player);

  atoupicGame.setLastCardPlayed(action.card, action.player.position);
  atoupicGame.realPlayerCanChooseCard(false);

  store.dispatch(SetGameContextAction(gameContext));
  store.dispatch(ChooseCardDecisionAction(gameContext));

  next(action);
}

void chooseCardForAi(
  Store<ApplicationState> store,
  ChooseCardForAiAction action,
  NextDispatcher next,
) {
  var card = action
      .possibleCardsToPlay[Random().nextInt(action.possibleCardsToPlay.length)];

  store.dispatch(SetCardDecisionAction(
    card,
    action.player,
  ));

  next(action);
}

void endCardRound(
  Store<ApplicationState> store,
  EndCardRoundAction action,
  NextDispatcher next,
) {
  final container = Container();
  final AtoupicGame atoupicGame = container<AtoupicGame>();

  atoupicGame.resetLastPlayedCards();

  store.dispatch(StartCardRoundAction(action.context));

  next(action);
}
