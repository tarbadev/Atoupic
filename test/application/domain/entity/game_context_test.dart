import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helper/test_factory.dart';

void main() {
  group('GameContext', () {
    group('setDecision', () {
      test('stores the players decision', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(TestFactory.cards.sublist(0, 5), Position.Left),
          firstPlayer,
          Player(TestFactory.cards.sublist(0, 5), Position.Right),
          TestFactory.realPlayer
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        var newGameContext =
            gameContext.setDecision(firstPlayer, Decision.Pass);
        expect(newGameContext.turns[0].playerDecisions[firstPlayer],
            Decision.Pass);
      });
    });

    group('nextPlayer', () {
      test('when next player is after the first player', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(TestFactory.cards.sublist(0, 5), Position.Left),
          Player(TestFactory.cards.sublist(0, 5), Position.Right),
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)..playerDecisions[firstPlayer] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when next player is first players list', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          TestFactory.realPlayer,
          Player(TestFactory.cards.sublist(0, 5), Position.Left),
          Player(TestFactory.cards.sublist(0, 5), Position.Right),
          firstPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)..playerDecisions[firstPlayer] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when all players already passed', () {
        var firstPlayer = TestFactory.computerPlayer;
        var secondPlayer = Player(TestFactory.cards.sublist(0, 5), Position.Left);
        var thirdPlayer = Player(TestFactory.cards.sublist(0, 5), Position.Right);
        List<Player> players = [
          firstPlayer,
          secondPlayer,
          thirdPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..playerDecisions[firstPlayer] = Decision.Pass
            ..playerDecisions[secondPlayer] = Decision.Pass
            ..playerDecisions[thirdPlayer] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });
    });
  });
}
