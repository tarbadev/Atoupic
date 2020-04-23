import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  group('TakeOrPassDialogBloc', () {
    TakeOrPassBloc currentTurnBloc;

    setUp(() {
      reset(Mocks.gameBloc);
      reset(Mocks.gameService);
      reset(Mocks.cardService);
      reset(Mocks.aiService);

      currentTurnBloc = TakeOrPassBloc(
          Mocks.gameBloc, Mocks.gameService, Mocks.cardService, Mocks.aiService);
    });

    tearDown(() {
      currentTurnBloc.close();
    });

    test('initial state is InitialTakeOrPassState', () {
      expect(currentTurnBloc.initialState, HideTakeOrPass());
    });

    group('on Take event', () {
      var card = Card(CardColor.Spade, CardHead.Ace);
      var distributedCard = Card(CardColor.Heart, CardHead.Seven);
      var firstPlayer = TestFactory.topPlayer..cards = [];
      var realPlayer = TestFactory.realPlayer..cards = [Card(CardColor.Spade, CardHead.Jack)];
      List<Player> players = [
        TestFactory.leftPlayer..cards = [],
        firstPlayer,
        realPlayer,
        TestFactory.rightPlayer..cards = [],
      ];
      var updatedRealPlayer = TestFactory.realPlayer
        ..cards = [distributedCard, Card(CardColor.Spade, CardHead.Jack), card];
      List<Player> updatedPlayers = [
        TestFactory.leftPlayer..cards = [distributedCard],
        TestFactory.topPlayer..cards = [distributedCard],
        updatedRealPlayer,
        TestFactory.rightPlayer..cards = [distributedCard],
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(updatedPlayers, [
        Turn(1, firstPlayer)
          ..card = card
          ..trumpColor = card.color
          ..playerDecisions[realPlayer.position] = Decision.Take
      ]);

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>('emits PlayerTook',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.gameService.read()).thenReturn(gameContext);
            when(Mocks.cardService.distributeCards(any)).thenReturn([distributedCard]);

            currentTurnBloc.add(Take(realPlayer, card.color));
          },
          expect: [PlayerTook()],
          verify: (_) async {
            verify(Mocks.gameService.read());
            expect(verify(Mocks.cardService.distributeCards(2)).callCount, 1);
            verify(
                Mocks.gameBloc.add(AddPlayerCards([distributedCard, card], realPlayer.position)));
            verify(Mocks.gameBloc.add(DisplayPlayerTookCaption(realPlayer.position)));
            expect(verify(Mocks.cardService.distributeCards(3)).callCount, 3);
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], Position.Left)));
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], firstPlayer.position)));
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], Position.Right)));
            verify(Mocks.gameBloc.add(ResetPlayersCaption()));
            verify(Mocks.gameBloc.add(DisplayTrumpColor(card.color, Position.Bottom)));
            verify(Mocks.gameBloc.add(ReplaceRealPlayersCards(updatedRealPlayer.cards)));
            verify(Mocks.gameService.save(updatedGameContext));
          });
    });

    group('on Pass event', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.topPlayer;
      List<Player> players = [
        TestFactory.leftPlayer,
        firstPlayer,
        TestFactory.realPlayer,
        TestFactory.rightPlayer,
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(players, [
        Turn(1, firstPlayer)
          ..card = card
          ..playerDecisions[firstPlayer.position] = Decision.Pass
      ]);
      var updatedGameContext2 = GameContext(players, [
        Turn(1, firstPlayer)
          ..card = card
          ..round = 2
          ..playerDecisions[firstPlayer.position] = Decision.Pass
      ]);
      var mockedContext = MockGameContext();

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'saves the pass decision and emit PlayerPassed',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.gameService.read()).thenReturn(gameContext);

            currentTurnBloc.add(Pass(firstPlayer));
          },
          expect: [PlayerPassed(gameContext)],
          verify: (_) async {
            verify(Mocks.gameBloc.add(DisplayPlayerPassedCaption(firstPlayer.position)));
            verify(Mocks.gameService.read());
            verify(Mocks.gameService.save(updatedGameContext));
          });

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'saves the pass decision and emit PlayerPassed '
          'and saves new round if the next player is null',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.gameService.read()).thenReturn(mockedContext);
            when(mockedContext.setDecision(any, any)).thenReturn(mockedContext);
            when(mockedContext.nextPlayer()).thenReturn(null);
            when(mockedContext.lastTurn).thenReturn(Turn(1, firstPlayer)..round = 1);
            when(mockedContext.nextRound()).thenReturn(updatedGameContext2);

            currentTurnBloc.add(Pass(firstPlayer));
          },
          expect: [PlayerPassed(updatedGameContext2)],
          verify: (_) async {
            verify(Mocks.gameBloc.add(DisplayPlayerPassedCaption(firstPlayer.position)));
            verify(mockedContext.setDecision(firstPlayer, Decision.Pass));
            verify(Mocks.gameService.read());
            verify(mockedContext.nextRound());
            verify(Mocks.gameBloc.add(ResetPlayersCaption()));
            verify(Mocks.gameService.save(updatedGameContext2));
          });

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'saves the pass decision and emit PlayerPassed '
          'and adds NewTurn event if the next player is null is round 2',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.gameService.read()).thenReturn(mockedContext);
            when(mockedContext.setDecision(any, any)).thenReturn(mockedContext);
            when(mockedContext.nextPlayer()).thenReturn(null);
            when(mockedContext.lastTurn).thenReturn(Turn(1, firstPlayer)..round = 2);

            currentTurnBloc.add(Pass(firstPlayer));
          },
          expect: [NoOneTook()],
          verify: (_) async {
            verify(Mocks.gameBloc.add(DisplayPlayerPassedCaption(firstPlayer.position)));
            verify(mockedContext.setDecision(firstPlayer, Decision.Pass));
            verify(Mocks.gameService.read());
            verify(Mocks.gameService.save(mockedContext));
            verify(Mocks.gameBloc.add(NewTurn()));
          });
    });

    group('on RealPlayerTurn event', () {
      var player = TestFactory.realPlayer;
      var card = Card(CardColor.Club, CardHead.King);
      var turnRound1 = Turn(1, TestFactory.realPlayer)..card = card;
      var turnRound2 = Turn(1, TestFactory.realPlayer)
        ..card = card
        ..round = 2;

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
        'emits ShowTakeOrPassRound1 when round 1',
        build: () async => currentTurnBloc,
        act: (bloc) async => bloc.add(RealPlayerTurn(player, turnRound1)),
        expect: [ShowTakeOrPassRound1(player)],
      );

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
        'emits ShowTakeOrPassRound2 when round 2',
        build: () async => currentTurnBloc,
        act: (bloc) async => bloc.add(RealPlayerTurn(player, turnRound2)),
        expect: [ShowTakeOrPassRound2(player)],
      );
    });

    group('on ComputerPlayerTurn event', () {
      var cards = [TestFactory.cards.first];
      var player = TestFactory.topPlayer..cards = cards;
      var card = Card(CardColor.Club, CardHead.King);
      var turn = Turn(1, TestFactory.topPlayer)..card = card;
      var mockGameContext = MockGameContext();

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'emits PlayerPassed when aiService returns null',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.aiService.takeOrPass(any, any)).thenReturn(null);
            when(Mocks.gameService.read()).thenReturn(mockGameContext);
            when(mockGameContext.setDecision(any, any)).thenReturn(mockGameContext);
            when(mockGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);

            bloc.add(ComputerPlayerTurn(player, turn));
          },
          expect: [PlayerPassed(mockGameContext)],
          verify: (_) async {
            verify(mockGameContext.setDecision(player, Decision.Pass));
            verify(Mocks.aiService.takeOrPass(cards, turn));
          });

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'emits PlayerTook when aiService returns CardColor',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.aiService.takeOrPass(any, any)).thenReturn(CardColor.Heart);
            when(Mocks.gameService.read()).thenReturn(mockGameContext);
            when(mockGameContext.setDecision(any, any)).thenReturn(mockGameContext);
            when(mockGameContext.lastTurn).thenReturn(turn);
            when(mockGameContext.players)
                .thenReturn(UnmodifiableListView([TestFactory.realPlayerWithCards([])]));
            when(Mocks.cardService.distributeCards(any)).thenReturn([]);

            bloc.add(ComputerPlayerTurn(player, turn));
          },
          expect: [PlayerTook()],
          verify: (_) async {
            expect(turn.trumpColor, CardColor.Heart);
            verify(Mocks.aiService.takeOrPass(cards, turn));
          });
    });
  });
}
