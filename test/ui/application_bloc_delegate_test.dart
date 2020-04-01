import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  ApplicationBlocDelegate applicationBlocDelegate;

  setUp(() {
    applicationBlocDelegate = ApplicationBlocDelegate(Mocks.gameBloc, Mocks.takeOrPassDialogBloc);
  });

  group('On SoloGameInitialized', () {
    test('triggers NewTurn with turnAlreadyCreated true', () {
      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: StartSoloGame(),
            nextState: SoloGameInitialized(),
          ));

      verify(Mocks.gameBloc.add(NewTurn(turnAlreadyCreated: true)));
    });
  });

  group('on TurnCreated', () {
    test('adds a Pass event when player is computer', () {
      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: SoloGameInitialized(),
            event: NewTurn(turnAlreadyCreated: true),
            nextState: TurnCreated(Turn(1, TestFactory.computerPlayer)),
          ));

      verify(Mocks.takeOrPassDialogBloc.add(Pass(TestFactory.computerPlayer)));
    });

    test('adds RealPlayerTurn event when player is real player', () {
      var card = Card(CardColor.Heart, CardHead.Ace);
      var turn = Turn(1, TestFactory.realPlayer)..card = card;

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: SoloGameInitialized(),
            event: NewTurn(turnAlreadyCreated: true),
            nextState: TurnCreated(turn),
          ));

      verify(Mocks.takeOrPassDialogBloc.add(RealPlayerTurn(TestFactory.realPlayer, turn)));
    });
  });
}
