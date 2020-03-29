import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class CurrentTurnBloc extends Bloc<CurrentTurnEvent, int> {
  final GameBloc _gameBloc;
  StreamSubscription _gameSubscription;

  CurrentTurnBloc(this._gameBloc) {
    _gameSubscription = _gameBloc.listen((state) {
      if (state is TurnCreated) {
        add(UpdateCurrentTurn(state.turn.number));
      }
    });
  }

  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(
    CurrentTurnEvent event,
  ) async* {
    if (event is UpdateCurrentTurn) {
      yield event.turnNumber;
    }
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}
