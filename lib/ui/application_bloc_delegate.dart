import 'package:atoupic/bloc/bloc.dart';
import 'package:bloc/bloc.dart';

class ApplicationBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (transition.nextState is SoloGameInitialized) {
      bloc.add(NewTurn(turnAlreadyCreated: true));
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}