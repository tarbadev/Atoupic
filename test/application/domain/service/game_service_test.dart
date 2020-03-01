import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helper/fake_application_injector.dart';
import '../../../helper/mock_definition.dart';
import '../../../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('GameService', () {
    GameService gameService;

    setUp(() {
      reset(Mocks.playerService);
      reset(Mocks.gameContextRepository);

      gameService = GameService(Mocks.gameContextRepository);
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

      test('sets the random first current player and saves the game context',
          () {
        var computerPlayer = Player(Position.Top);
        List<Player> players = [
          computerPlayer,
          computerPlayer,
          computerPlayer,
          TestFactory.realPlayer
        ];
        when(Mocks.playerService.buildRealPlayer())
            .thenReturn(TestFactory.realPlayer);
        when(Mocks.playerService.buildComputerPlayer(any))
            .thenReturn(computerPlayer);
        var returnedGameContext = gameService.startSoloGame();

        GameContext savedGameContext =
            verify(Mocks.gameContextRepository.save(captureAny))
                .captured
                .single;
        var expectedGameContext = GameContext(
            players, [Turn(1, savedGameContext.turns[0].firstPlayer)]);
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
  });
}
