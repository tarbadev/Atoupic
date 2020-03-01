import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helper/fake_application_injector.dart';
import '../../../helper/mock_definition.dart';
import '../../../helper/test_factory.dart';

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
      var expectedPlayer = Player(Position.Top);
      var actualPlayer = playerService.buildComputerPlayer(Position.Top);

      expect(actualPlayer, expectedPlayer);
    });
  });
}
