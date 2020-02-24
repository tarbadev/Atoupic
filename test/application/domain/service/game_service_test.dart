import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../fake_application_injector.dart';
import '../../../mock_definition.dart';
import '../../../test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('GameService', () {
    GameService gameService;

    setUp(() {
      reset(Mocks.gameService);
      gameService = GameService();
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

      test('sets the players in game and displays the game', () {
        var computerPlayer = Player(TestFactory.cards, Position.Top);
        when(Mocks.playerService.buildRealPlayer())
            .thenReturn(TestFactory.realPlayer);
        when(Mocks.playerService.buildComputerPlayer(any))
            .thenReturn(computerPlayer);

        gameService.startSoloGame();

        verifyInOrder([
          Mocks.atoupicGame.setPlayers([
            computerPlayer,
            computerPlayer,
            computerPlayer,
            TestFactory.realPlayer,
          ]),
          Mocks.atoupicGame.visible = true,
        ]);
      });

      test('sets the random first current player', () {
        var computerPlayer = Player(TestFactory.cards.sublist(0, 2), Position.Top);
        when(Mocks.playerService.buildRealPlayer())
            .thenReturn(TestFactory.realPlayer);
        when(Mocks.playerService.buildComputerPlayer(any))
            .thenReturn(computerPlayer);

        gameService.startSoloGame();

        var player = verify(Mocks.atoupicGame.setCurrentPlayer(
                captureAny, gameService.onTakeOrPassDecision))
            .captured
            .single;
        expect([TestFactory.realPlayer, computerPlayer].contains(player), isTrue);
      });
    });
  });
}
