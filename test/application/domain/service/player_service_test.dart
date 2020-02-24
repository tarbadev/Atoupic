import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../fake_application_injector.dart';
import '../../../mock_definition.dart';
import '../../../test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('PlayerService', () {
    PlayerService playerService;

    setUp(() {
      playerService = PlayerService();
    });

    test('buildRealPlayer returns a player', () {
      var cards = [
        Card(CardColor.Club, CardHead.Seven),
        Card(CardColor.Club, CardHead.Eight),
        Card(CardColor.Club, CardHead.Nine),
        Card(CardColor.Club, CardHead.Ten),
        Card(CardColor.Club, CardHead.Jack),
      ];

      when(Mocks.cardService.distributeCards(any)).thenReturn(cards);

      var expectedPlayer = TestFactory.realPlayerWithCards(cards);
      var actualPlayer = playerService.buildRealPlayer();

      expect(actualPlayer, expectedPlayer);
      expect(listEquals(actualPlayer.cards, expectedPlayer.cards), isTrue);

      verify(Mocks.cardService.distributeCards(5));
    });

    test('buildComputerPlayer returns a player', () {
      var cards = [
        Card(CardColor.Club, CardHead.Seven),
        Card(CardColor.Club, CardHead.Eight),
        Card(CardColor.Club, CardHead.Nine),
        Card(CardColor.Club, CardHead.Ten),
        Card(CardColor.Club, CardHead.Jack),
      ];

      when(Mocks.cardService.distributeCards(any)).thenReturn(cards);

      var expectedPlayer = Player(cards, Position.Top);
      var actualPlayer = playerService.buildComputerPlayer(Position.Top);

      expect(actualPlayer, expectedPlayer);
      expect(listEquals(actualPlayer.cards, expectedPlayer.cards), isTrue);

      verify(Mocks.cardService.distributeCards(5));
    });
  });
}