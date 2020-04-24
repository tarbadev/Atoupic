import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  group('DeclarationsBloc', () {
    DeclarationsBloc declarationsBloc;

    setUp(() {
      declarationsBloc = DeclarationsBloc(Mocks.gameBloc, Mocks.gameService);
    });

    tearDown(() {
      declarationsBloc.close();
    });

    test('initial state is InitialDeclarationsState', () {
      expect(declarationsBloc.initialState, InitialDeclarationsState());
    });

    group('on AnalyseDeclarations', () {
      final turn = MockTurn();
      final mockGameContext = MockGameContext();
      final turnDeclarations = <Position, List<Declaration>>{
        Position.Left: [Declaration(DeclarationType.Tierce, TestFactory.cards.sublist(0, 3))],
        Position.Top: [],
        Position.Right: [Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.Jack)])],
      };
      blocTest<DeclarationsBloc, DeclarationsEvent, DeclarationsState>(
        'emits AnalyzingDeclarations then FinishedAnalyzingDeclarations',
        build: () async => declarationsBloc,
        act: (bloc) async {
          when(Mocks.gameService.lookForDeclarations()).thenReturn(mockGameContext);
          when(mockGameContext.lastTurn).thenReturn(turn);
          when(turn.playerDeclarations).thenReturn(turnDeclarations);

          bloc.add(AnalyseDeclarations(mockGameContext));
        },
        expect: [AnalyzingDeclarations(), FinishedAnalyzingDeclarations(mockGameContext)],
        verify: (_) async {
          verify(Mocks.gameService.lookForDeclarations());
          verify(Mocks.gameBloc.add(DisplayPlayerCaption(Position.Left, 'Tierce!')));
          verify(Mocks.gameBloc.add(DisplayPlayerCaption(Position.Right, 'Square of Jacks!')));
        },
      );
    });
  });
}
