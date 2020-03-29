import 'package:atoupic/bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';

void main() {
  group('AppBloc', () {
    AppBloc appBloc;

    setUp(() {
      appBloc = AppBloc();
    });

    tearDown((){
      appBloc.close();
    });

    test('initial state is NotStarted', () {
      expect(appBloc.initialState, HomeAppState());
    });

    blocTest<AppBloc, AppEvent, AppState>(
      'emits InGameAppState() state on GameInitialized event',
      build: () async => appBloc,
      act: (bloc) async => appBloc.add(GameInitialized()),
      expect: [InGameAppState()],
    );
  });
}
