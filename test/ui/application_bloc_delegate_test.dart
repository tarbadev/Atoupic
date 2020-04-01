import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';

void main() {
  group('On SoloGameInitialized', () {
    test('triggers NewTurn with turnAlreadyCreated true', () {
      ApplicationBlocDelegate applicationBlocDelegate = ApplicationBlocDelegate();

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            nextState: SoloGameInitialized(),
            currentState: NotStarted(),
            event: StartSoloGame(),
          ));

      verify(Mocks.gameBloc.add(NewTurn(turnAlreadyCreated: true)));
    });
  });
}
