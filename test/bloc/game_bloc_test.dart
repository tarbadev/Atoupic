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
      act: (bloc) async => bloc.add(DisplayPlayerPassedCaption(Position.Left)),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.setPlayerPassed(Position.Left));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to reset the passed caption for all players',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(ResetPlayersPassedCaption()),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.resetPlayersPassed());
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to display the trump color contracted by the taker',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(DisplayTrumpColor(CardColor.Heart, Position.Top)),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.setTrumpColor(CardColor.Heart, Position.Top));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to cards to the given player',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(AddPlayerCards([TestFactory.cards.first], Position.Right)),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.addPlayerCards([TestFactory.cards.first], Position.Right));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to reset the real players cards',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(ReplaceRealPlayersCards([TestFactory.cards.first])),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame.replaceRealPlayersCards([TestFactory.cards.first]));
      },
    );

    blocTest<GameBloc, GameEvent, GameState>(
      'calls the game to set the enable real players capability to play a card',
      build: () async => gameBloc,
      act: (bloc) async => bloc.add(RealPlayerCanChooseCard([TestFactory.cards.first])),
      expect: [],
      verify: (_) async {
        verify(Mocks.atoupicGame
            .realPlayerCanChooseCard(true, possiblePlayableCards: [TestFactory.cards.first]));
      },
    );

    group('On SetPlayedCard', () {
      final callback = () {};
      blocTest<GameBloc, GameEvent, GameState>(
        'calls the game to set the disable real players capability to play a card',
        build: () async => gameBloc,
        act: (bloc) async =>
            bloc.add(SetPlayedCard(TestFactory.cards.first, Position.Right, callback)),
        expect: [],
        verify: (_) async {
          verify(Mocks.atoupicGame.realPlayerCanChooseCard(false));
          verify(Mocks.atoupicGame
              .setLastCardPlayed(TestFactory.cards.first, Position.Right, callback));
        },
      );
    });
  });
}
