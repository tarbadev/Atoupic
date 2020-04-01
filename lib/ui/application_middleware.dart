import 'dart:math';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/bloc/game_bloc.dart';
import 'package:atoupic/bloc/game_event.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

List<Middleware<ApplicationState>> createApplicationMiddleware() => [
      TypedMiddleware<ApplicationState, StartCardRoundAction>(startCardRound),
      TypedMiddleware<ApplicationState, ChooseCardDecisionAction>(chooseCardDecision),
      TypedMiddleware<ApplicationState, SetCardDecisionAction>(setCardDecision),
      TypedMiddleware<ApplicationState, ChooseCardForAiAction>(chooseCardForAi),
      TypedMiddleware<ApplicationState, EndCardRoundAction>(endCardRound),
      TypedMiddleware<ApplicationState, EndTurnAction>(endTurn),
      TypedMiddleware<ApplicationState, EndGameAction>(endGame),
    ];

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
      GameBloc gameBloc = container.resolve();
      gameBloc.add(RealPlayerCanChooseCard(possibleCardsToPlay));
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
  final GameService gameService = container<GameService>();
  final GameBloc gameBloc = container<GameBloc>();

  GameContext gameContext = gameService.read();
  gameContext = gameContext.setCardDecision(action.card, action.player);

  gameService.save(gameContext);

  gameBloc.add(SetPlayedCard(
    action.card,
    action.player.position,
    () => store.dispatch(ChooseCardDecisionAction(gameContext)),
  ));

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
  final GameBloc gameBloc = container<GameBloc>();

  gameBloc.add(ResetLastPlayedCards());

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

  store.dispatch(SetCurrentTurnAction(action.context.lastTurn));
  store.dispatch(SetTurnResultAction(action.context.lastTurn.turnResult));

  next(action);
}

void endGame(
  Store<ApplicationState> store,
  EndGameAction action,
  NextDispatcher next,
) {
  next(action);
}
