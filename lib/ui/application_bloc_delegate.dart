import 'package:atoupic/bloc/bloc.dart';
import 'package:bloc/bloc.dart';

class ApplicationBlocDelegate extends BlocDelegate {
  GameBloc _gameBloc;
  TakeOrPassDialogBloc _takeOrPassDialogBloc;

  ApplicationBlocDelegate(this._gameBloc, this._takeOrPassDialogBloc);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (transition.nextState is SoloGameInitialized) {
      _gameBloc.add(NewTurn(turnAlreadyCreated: true));
    } else if (transition.nextState is TurnCreated) {
      if (transition.nextState.turn.firstPlayer.isRealPlayer) {
        _takeOrPassDialogBloc
            .add(RealPlayerTurn(transition.nextState.turn.firstPlayer, transition.nextState.turn));
      } else {
        _takeOrPassDialogBloc.add(Pass(transition.nextState.turn.firstPlayer));
      }
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}
