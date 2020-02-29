import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:redux/redux.dart';

ApplicationState applicationReducer(ApplicationState state, action) =>
    ApplicationState(
      setShowTakeOrPassDialogReducer(state.showTakeOrPassDialog, action),
      setCurrentViewReducer(state.currentView, action),
      setTakeOrPassCardReducer(state.takeOrPassCard, action),
      setRealPlayerReducer(state.realPlayer, action),
    );

final Reducer<bool> setShowTakeOrPassDialogReducer = combineReducers([
  TypedReducer<bool, ShowTakeOrPassDialogAction>(_setShowTakeOrPassDialog),
]);

bool _setShowTakeOrPassDialog(bool show, ShowTakeOrPassDialogAction action) => action.show;

final Reducer<AtoupicView> setCurrentViewReducer = combineReducers([
  TypedReducer<AtoupicView, SetCurrentViewAction>(_setCurrentView),
]);

AtoupicView _setCurrentView(AtoupicView show, SetCurrentViewAction action) => action.view;

final Reducer<Card> setTakeOrPassCardReducer = combineReducers([
  TypedReducer<Card, SetTakeOrPassCard>(_setTakeOrPassCard),
]);

Card _setTakeOrPassCard(Card card, SetTakeOrPassCard action) => action.newCard;

final Reducer<Player> setRealPlayerReducer = combineReducers([
  TypedReducer<Player, SetRealPlayerAction>(_setRealPlayer),
]);

Player _setRealPlayer(Player player, SetRealPlayerAction action) => action.player;