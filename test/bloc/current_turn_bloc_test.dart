import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';

void main() {
  group('CurrentTurnBloc', () {
    CurrentTurnBloc currentTurnBloc;

    setUp(() {
      currentTurnBloc = CurrentTurnBloc(Mocks.gameBloc);
    });

    tearDown((){
      currentTurnBloc.close();
    });

    test('initial state is 0', () {
      expect(currentTurnBloc.initialState, 0);
    });

    blocTest<CurrentTurnBloc, CurrentTurnEvent, int>(
      'emits turn number on UpdateCurrentTurn event',
      build: () async => currentTurnBloc,
      act: (bloc) async => bloc.add(UpdateCurrentTurn(12)),
      expect: [12],
    );

    blocTest<CurrentTurnBloc, CurrentTurnEvent, int>(
      'listens to gameBloc and emits turn number on UpdateCurrentTurn event',
      build: () async {
        whenListen(Mocks.gameBloc, Stream.fromIterable([TurnCreated(Turn(45, null))]));
        return CurrentTurnBloc(Mocks.gameBloc);
      },
      expect: [45],
    );
  });
}