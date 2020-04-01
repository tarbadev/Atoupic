import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/entity/score_display.dart';
import 'package:redux/redux.dart';

ApplicationState applicationReducer(ApplicationState state, action) => ApplicationState(
      setCurrentTurnReducer(state.currentTurn, action),
      setScoreReducer(state.score, action),
    );

final Reducer<ScoreDisplay> setScoreReducer = combineReducers([
  TypedReducer<ScoreDisplay, SetTurnResultAction>(addToScore),
]);

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
