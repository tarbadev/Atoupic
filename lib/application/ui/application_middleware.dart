import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

List<Middleware<ApplicationState>> createApplicationMiddleware() {
  List<Middleware<ApplicationState>> applicationMiddleware = [
    TypedMiddleware<ApplicationState, StartSoloGameAction>(startSoloGame),
    TypedMiddleware<ApplicationState, SetPlayersInGame>(setPlayersInGame),
    TypedMiddleware<ApplicationState, TakeOrPassAction>(takeOrPass),
    TypedMiddleware<ApplicationState, TakeOrPassDecisionAction>(takeOrPassDecision),
    TypedMiddleware<ApplicationState, PassDecisionAction>(passDecision),
  ];

  return applicationMiddleware;
}

void startSoloGame(
  Store<ApplicationState> store,
  StartSoloGameAction action,
  NextDispatcher next,
) {
  final container = Container();
  final atoupicGame = container<AtoupicGame>();
  final GameService gameService = container<GameService>();

  final gameContext = gameService.startSoloGame();

  store.dispatch(SetPlayersInGame(gameContext));
  store.dispatch(TakeOrPassAction(gameContext));

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

void takeOrPass(
  Store<ApplicationState> store,
  TakeOrPassAction action,
  NextDispatcher next,
) {
  final container = Container();
  final CardService cardService = container<CardService>();
  final GameService gameService = container<GameService>();
  final card = cardService.distributeCards(1).first;

  action.gameContext.turns.last.card = card;

  gameService.save(action.gameContext);

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
  final GameService gameService = container<GameService>();

  var gameContext = gameService.read();
  var newGameContext = gameService.save(gameContext.setDecision(action.player, Decision.Pass));

  store.dispatch(TakeOrPassDecisionAction(newGameContext.nextPlayer()));
  store.dispatch(SetPlayersInGame(newGameContext));

  next(action);
}
