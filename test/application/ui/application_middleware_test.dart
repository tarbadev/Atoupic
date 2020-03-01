import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_middleware.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjectorForTest();

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
        Mocks.store.dispatch(SetRealPlayerAction(TestFactory.realPlayer)),
        Mocks.store.dispatch(StartTurnAction(gameContext)),
        Mocks.atoupicGame.visible = true,
        Mocks.mockNext.next(startSoloGameAction),
      ]);
    });
  });

  group('setPlayersInGame', () {
    test('sets the players in game', () {
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left)..cards = [],
        firstPlayer..cards = [],
        TestFactory.realPlayer..cards = [],
        Player(Position.Right)..cards = [],
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
      var setGameContextAction = SetPlayersInGame(gameContext);

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);

      setPlayersInGame(Mocks.store, setGameContextAction, Mocks.next);

      List<PlayerComponent> capturedList =
          verify(Mocks.atoupicGame.setPlayers(captureAny)).captured[0];
      expect(capturedList.length, gameContext.players.length);

      verify(Mocks.mockNext.next(setGameContextAction));
    });
  });

  group('startTurn', () {
    test('gets one card and dispatch a TakeOrPassDecision with the player', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(Position.Right),
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
      var updatedGameContext =
          GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var takeOrPassAction = StartTurnAction(gameContext);

      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
      when(Mocks.gameService.save(any)).thenReturn(gameContext);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        Mocks.cardService.initializeCards(),
        Mocks.cardService.distributeCards(1),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(SetTurnAction(1)),
        Mocks.store.dispatch(SetTakeOrPassCard(card)),
        Mocks.store.dispatch(SetPlayersInGame(gameContext)),
        Mocks.store.dispatch(TakeOrPassDecisionAction(firstPlayer)),
        Mocks.mockNext.next(takeOrPassAction),
      ]);
    });

    test('distributes 5 cards to each players before getting one for the turn',
        () {
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
      var updatedGameContext =
          GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var takeOrPassAction = StartTurnAction(gameContext);

      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
      when(Mocks.gameService.save(any)).thenReturn(gameContext);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        Mocks.cardService.distributeCards(5),
        mockPlayer.cards = [card],
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(5),
        Mocks.cardService.distributeCards(1),
        Mocks.gameService.save(updatedGameContext),
      ]);
    });

    test('orders the cards of the real player',
        () {
      Player mockPlayer = MockPlayer();
      List<Player> players = [
        mockPlayer,
      ];
      var gameContext = GameContext(players, [Turn(1, mockPlayer)]);
      var takeOrPassAction = StartTurnAction(gameContext);

      when(Mocks.cardService.distributeCards(any)).thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      startTurn(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        mockPlayer.initializeCards(),
      ]);
    });
  });

  group('takeOrPassDecision', () {
    test('when player is not real dispatch PassDecisionAction', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var action = TakeOrPassDecisionAction(TestFactory.computerPlayer);

      takeOrPassDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.store.dispatch(PassDecisionAction(TestFactory.computerPlayer)),
        Mocks.mockNext.next(action),
      ]);
    });

    test('when player is real dispatch ShowTakeOrPassDialogAction', () {
      var card = Card(CardColor.Club, CardHead.Ace);
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
      var gameContext =
          GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(players, [
        Turn(1, firstPlayer)
          ..card = card
          ..playerDecisions[firstPlayer] = Decision.Pass
      ]);
      var action = PassDecisionAction(firstPlayer);
      var mockedContext = MockGameContext();

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.gameService.save(any)).thenReturn(mockedContext);
      when(mockedContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
      when(mockedContext.players)
          .thenReturn([firstPlayer, TestFactory.realPlayer]);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(TakeOrPassDecisionAction(TestFactory.realPlayer)),
        Mocks.store.dispatch(SetPlayersInGame(mockedContext)),
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
      when(Mocks.gameService.save(any)).thenReturn(mockedContext);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(TakeOrPassDecisionAction(firstPlayer)),
        Mocks.store.dispatch(SetPlayersInGame(mockedContext)),
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
      when(Mocks.gameService.save(any)).thenReturn(updatedGameContext);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(StartTurnAction(updatedGameContext)),
        Mocks.store.dispatch(SetPlayersInGame(updatedGameContext)),
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
      var gameContext =
          GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var updatedGameContext = GameContext(updatedPlayers, [
        Turn(1, firstPlayer)
          ..card = card
          ..playerDecisions[realPlayer] = Decision.Take
      ]);
      var action = TakeDecisionAction(realPlayer);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
      when(Mocks.gameService.save(any)).thenReturn(updatedGameContext);

      takeDecision(Mocks.store, action, Mocks.next);

      expect(realPlayer.cards.length, 2);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.cardService.distributeCards(2),
        Mocks.cardService.distributeCards(3),
        Mocks.cardService.distributeCards(3),
        Mocks.cardService.distributeCards(3),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(SetPlayersInGame(updatedGameContext)),
        Mocks.mockNext.next(action),
      ]);
    });

    test('orders cards of real player', () {
      Player mockPlayer = MockPlayer();
      var gameContext =
      GameContext([mockPlayer], [Turn(1, mockPlayer)..card = Card(CardColor.Club, CardHead.King)]);
      var action = TakeDecisionAction(mockPlayer);

      when(Mocks.gameService.read()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any)).thenReturn([Card(CardColor.Club, CardHead.Eight)]);
      when(mockPlayer.cards).thenReturn([]);
      when(mockPlayer.isRealPlayer).thenReturn(true);

      takeDecision(Mocks.store, action, Mocks.next);

      verify(mockPlayer.initializeCards());
    });
  });
}
