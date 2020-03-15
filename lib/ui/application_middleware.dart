import 'dart:math';

import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

List<Middleware<ApplicationState>> createApplicationMiddleware() => [
      TypedMiddleware<ApplicationState, StartSoloGameAction>(startSoloGame),
      TypedMiddleware<ApplicationState, StartTurnAction>(startTurn),
      TypedMiddleware<ApplicationState, TakeOrPassDecisionAction>(takeOrPassDecision),
      TypedMiddleware<ApplicationState, PassDecisionAction>(passDecision),
      TypedMiddleware<ApplicationState, TakeDecisionAction>(takeDecision),
      TypedMiddleware<ApplicationState, StartCardRoundAction>(startCardRound),
      TypedMiddleware<ApplicationState, ChooseCardDecisionAction>(chooseCardDecision),
      TypedMiddleware<ApplicationState, SetCardDecisionAction>(setCardDecision),
      TypedMiddleware<ApplicationState, ChooseCardForAiAction>(chooseCardForAi),
      TypedMiddleware<ApplicationState, EndCardRoundAction>(endCardRound),
      TypedMiddleware<ApplicationState, EndTurnAction>(endTurn),
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

  store.dispatch(
      SetRealPlayerAction(gameContext.players.firstWhere((player) => player.isRealPlayer)));
  store.dispatch(StartTurnAction(turnAlreadyCreated: true));

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
  final GameService gameService = container<GameService>();

  GameContext gameContext =
      action.turnAlreadyCreated ? gameService.read() : gameService.read().nextTurn();

  atoupicGame.resetPlayersPassed();
  atoupicGame.resetTrumpColor();
  atoupicGame.resetPlayersCards();

  gameContext.players.forEach((player) => player.cards = cardService.distributeCards(5));
  gameContext.players.firstWhere((player) => player.isRealPlayer).sortCards();

  gameContext.players
      .forEach((player) => atoupicGame.addPlayerCards(player.cards, player.position));

  final card = cardService.distributeCards(1).first;

  gameContext.lastTurn.card = card;

  store.dispatch(SetCurrentTurnAction(gameContext.lastTurn));
  gameService.save(gameContext);
  store.dispatch(SetTurnAction(gameContext.lastTurn.number));
  store.dispatch(SetTakeOrPassCard(card));
  store.dispatch(TakeOrPassDecisionAction(gameContext.nextPlayer()));

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

  atoupicGame.setPlayerPassed(action.player.position);

  var gameContext = gameService.read().setDecision(action.player, Decision.Pass);
  var nextPlayer = gameContext.nextPlayer();
  if (nextPlayer == null && gameContext.lastTurn.round == 2) {
    store.dispatch(StartTurnAction());
  } else {
    if (nextPlayer == null) {
      atoupicGame.resetPlayersPassed();
      gameContext = gameContext.nextRound();
      nextPlayer = gameContext.nextPlayer();
    }

    store.dispatch(TakeOrPassDecisionAction(nextPlayer));
  }

  gameService.save(gameContext);

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

  var gameContext = gameService.read().setDecision(action.player, Decision.Take);

  action.player.cards.add(gameContext.lastTurn.card);
  var takerCards = cardService.distributeCards(2);
  action.player.cards.addAll(takerCards);

  gameContext.lastTurn.trumpColor = action.color;
  atoupicGame.setTrumpColor(action.color, action.player.position);
  atoupicGame.addPlayerCards(takerCards, action.player.position);

  gameContext.players.forEach((player) {
    if (player != action.player) {
      var newCards = cardService.distributeCards(3);
      player.cards.addAll(newCards);
      atoupicGame.addPlayerCards(newCards, player.position);
    }
  });
  var realPlayer = gameContext.players.firstWhere((player) => player.isRealPlayer);
  realPlayer.sortCards(trumpColor: action.color);

  atoupicGame.resetPlayersPassed();
  atoupicGame.replaceRealPlayersCards(realPlayer.cards);

  gameService.save(gameContext);
  store.dispatch(StartCardRoundAction(gameContext));

  next(action);
}

void startCardRound(
  Store<ApplicationState> store,
  StartCardRoundAction action,
  NextDispatcher next,
) {
  final container = Container();
  final GameService gameService = container<GameService>();
  var newContext = action.context.newCardRound();

  gameService.save(newContext);
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
    final container = Container();
    var possibleCardsToPlay = action.context.getPossibleCardsToPlay(nextPlayer);
    if (nextPlayer.isRealPlayer) {
      AtoupicGame atoupicGame = container.resolve();
      atoupicGame.realPlayerCanChooseCard(
        true,
        possiblePlayableCards: possibleCardsToPlay,
      );
    } else {
      AiService aiService = container.resolve();
      var chosenCard = aiService.chooseCard(
        possibleCardsToPlay,
        action.context.lastTurn,
        nextPlayer.position.isVertical,
      );
      store.dispatch(SetCardDecisionAction(chosenCard, nextPlayer));
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

  atoupicGame.setLastCardPlayed(
    action.card,
    action.player.position,
    () => store.dispatch(ChooseCardDecisionAction(gameContext)),
  );
  atoupicGame.realPlayerCanChooseCard(false);

  gameService.save(gameContext);

  next(action);
}

void chooseCardForAi(
  Store<ApplicationState> store,
  ChooseCardForAiAction action,
  NextDispatcher next,
) {
  var card = action.possibleCardsToPlay[Random().nextInt(action.possibleCardsToPlay.length)];

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

  if (action.context.lastTurn.cardRounds.length < 8) {
    store.dispatch(StartCardRoundAction(action.context));
  } else {
    store.dispatch(EndTurnAction(action.context));
  }

  next(action);
}

void endTurn(
  Store<ApplicationState> store,
  EndTurnAction action,
  NextDispatcher next,
) {
  final container = Container();
  final GameService gameService = container<GameService>();
  action.context.lastTurn.calculatePoints(action.context.players);

  gameService.save(action.context);

  store.dispatch(SetTurnResultAction(action.context.lastTurn.turnResult));

  next(action);
}