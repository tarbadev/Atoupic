import 'dart:collection';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  group('TakeOrPassBloc', () {
    TakeOrPassBloc currentTurnBloc;

    setUp(() {
      reset(Mocks.gameBloc);
      reset(Mocks.gameService);
      reset(Mocks.cardService);

      currentTurnBloc = TakeOrPassBloc(Mocks.gameBloc, Mocks.gameService, Mocks.cardService);
    });

    tearDown(() {
      currentTurnBloc.close();
    });

    test('initial state is InitialTakeOrPassState', () {
      expect(currentTurnBloc.initialState, InitialTakeOrPassState());
    });

    group('on Take event', () {
      var card = Card(CardColor.Spade, CardHead.Ace);
      var distributedCard = Card(CardColor.Heart, CardHead.Seven);
      var firstPlayer = TestFactory.computerPlayer..cards = [];
      var realPlayer = TestFactory.realPlayer..cards = [Card(CardColor.Spade, CardHead.Jack)];
      List<Player> players = [
        Player(Position.Left)..cards = [],
        firstPlayer,
        realPlayer,
        Player(Position.Right)..cards = [],
      ];
      var updatedRealPlayer = TestFactory.realPlayer..cards = [distributedCard, Card(CardColor.Spade, CardHead.Jack), card];
      List<Player> updatedPlayers = [
        Player(Position.Left)..cards = [distributedCard],
        Player(Position.Top)..cards = [distributedCard],
        updatedRealPlayer,
        Player(Position.Right)..cards = [distributedCard],
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(updatedPlayers, [
        Turn(1, firstPlayer)
          ..card = card
          ..trumpColor = card.color
          ..playerDecisions[realPlayer.position] = Decision.Take
      ]);

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
          'emits PlayerTook',
          build: () async => currentTurnBloc,
          act: (bloc) async {
            when(Mocks.gameService.read()).thenReturn(gameContext);
            when(Mocks.cardService.distributeCards(any)).thenReturn([distributedCard]);

            currentTurnBloc.add(Take(realPlayer, card.color));
          },
          expect: [PlayerTook(updatedRealPlayer)],
          verify: (_) async {
            verify(Mocks.gameService.read());
            expect(verify(Mocks.cardService.distributeCards(2)).callCount, 1);
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard, card], realPlayer.position)));
            expect(verify(Mocks.cardService.distributeCards(3)).callCount, 3);
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], Position.Left)));
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], firstPlayer.position)));
            verify(Mocks.gameBloc.add(AddPlayerCards([distributedCard], Position.Right)));
            verify(Mocks.gameBloc.add(ResetPlayersPassedCaption()));
            verify(Mocks.gameBloc.add(DisplayTrumpColor(card.color, Position.Bottom)));
            verify(Mocks.gameBloc.add(ReplaceRealPlayersCards(updatedRealPlayer.cards)));
            verify(Mocks.gameService.save(updatedGameContext));
          }
      );
    });

    group('on Pass event', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
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
          }
      );

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
            verify(Mocks.gameService.save(updatedGameContext2));
          }
      );

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
          }
      );
    });

    group('on RealPlayerTurn event', () {
      var player = TestFactory.realPlayer;
      var card = Card(CardColor.Club, CardHead.King);

      blocTest<TakeOrPassBloc, TakeOrPassEvent, TakeOrPassState>(
        'emits ShowTakeOrPassDialog',
        build: () async => currentTurnBloc,
        act: (bloc) async => bloc.add(RealPlayerTurn(player, card)),
        expect: [ShowTakeOrPassDialog(player, card)],
      );
    });
  });
}
