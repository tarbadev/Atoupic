import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/entity/turn_result.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:atoupic/application/ui/entity/score_display.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

ApplicationState applicationReducer(ApplicationState state, action) => ApplicationState(
      setShowTakeOrPassDialogReducer(state.showTakeOrPassDialog, action),
      setCurrentViewReducer(state.currentView, action),
      setRealPlayerReducer(state.realPlayer, action),
      setGameContextReducer(state.gameContext, action),
      setTurnResultReducer(state.turnResult, action),
      setScoreReducer(state.score, action),
    );

final Reducer<bool> setShowTakeOrPassDialogReducer = combineReducers([
  TypedReducer<bool, ShowTakeOrPassDialogAction>(_setShowTakeOrPassDialog),
]);

bool _setShowTakeOrPassDialog(bool show, ShowTakeOrPassDialogAction action) => action.show;

final Reducer<AtoupicView> setCurrentViewReducer = combineReducers([
  TypedReducer<AtoupicView, SetCurrentViewAction>(_setCurrentView),
]);

AtoupicView _setCurrentView(AtoupicView show, SetCurrentViewAction action) => action.view;

final Reducer<Player> setRealPlayerReducer = combineReducers([
  TypedReducer<Player, SetRealPlayerAction>(_setRealPlayer),
]);

Player _setRealPlayer(Player player, SetRealPlayerAction action) => action.player;

final Reducer<GameContext> setGameContextReducer = combineReducers([
  TypedReducer<GameContext, SetGameContextAction>(setGameContext),
]);

GameContext setGameContext(
  GameContext currentGameContext,
  SetGameContextAction action,
) =>
    Container().resolve<GameService>().save(action.newGameContext);

final Reducer<TurnResult> setTurnResultReducer = combineReducers([
  TypedReducer<TurnResult, SetTurnResultAction>(_setTurnResult),
]);

TurnResult _setTurnResult(TurnResult turnResult, SetTurnResultAction action) => action.turnResult;

final Reducer<ScoreDisplay> setScoreReducer = combineReducers([
  TypedReducer<ScoreDisplay, SetScoreAction>(_setScore),
  TypedReducer<ScoreDisplay, SetTurnResultAction>(addToScore),
]);

ScoreDisplay _setScore(ScoreDisplay scoreDisplay, SetScoreAction action) => action.newScore;

ScoreDisplay addToScore(ScoreDisplay scoreDisplay, SetTurnResultAction action) =>
    action.turnResult == null
        ? scoreDisplay
        : ScoreDisplay(
            scoreDisplay.us + action.turnResult.verticalScore,
            scoreDisplay.them + action.turnResult.horizontalScore,
          );
