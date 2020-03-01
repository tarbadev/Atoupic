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
      TypedMiddleware<ApplicationState, SetPlayersInGame>(setPlayersInGame),
      TypedMiddleware<ApplicationState, StartTurnAction>(startTurn),
      TypedMiddleware<ApplicationState, TakeOrPassDecisionAction>(
          takeOrPassDecision),
      TypedMiddleware<ApplicationState, PassDecisionAction>(passDecision),
      TypedMiddleware<ApplicationState, TakeDecisionAction>(takeDecision),
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
  SetPlayersInGame action,
  NextDispatcher next,
) {
  final container = Container();
  final AtoupicGame atoupicGame = container.resolve();

  atoupicGame.setPlayers(action.context.players
      .map((player) => PlayerComponent.fromPlayer(
            player,
            passed: action.context.turns.last.playerDecisions[player] ==
                Decision.Pass,
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
  store.dispatch(SetPlayersInGame(action.gameContext));
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
  store.dispatch(SetPlayersInGame(gameContext));

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
  store.dispatch(SetPlayersInGame(gameContext));

  next(action);
}
