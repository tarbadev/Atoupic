import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/entity/score_display.dart';
import 'package:redux/redux.dart';

ApplicationState applicationReducer(ApplicationState state, action) => ApplicationState(
      setShowTakeOrPassDialogReducer(state.showTakeOrPassDialog, action),
      setCurrentViewReducer(state.currentView, action),
      setRealPlayerReducer(state.realPlayer, action),
      setCurrentTurnReducer(state.currentTurn, action),
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

final Reducer<Turn> setCurrentTurnReducer = combineReducers([
  TypedReducer<Turn, SetCurrentTurnAction>(_setCurrentTurn),
]);

Turn _setCurrentTurn(Turn turn, SetCurrentTurnAction action) => action.turn;