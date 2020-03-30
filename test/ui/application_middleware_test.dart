import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/application_middleware.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helper/fake_application_injector.dart';
import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.store);
    reset(Mocks.mockNext);
    reset(Mocks.aiService);
    reset(Mocks.gameService);
    reset(Mocks.cardService);
    reset(Mocks.gameBloc);
  });

  group('takeDecision', () {
    test('distributes cards to players', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer..cards = [];
      var realPlayer = TestFactory.realPlayer..cards = [];
      List<Player> players = [
        Player(Position.Left)..cards = [],
        firstPlayer,
        realPlayer,
        Player(Position.Right)..cards = [],
      ];
      List<Player> updatedPlayers = [
        Player(Position.Left)..cards = [card],
        TestFactory.computerPlayer..cards = [card],
        TestFactory.realPlayer..cards = [card, card],
        Player(Position.Right)..cards = [card],
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(updatedPlayers, [
        Turn(1, firstPlayer)
          ..card = card
          ..trumpColor = card.color
          ..playerDecisions[realPlayer.position] = Decision.Take
      ]);
      var action = TakeDecisionAction(realPlayer, CardColor.Club);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);

      takeDecision(Mocks.store, action, Mocks.next);

      expect(realPlayer.cards.length, 2);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.cardService.distributeCards(2),
        Mocks.gameBloc.add(AddPlayerCards([card], realPlayer.position)),
        Mocks.cardService.distributeCards(3),
        Mocks.gameBloc.add(AddPlayerCards([card], Position.Left)),
        Mocks.cardService.distributeCards(3),
        Mocks.gameBloc.add(AddPlayerCards([card], firstPlayer.position)),
        Mocks.cardService.distributeCards(3),
        Mocks.gameBloc.add(AddPlayerCards([card], Position.Right)),
        Mocks.gameBloc.add(ResetPlayersPassedCaption()),
        Mocks.gameService.save(updatedGameContext),
        Mocks.mockNext.next(action),
      ]);
    });

    test('orders cards of real player', () {
      Player mockPlayer = MockPlayer();
      var gameContext = GameContext(
          [mockPlayer], [Turn(1, mockPlayer)..card = Card(CardColor.Club, CardHead.King)]);
      var action = TakeDecisionAction(mockPlayer, CardColor.Club);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.cards).thenReturn([]);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      takeDecision(Mocks.store, action, Mocks.next);

      verify(mockPlayer.sortCards(trumpColor: CardColor.Club));
      verify(Mocks.gameBloc.add(ReplaceRealPlayersCards([
        Card(CardColor.Club, CardHead.King),
        Card(CardColor.Club, CardHead.Eight),
      ])));
    });

    test('dispatches StartCardRound', () {
      Player mockPlayer = MockPlayer();
      var gameContext = GameContext(
          [mockPlayer], [Turn(1, mockPlayer)..card = Card(CardColor.Club, CardHead.King)]);
      var action = TakeDecisionAction(mockPlayer, CardColor.Club);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.cards).thenReturn([]);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      takeDecision(Mocks.store, action, Mocks.next);

      verify(Mocks.store.dispatch(StartCardRoundAction(gameContext)));
    });

    test('sets the trump color in game', () {
      Player mockPlayer = MockPlayer();
      var gameContext = GameContext(
          [mockPlayer], [Turn(1, mockPlayer)..card = Card(CardColor.Club, CardHead.King)]);
      var action = TakeDecisionAction(mockPlayer, CardColor.Club);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.cards).thenReturn([]);
      when(mockPlayer.position).thenReturn(Position.Right);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      takeDecision(Mocks.store, action, Mocks.next);

      expect(gameContext.lastTurn.trumpColor, CardColor.Club);

      verify(Mocks.gameBloc.add(DisplayTrumpColor(CardColor.Club, Position.Right)));
    });
  });

  group('startCardRound', () {
    test('dispatches a ChooseCardDecision', () {
      GameContext mockGameContext = MockGameContext();
      GameContext updatedContext = MockGameContext();
      var action = StartCardRoundAction(mockGameContext);

      when(mockGameContext.newCardRound()).thenReturn(updatedContext);

      startCardRound(Mocks.store, action, Mocks.next);

      verify(Mocks.gameService.save(updatedContext));
      verify(Mocks.store.dispatch(ChooseCardDecisionAction(updatedContext)));
      verify(Mocks.mockNext.next(action));
    });
  });

  group('chooseCardDecision', () {
    test('dispatches a ShowRealPlayerDecisionAction when next card player is real player', () {
      GameContext mockGameContext = MockGameContext();
      var action = ChooseCardDecisionAction(mockGameContext);

      when(mockGameContext.nextCardPlayer()).thenReturn(TestFactory.realPlayer);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([TestFactory.cards[0]]);

      chooseCardDecision(Mocks.store, action, Mocks.next);

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(TestFactory.realPlayer));
      verify(Mocks.gameBloc.add(RealPlayerCanChooseCard([TestFactory.cards[0]])));
      verify(Mocks.mockNext.next(action));
    });

    test(
        'when next card player is computer player'
        'dispatches a SetCardDecisionAction with the given card from AiService ', () {
      Turn turn = Turn(1, TestFactory.realPlayer);
      var card = TestFactory.cards[0];
      GameContext mockGameContext = MockGameContext();
      var action = ChooseCardDecisionAction(mockGameContext);

      when(mockGameContext.nextCardPlayer()).thenReturn(TestFactory.computerPlayer);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([card]);
      when(mockGameContext.lastTurn).thenReturn(turn);
      when(Mocks.aiService.chooseCard(any, any, any)).thenReturn(card);

      chooseCardDecision(Mocks.store, action, Mocks.next);

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(TestFactory.computerPlayer));
      verify(Mocks.aiService.chooseCard([card], turn, true));
      verify(Mocks.store.dispatch(SetCardDecisionAction(card, TestFactory.computerPlayer)));
      verifyNoMoreInteractions(Mocks.store);
      verify(Mocks.mockNext.next(action));
    });

    test('dispatches a EndCardRoundAction when next card player is null', () {
      GameContext mockGameContext = MockGameContext();
      var action = ChooseCardDecisionAction(mockGameContext);

      when(mockGameContext.nextCardPlayer()).thenReturn(null);

      chooseCardDecision(Mocks.store, action, Mocks.next);

      verify(mockGameContext.nextCardPlayer());
      verify(Mocks.store.dispatch(EndCardRoundAction(mockGameContext)));
      verifyNoMoreInteractions(Mocks.store);
      verify(Mocks.mockNext.next(action));
    });
  });

  group('setCardDecision', () {
    test('stores the card played and updates UI', () {
      GameContext mockGameContext = MockGameContext();
      GameContext updatedGameContext = MockGameContext();
      var card = TestFactory.cards[0];
      var player = TestFactory.realPlayer;
      var action = SetCardDecisionAction(card, player);

      when(Mocks.gameService.read()).thenReturn(mockGameContext);
      when(mockGameContext.setCardDecision(any, any)).thenReturn(updatedGameContext);

      setCardDecision(Mocks.store, action, Mocks.next);

      verify(mockGameContext.setCardDecision(card, player));
      SetPlayedCard setPlayedCard = verify(Mocks.gameBloc.add(captureAny)).captured.single;
      expect(setPlayedCard.card, card);
      expect(setPlayedCard.position, player.position);

      verify(Mocks.gameService.save(updatedGameContext));
      setPlayedCard.onCardPlayed();
      verify(Mocks.store.dispatch(ChooseCardDecisionAction(updatedGameContext)));
      verify(Mocks.mockNext.next(action));
    });
  });

  group('chooseCardForAi', () {
    test('dispatches a SetCardDecisionAction with a random card', () {
      var card = Card(CardColor.Club, CardHead.Eight);
      var player = TestFactory.computerPlayer..cards = [card];
      var action = ChooseCardForAiAction([card], player);

      chooseCardForAi(Mocks.store, action, Mocks.next);

      verify(Mocks.store.dispatch(SetCardDecisionAction(card, player)));
      verify(Mocks.mockNext.next(action));
    });
  });

  group('endCardRound', () {
    test('resets the last played cards in game and start a new round', () {
      GameContext mockContext = MockGameContext();
      var action = EndCardRoundAction(mockContext);

      when(mockContext.lastTurn).thenReturn(Turn(1, TestFactory.realPlayer));
      endCardRound(Mocks.store, action, Mocks.next);

      verify(Mocks.gameBloc.add(ResetLastPlayedCards()));
      verify(Mocks.store.dispatch(StartCardRoundAction(mockContext)));
      verify(Mocks.mockNext.next(action));
    });

    test('when all rounds played resets the last played cards in game and ends turn', () {
      List<CartRound> cardRounds = List();

      for (int i = 0; i <= 7; i++) {
        cardRounds.add(CartRound(Player(Position.Top))
          ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
          ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
          ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
          ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven));
      }

      expect(cardRounds.length, 8);

      GameContext gameContext = TestFactory.gameContext..lastTurn.cardRounds = cardRounds;
      var action = EndCardRoundAction(gameContext);

      endCardRound(Mocks.store, action, Mocks.next);

      verify(Mocks.gameBloc.add(ResetLastPlayedCards()));
      verify(Mocks.store.dispatch(EndTurnAction(gameContext)));
      verify(Mocks.mockNext.next(action));
    });
  });

  group('endTurn', () {
    test('calculates the points and displays the result', () {
      Turn mockTurn = MockTurn();
      GameContext gameContext = GameContext([], [mockTurn]);
      var action = EndTurnAction(gameContext);
      var turnResult = TestFactory.turnResult;

      when(mockTurn.turnResult).thenReturn(turnResult);

      endTurn(Mocks.store, action, Mocks.next);

      verify(mockTurn.calculatePoints(gameContext.players));
      verify(Mocks.store.dispatch(SetCurrentTurnAction(gameContext.lastTurn)));
      verify(Mocks.store.dispatch(SetTurnResultAction(turnResult)));
      verify(Mocks.gameService.save(gameContext));
      verify(Mocks.mockNext.next(action));
    });
  });
}
