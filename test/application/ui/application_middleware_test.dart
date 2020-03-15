import 'package:atoupic/application/domain/entity/turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_middleware.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.store);
  });

  group('startSoloGame', () {
    test('call gameService to get gameContext and sets in the state', () {
      var startSoloGameAction = StartSoloGameAction();
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);

      startSoloGame(Mocks.store, startSoloGameAction, Mocks.next);

      verifyInOrder([
        Mocks.gameService.startSoloGame(),
        Mocks.atoupicGame.setDomainPlayers(players),
        Mocks.atoupicGame.visible = true,
        Mocks.store.dispatch(SetRealPlayerAction(TestFactory.realPlayer)),
        Mocks.store.dispatch(StartTurnAction(gameContext)),
        Mocks.mockNext.next(startSoloGameAction),
      ]);
    });
  });

  group('startTurn', () {
    test('gets one card and dispatch a TakeOrPassDecision with the player', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        Player(Position.Right),
        TestFactory.realPlayer,
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
      var updatedGameContext = GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var takeOrPassAction = StartTurnAction(gameContext, turnAlreadyCreated: true);

      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        Mocks.cardService.initializeCards(),
        Mocks.atoupicGame.addPlayerCards([card], Position.Left),
        Mocks.atoupicGame.addPlayerCards([card], Position.Top),
        Mocks.atoupicGame.addPlayerCards([card], Position.Right),
        Mocks.atoupicGame.addPlayerCards([card], Position.Bottom),
        Mocks.cardService.distributeCards(1),
        Mocks.store.dispatch(SetGameContextAction(updatedGameContext)),
        Mocks.store.dispatch(SetTurnAction(1)),
        Mocks.store.dispatch(SetTakeOrPassCard(card)),
        Mocks.store.dispatch(TakeOrPassDecisionAction(firstPlayer)),
        Mocks.mockNext.next(takeOrPassAction),
      ]);
    });

    test('distributes 5 cards to each players before getting one for the turn', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      Player mockPlayer = MockPlayer();
      List<Player> players = [
        mockPlayer,
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
      var action = StartTurnAction(gameContext);

      when(mockPlayer.isRealPlayer).thenReturn(false);
      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);

      startTurn(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.cardService.distributeCards(5),
        mockPlayer.cards = [card],
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(1),
        Mocks.store.dispatch(SetGameContextAction(gameContext)),
      ]);
    });

    test('orders the cards of the real player', () {
      Player mockPlayer = MockPlayer();
      List<Player> players = [
        mockPlayer,
      ];
      var gameContext = GameContext(players, [Turn(1, mockPlayer)]);
      var takeOrPassAction = StartTurnAction(gameContext);

      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        mockPlayer.sortCards(),
      ]);
    });

    test('create next turn and resets the game', () {
      Player mockPlayer = MockPlayer();
      GameContext gameContext = MockGameContext();
      List<Player> players = [
        mockPlayer,
      ];
      var newGameContext = GameContext(players, [Turn(1, mockPlayer)]);
      var takeOrPassAction = StartTurnAction(gameContext);

      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.isRealPlayer).thenReturn(true);
      when(gameContext.players).thenReturn(players);
      when(gameContext.nextTurn()).thenReturn(newGameContext);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verify(Mocks.atoupicGame.resetPlayersPassed());
      verify(Mocks.atoupicGame.resetPlayersCards());
      verify(Mocks.atoupicGame.resetTrumpColor());
      verify(gameContext.nextTurn());
    });

    test('when turn already created does not call nextTurn()', () {
      Player mockPlayer = MockPlayer();
      GameContext gameContext = MockGameContext();
      List<Player> players = [
        mockPlayer,
      ];
      var takeOrPassAction = StartTurnAction(gameContext, turnAlreadyCreated: true);

      when(Mocks.cardService.distributeCards(any))
          .thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.isRealPlayer).thenReturn(true);
      when(gameContext.players).thenReturn(players);
      when(gameContext.lastTurn).thenReturn(Turn(1, mockPlayer));

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verify(Mocks.atoupicGame.resetPlayersCards());
      verifyNever(gameContext.nextTurn());
    });
  });

  group('takeOrPassDecision', () {
    test('when player is not real dispatch PassDecisionAction', () {
      var action = TakeOrPassDecisionAction(TestFactory.computerPlayer);

      takeOrPassDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.store.dispatch(PassDecisionAction(TestFactory.computerPlayer)),
        Mocks.mockNext.next(action),
      ]);
    });

    test('when player is real dispatch ShowTakeOrPassDialogAction', () {
      var action = TakeOrPassDecisionAction(TestFactory.realPlayer);

      takeOrPassDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.store.dispatch(ShowTakeOrPassDialogAction(true)),
        Mocks.mockNext.next(action),
      ]);
    });
  });

  group('passDecision', () {
    test(
        'saves new gameContext with decision, sets in game players and dispatch TakeOrPassDecision with next player',
        () {
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
      var action = PassDecisionAction(firstPlayer);
      var mockedContext = MockGameContext();

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(mockedContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
      when(mockedContext.players).thenReturn([firstPlayer, TestFactory.realPlayer]);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.atoupicGame.setPlayerPassed(action.player.position),
        Mocks.gameService.read(),
        Mocks.store.dispatch(TakeOrPassDecisionAction(TestFactory.realPlayer)),
        Mocks.store.dispatch(SetGameContextAction(updatedGameContext)),
        Mocks.mockNext.next(action),
      ]);
    });

    test('when nextPlayer returns null switch to round 2', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
      ];
      var updatedGameContext = GameContext(players, [
        Turn(1, firstPlayer)
          ..card = card
          ..round = 2
      ]);
      var action = PassDecisionAction(firstPlayer);
      GameContext mockedContext = MockGameContext();

      when(Mocks.gameService.read()).thenReturn(mockedContext);
      when(mockedContext.setDecision(any, any)).thenReturn(mockedContext);
      when(mockedContext.nextPlayer()).thenReturn(null);
      when(mockedContext.lastTurn).thenReturn(Turn(1, firstPlayer));
      when(mockedContext.nextRound()).thenReturn(updatedGameContext);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.atoupicGame.resetPlayersPassed(),
        Mocks.store.dispatch(TakeOrPassDecisionAction(firstPlayer)),
        Mocks.store.dispatch(SetGameContextAction(updatedGameContext)),
        Mocks.mockNext.next(action),
      ]);
    });

    test('when nextPlayer returns null and round is 2 calls next round', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
      ];
      var updatedGameContext = GameContext(players, [
        Turn(1, firstPlayer)
          ..card = card
          ..round = 2
      ]);
      var action = PassDecisionAction(firstPlayer);
      GameContext mockedContext = MockGameContext();

      when(Mocks.gameService.read()).thenReturn(mockedContext);
      when(mockedContext.setDecision(any, any)).thenReturn(mockedContext);
      when(mockedContext.nextPlayer()).thenReturn(null);
      when(mockedContext.lastTurn).thenReturn(Turn(1, firstPlayer)..round = 2);
      when(mockedContext.nextTurn()).thenReturn(updatedGameContext);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.store.dispatch(SetGameContextAction(mockedContext)),
        Mocks.mockNext.next(action),
      ]);
    });
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
        Mocks.atoupicGame.addPlayerCards([card], realPlayer.position),
        Mocks.cardService.distributeCards(3),
        Mocks.atoupicGame.addPlayerCards([card], Position.Left),
        Mocks.cardService.distributeCards(3),
        Mocks.atoupicGame.addPlayerCards([card], firstPlayer.position),
        Mocks.cardService.distributeCards(3),
        Mocks.atoupicGame.addPlayerCards([card], Position.Right),
        Mocks.atoupicGame.resetPlayersPassed(),
        Mocks.store.dispatch(SetGameContextAction(updatedGameContext)),
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
      verify(Mocks.atoupicGame.replaceRealPlayersCards([
        Card(CardColor.Club, CardHead.King),
        Card(CardColor.Club, CardHead.Eight),
      ]));
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

      verify(Mocks.atoupicGame.setTrumpColor(CardColor.Club, Position.Right));
    });
  });

  group('startCardRound', () {
    test('dispatches a ChooseCardDecision', () {
      GameContext mockGameContext = MockGameContext();
      GameContext updatedContext = MockGameContext();
      var action = StartCardRoundAction(mockGameContext);

      when(mockGameContext.newCardRound()).thenReturn(updatedContext);

      startCardRound(Mocks.store, action, Mocks.next);

      verify(Mocks.store.dispatch(SetGameContextAction(updatedContext)));
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
      verify(Mocks.atoupicGame
          .realPlayerCanChooseCard(true, possiblePlayableCards: [TestFactory.cards[0]]));
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
      Function callBack =
          verify(Mocks.atoupicGame.setLastCardPlayed(card, player.position, captureAny))
              .captured
              .single;
      verify(Mocks.store.dispatch(SetGameContextAction(updatedGameContext)));
      verify(Mocks.atoupicGame.realPlayerCanChooseCard(false));
      callBack();
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

      verify(Mocks.atoupicGame.resetLastPlayedCards());
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

      verify(Mocks.atoupicGame.resetLastPlayedCards());
      verify(Mocks.store.dispatch(EndTurnAction(gameContext)));
      verify(Mocks.mockNext.next(action));
    });
  });

  group('endTurn', () {
    test('calculates the points and displays the result', () {
      Turn mockTurn = MockTurn();
      GameContext gameContext = TestFactory.gameContext..turns[0] = mockTurn;
      var action = EndTurnAction(gameContext);
      var turnResult = TestFactory.turnResult;

      when(mockTurn.turnResult).thenReturn(turnResult);

      endTurn(Mocks.store, action, Mocks.next);

      verify(mockTurn.calculatePoints(gameContext.players));
      verify(Mocks.store.dispatch(SetTurnResultAction(turnResult)));
      verify(Mocks.store.dispatch(SetGameContextAction(gameContext)));
      verify(Mocks.mockNext.next(action));
    });
  });
}
