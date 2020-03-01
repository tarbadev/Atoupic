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
  final CardService cardService = container<CardService>();
  final GameService gameService = container<GameService>();
  final card = cardService.distributeCards(1).first;

  action.gameContext.lastTurn.card = card;

  gameService.save(action.gameContext);

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
    var newGameContext = gameService.save(gameContext);
    store.dispatch(StartTurnAction(newGameContext));
    store.dispatch(SetPlayersInGame(newGameContext));
  } else {
    if (nextPlayer == null) {
      gameContext = gameContext.nextRound();
      nextPlayer = gameContext.nextPlayer();
    }

    var newGameContext = gameService.save(gameContext);

    store.dispatch(TakeOrPassDecisionAction(nextPlayer));
    store.dispatch(SetPlayersInGame(newGameContext));
  }

  next(action);
}
