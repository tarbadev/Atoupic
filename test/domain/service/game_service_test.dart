import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('GameService', () {
    GameService gameService;

    setUp(() {
      reset(Mocks.playerService);
      reset(Mocks.cardService);
      reset(Mocks.gameContextRepository);

      gameService = GameService(Mocks.gameContextRepository, Mocks.cardService);
    });

    group('startSoloGame', () {
      test('generates a real player', () {
        gameService.startSoloGame();

        verify(Mocks.playerService.buildRealPlayer());
      });

      test('generates 3 computer players', () {
        gameService.startSoloGame();

        verifyInOrder([
          Mocks.playerService.buildComputerPlayer(Position.Left),
          Mocks.playerService.buildComputerPlayer(Position.Top),
          Mocks.playerService.buildComputerPlayer(Position.Right),
        ]);
      });

      test('sets the random first current player and saves the game context', () {
        var computerPlayer = Player(Position.Top);
        List<Player> players = [
          computerPlayer,
          computerPlayer,
          computerPlayer,
          TestFactory.realPlayer
        ];
        when(Mocks.playerService.buildRealPlayer()).thenReturn(TestFactory.realPlayer);
        when(Mocks.playerService.buildComputerPlayer(any)).thenReturn(computerPlayer);
        var returnedGameContext = gameService.startSoloGame();

        GameContext savedGameContext =
            verify(Mocks.gameContextRepository.save(captureAny)).captured.single;
        var expectedGameContext =
            GameContext(players, [Turn(1, savedGameContext.turns[0].firstPlayer)]);
        expect(returnedGameContext, expectedGameContext);
      });
    });

    group('save', () {
      test('returns the saved context', () {
        var gameContext = MockGameContext();
        var savedGameContext = GameContext(
          [TestFactory.computerPlayer, TestFactory.realPlayer],
          [Turn(1, TestFactory.computerPlayer)],
        );

        when(Mocks.gameContextRepository.save(any)).thenReturn(savedGameContext);

        expect(gameService.save(gameContext), savedGameContext);

        verify(Mocks.gameContextRepository.save(gameContext));
      });
    });

    group('read', () {
      test('returns the read context', () {
        var readGameContext = GameContext(
          [TestFactory.computerPlayer, TestFactory.realPlayer],
          [Turn(1, TestFactory.computerPlayer)],
        );

        when(Mocks.gameContextRepository.read()).thenReturn(readGameContext);

        expect(gameService.read(), readGameContext);

        verify(Mocks.gameContextRepository.read());
      });
    });

    group('startTurn', () {
      test('returns the new turn when turnAlreadyCreated is false', () {
        GameContext mockedGameContext = MockGameContext();
        var turn = Turn(1, TestFactory.computerPlayer);
        var readGameContext = GameContext([TestFactory.realPlayer], [turn]);

        when(mockedGameContext.nextTurn()).thenReturn(readGameContext);
        when(Mocks.gameContextRepository.read()).thenReturn(mockedGameContext);
        when(Mocks.cardService.distributeCards(any)).thenReturn([TestFactory.cards[0]]);
        when(Mocks.gameContextRepository.save(any)).thenReturn(readGameContext);

        expect(gameService.startTurn(false), readGameContext);

        verify(Mocks.gameContextRepository.read());
        verify(Mocks.cardService.initializeCards());
      });

      test('returns the new turn when turnAlreadyCreated is true', () {
        GameContext mockedGameContext = MockGameContext();
        var turn = Turn(1, TestFactory.computerPlayer);

        when(Mocks.gameContextRepository.read()).thenReturn(mockedGameContext);
        when(mockedGameContext.players).thenReturn([TestFactory.realPlayer]);
        when(mockedGameContext.lastTurn).thenReturn(turn);
        when(Mocks.cardService.distributeCards(any)).thenReturn([TestFactory.cards[0]]);
        when(Mocks.gameContextRepository.save(any)).thenReturn(mockedGameContext);

        expect(gameService.startTurn(true), mockedGameContext);

        verify(Mocks.gameContextRepository.read());
        verifyNever(mockedGameContext.nextTurn());
      });

      test('distributes cards to players and sorts real players cards', () {
        Player mockedPlayer = MockPlayer();
        Player mockedRealPlayer = MockPlayer();
        var turn = Turn(1, TestFactory.computerPlayer);
        GameContext gameContext = GameContext([mockedPlayer, mockedRealPlayer], [turn]);
        var cards = [TestFactory.cards[0]];

        when(Mocks.gameContextRepository.read()).thenReturn(gameContext);
        when(mockedPlayer.isRealPlayer).thenReturn(false);
        when(mockedRealPlayer.isRealPlayer).thenReturn(true);
        when(Mocks.cardService.distributeCards(any)).thenReturn(cards);
        when(Mocks.gameContextRepository.save(any)).thenReturn(gameContext);

        expect(gameService.startTurn(true), gameContext);

        verify(mockedPlayer.cards = cards);
        verify(mockedRealPlayer.cards = cards);
        verify(mockedRealPlayer.sortCards());
        expect(verify(Mocks.cardService.distributeCards(5)).callCount, 2);
      });

      test('distributes 1 card to display and stores new gameContext', () {
        var cards = [TestFactory.cards[0]];
        var turn = Turn(1, TestFactory.computerPlayer);
        var newTurn = Turn(1, TestFactory.computerPlayer)..card = TestFactory.cards[0];
        GameContext gameContext = GameContext([TestFactory.realPlayer], [turn]);
        GameContext newGameContext =
            GameContext([TestFactory.realPlayerWithCards(cards)], [newTurn]);

        when(Mocks.gameContextRepository.read()).thenReturn(gameContext);
        when(Mocks.cardService.distributeCards(any)).thenReturn(cards);
        when(Mocks.gameContextRepository.save(any)).thenReturn(newGameContext);

        expect(gameService.startTurn(true), newGameContext);

        verify(Mocks.cardService.distributeCards(1));
        verify(Mocks.gameContextRepository.save(newGameContext));
      });
    });
  });
}
