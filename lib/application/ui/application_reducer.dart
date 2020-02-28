import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:redux/redux.dart';

ApplicationState applicationReducer(ApplicationState state, action) =>
    ApplicationState(
      setShowTakeOrPassDialogReducer(state.showTakeOrPassDialog, action),
    );

final Reducer<bool> setShowTakeOrPassDialogReducer = combineReducers([
  TypedReducer<bool, ShowTakeOrPassDialogAction>(_setShowTakeOrPassDialog),
]);

bool _setShowTakeOrPassDialog(bool show, ShowTakeOrPassDialogAction action) => action.show;