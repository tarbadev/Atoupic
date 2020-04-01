import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => HomeAppState();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is GameInitialized) {
      yield InGameAppState();
    } else {
      if (event is GameFinished) {
        yield HomeAppState();
      }
    }
  }
}
