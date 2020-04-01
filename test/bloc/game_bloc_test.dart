import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/fake_application_injector.dart';
import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('GameBloc', () {
    List<Player> players = TestFactory.gameContext.players;
    GameBloc gameBloc;

    setUp(() {
      reset(Mocks.atoupicGame);

      gameBloc = GameBloc(Mocks.atoupicGame, Mocks.appBloc, Mocks.gameService, Mocks.aiService);
    });

    tearDown(() {
      gameBloc.close();
    });

    test('initial state is NotStarted', () {
      expect(gameBloc.initialState, NotStarted());
    });

    blocTest<GameBloc, GameEvent, GameState>(
      'emits SoloGameInitialized() state on StartSoloGame event',
      build: () async => gameBloc,
      act: (bloc) async {
        var firstPlayer = TestFactory.computerPlayer;
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);

        when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);

        bloc.add(StartSoloGame());
      },
      expect: [SoloGameInitialized()],
      verify: (_) async {
        verify(Mocks.gameService.startSoloGame());
        verify(Mocks.atoupicGame.visible = true);
        verify(Mocks.atoupicGame.setDomainPlayers(players));
        verify(Mocks.appBloc.add(GameInitialized()));
      },
    );

    group('on NewTurn event', () {
      blocTest<GameBloc, GameEvent, GameState>(
        'emits TurnCreated() state on NewTurn event',
        build: () async => gameBloc,
        act: (bloc) async {
          when(Mocks.gameService.startTurn(any)).thenReturn(TestFactory.gameContext);

          bloc.add(NewTurn(turnAlreadyCreated: false));
        },
        expect: [CreatingTurn(), TurnCreated(TestFactory.gameContext.lastTurn)],
        verify: (_) async {
          verify(Mocks.atoupicGame.resetPlayersPassed());
          verify(Mocks.atoupicGame.resetTrumpColor());
          verify(Mocks.atoupicGame.resetPlayersCards());

          verify(Mocks.gameService.startTurn(false));

          verify(Mocks.atoupicGame.addPlayerCards(null, Position.Left));
          verify(Mocks.atoupicGame.addPlayerCards(null, Position.Top));
          verify(Mocks.atoupicGame.addPlayerCards(null, Position.Right));
          verify(Mocks.atoupicGame
              .addPlayerCards([Card(CardColor.Heart, CardHead.Ace)], Position.Bottom));
        },
      );
    });

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

    group('On ResetLastPlayedCards', () {
      blocTest<GameBloc, GameEvent, GameState>(
        'calls the game to reset the last played cards',
        build: () async => gameBloc,
        act: (bloc) async => bloc.add(ResetLastPlayedCards()),
        expect: [],
        verify: (_) async {
          verify(Mocks.atoupicGame.resetLastPlayedCards());
        },
      );
    });

    blocTest<GameBloc, GameEvent, GameState>(
      'emits CardRoundCreated when done',
      build: () async => gameBloc,
      act: (bloc) async {
        final mockedContext = MockGameContext();
        when(Mocks.gameService.read()).thenReturn(mockedContext);
        when(mockedContext.newCardRound()).thenReturn(TestFactory.gameContext);
        when(Mocks.gameService.save(any)).thenReturn(TestFactory.gameContext);

        bloc.add(NewCardRound());
      },
      expect: [CreatingCardRound(), CardRoundCreated(TestFactory.gameContext)],
      verify: (_) async {
        verify(Mocks.gameService.save(TestFactory.gameContext));
      },
    );

    group('On PlayCardForAi', () {
      final mockGameContext = MockGameContext();
      final updatedGameContext = MockGameContext();
      final cards = TestFactory.cards.toList().sublist(0, 3);
      final card = cards.first;
      final turn = Turn(1, TestFactory.realPlayer);
      blocTest<GameBloc, GameEvent, GameState>(
        'emits CardPlayed after calling the AiService to get a card',
        build: () async => gameBloc,
        act: (bloc) async {
          when(Mocks.gameService.read()).thenReturn(mockGameContext);
          when(Mocks.aiService.chooseCard(any, any, any)).thenReturn(card);
          when(mockGameContext.lastTurn).thenReturn(turn);
          when(mockGameContext.setCardDecision(any, any)).thenReturn(updatedGameContext);

          bloc.add(PlayCardForAi(TestFactory.computerPlayer, cards));

          await untilCalled(Mocks.atoupicGame.setLastCardPlayed(any, any, any));
          var callback = verify(Mocks.atoupicGame.setLastCardPlayed(card, Position.Top, captureAny)).captured.single;
          callback();
        },
        expect: [CardAnimationStarted(), CardAnimationEnded(), CardPlayed(updatedGameContext)],
        verify: (_) async {
          verify(Mocks.gameService.read());
          verify(Mocks.aiService.chooseCard(cards, turn, true));
          verify(mockGameContext.setCardDecision(card, TestFactory.computerPlayer));
          verify(Mocks.gameService.save(updatedGameContext));
        },
      );
    });

    group('On PlayCard', () {
      final mockGameContext = MockGameContext();
      final updatedGameContext = MockGameContext();
      final card = TestFactory.cards.first;
      blocTest<GameBloc, GameEvent, GameState>(
        'emits CardPlayed',
        build: () async => gameBloc,
        act: (bloc) async {
          when(Mocks.gameService.read()).thenReturn(mockGameContext);
          when(mockGameContext.setCardDecision(any, any)).thenReturn(updatedGameContext);

          bloc.add(PlayCard(card, TestFactory.realPlayer));

          await untilCalled(Mocks.atoupicGame.setLastCardPlayed(any, any, any));
          var callback = verify(Mocks.atoupicGame.setLastCardPlayed(card, Position.Bottom, captureAny)).captured.single;
          callback();
        },
        expect: [CardAnimationStarted(), CardAnimationEnded(), CardPlayed(updatedGameContext)],
        verify: (_) async {
          verify(Mocks.gameService.read());
          verify(mockGameContext.setCardDecision(card, TestFactory.realPlayer));
          verify(Mocks.atoupicGame.realPlayerCanChooseCard(false));
          verify(Mocks.gameService.save(updatedGameContext));
        },
      );
    });

    group('On EndCardRound', () {
      final mockGameContext = MockGameContext();
      final mockTurn = MockTurn();
      final updatedGameContext = MockGameContext();
      blocTest<GameBloc, GameEvent, GameState>(
        'emits CardRoundCreated when NOT the last round',
        build: () async => gameBloc,
        act: (bloc) async {
          when(Mocks.gameService.read()).thenReturn(mockGameContext);
          when(mockGameContext.lastTurn).thenReturn(Turn(1, null)..cardRounds = []);
          when(mockGameContext.newCardRound()).thenReturn(updatedGameContext);
          when(Mocks.gameService.save(any)).thenReturn(updatedGameContext);

          bloc.add(EndCardRound());
        },
        expect: [CardRoundCreated(updatedGameContext)],
        verify: (_) async {
          verify(Mocks.gameService.read());
          verify(mockGameContext.newCardRound());
          verify(Mocks.atoupicGame.resetLastPlayedCards());
          verify(Mocks.gameService.save(updatedGameContext));
        },
      );

      blocTest<GameBloc, GameEvent, GameState>(
        'emits CardRoundCreated when it is the last round',
        build: () async => gameBloc,
        act: (bloc) async {
          List<CartRound> cardRounds = List();

          for (int i = 0; i <= 7; i++) {
            cardRounds.add(CartRound(Player(Position.Top))
              ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
              ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
              ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
              ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven));
          }

          when(Mocks.gameService.read()).thenReturn(mockGameContext);
          when(mockGameContext.players).thenReturn(UnmodifiableListView([TestFactory.realPlayer]));
          when(mockGameContext.lastTurn).thenReturn(mockTurn);
          when(mockTurn.cardRounds).thenReturn(cardRounds);
          when(Mocks.gameService.save(any)).thenReturn(mockGameContext);

          bloc.add(EndCardRound());
        },
        expect: [TurnEnded()],
        verify: (_) async {
          verify(Mocks.atoupicGame.resetLastPlayedCards());
          verify(Mocks.gameService.read());
          verify(mockTurn.calculatePoints([TestFactory.realPlayer]));
          verify(Mocks.gameService.save(mockGameContext));

          verify(Mocks.store.dispatch(SetCurrentTurnAction(mockTurn)));
          verify(Mocks.store.dispatch(SetTurnResultAction(null)));
        },
      );
    });
  });
}
