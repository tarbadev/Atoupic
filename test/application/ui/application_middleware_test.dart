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
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);

      startSoloGame(Mocks.store, startSoloGameAction, Mocks.next);

      verifyInOrder([
        Mocks.gameService.startSoloGame(),
        Mocks.store.dispatch(SetPlayersInGame(gameContext)),
        Mocks.store.dispatch(TakeOrPassAction(gameContext)),
        Mocks.atoupicGame.visible = true,
        Mocks.mockNext.next(startSoloGameAction),
      ]);
    });
  });

  group('setPlayersInGame', () {
    test('sets the players in game', () {
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
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

  group('takeOrPass', () {
    test('gets one card and dispatch a TakeOrPassDecision with the player', () {
      var card = Card(CardColor.Club, CardHead.Ace);
      var firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
      ];
      var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
      var updatedGameContext =
          GameContext(players, [Turn(1, firstPlayer)..card = card]);
      var takeOrPassAction = TakeOrPassAction(gameContext);

      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
      when(Mocks.gameService.save(any)).thenReturn(gameContext);

      takeOrPass(Mocks.store, takeOrPassAction, Mocks.next);

      verifyInOrder([
        Mocks.cardService.distributeCards(1),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(SetTakeOrPassCard(card)),
        Mocks.store.dispatch(TakeOrPassDecisionAction(firstPlayer)),
        Mocks.mockNext.next(takeOrPassAction),
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
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
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
      when(mockedContext.turns).thenReturn([Turn(1, firstPlayer)..card = card]);
      when(mockedContext.players).thenReturn([firstPlayer, TestFactory.realPlayer]);

      passDecision(Mocks.store, action, Mocks.next);

      verifyInOrder([
        Mocks.gameService.read(),
        Mocks.gameService.save(updatedGameContext),
        Mocks.store.dispatch(TakeOrPassDecisionAction(TestFactory.realPlayer)),
        Mocks.store.dispatch(SetPlayersInGame(mockedContext)),
        Mocks.mockNext.next(action),
      ]);
    });
  });
}
