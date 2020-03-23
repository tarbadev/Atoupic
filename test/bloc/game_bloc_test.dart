import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  group('GameBloc', () {
    List<Player> players = TestFactory.gameContext.players;
    GameBloc gameBloc;

    setUp(() {
      gameBloc = GameBloc(Mocks.atoupicGame);
    });

    test('initial state is NotStarted', () {
      expect(gameBloc.initialState, NotStarted());
    });

    blocTest<GameBloc, GameEvent, GameState>(
      'emits Initialized() state when starting game',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(Start(players)),
      expect: [Initialized()],
      verify: (_) async {
        verify(Mocks.atoupicGame.visible = true);
        verify(Mocks.atoupicGame.setDomainPlayers(players));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'resets the game on NewTurn',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(NewTurn(players)),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.resetPlayersPassed());
        verify(Mocks.atoupicGame.resetTrumpColor());
        verify(Mocks.atoupicGame.resetPlayersCards());
        verify(Mocks.atoupicGame.addPlayerCards(null, Position.Left));
        verify(Mocks.atoupicGame.addPlayerCards(null, Position.Top));
        verify(Mocks.atoupicGame.addPlayerCards(null, Position.Right));
        verify(Mocks.atoupicGame
            .addPlayerCards([Card(CardColor.Heart, CardHead.Ace)], Position.Bottom));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to display player passed',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(DisplayPlayerPassed(Position.Left)),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.setPlayerPassed(Position.Left));
      },
    );
  });
}
