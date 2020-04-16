import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('PlayerService', () {
    PlayerService playerService;

    setUp(() {
      playerService = PlayerService();
    });

    test('buildRealPlayer returns a player with ordered cards', () {
      var expectedPlayer = TestFactory.realPlayer;
      var actualPlayer = playerService.buildRealPlayer();

      expect(actualPlayer, expectedPlayer);
    });

    test('buildComputerPlayer returns a player', () {
      var expectedPlayer = TestFactory.topPlayer;
      var actualPlayer = playerService.buildComputerPlayer(Position.Top, expectedPlayer.name);

      expect(actualPlayer, expectedPlayer);
    });
  });
}
