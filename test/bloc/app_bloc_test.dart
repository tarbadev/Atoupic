import 'package:atoupic/bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

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
      act: (bloc) async => bloc.add(GameInitialized()),
      expect: [InGameAppState()],
    );

    blocTest<AppBloc, AppEvent, AppState>(
      'emits HomeAppState() state on GameFinished event',
      build: () async => TestAppBloc(),
      act: (bloc) async => bloc.add(GameFinished()),
      expect: [HomeAppState()],
    );
  });
}

class TestAppBloc extends AppBloc {
  @override
  AppState get initialState => InGameAppState();
}