import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_reducer.dart';
import 'package:atoupic/application/ui/entity/score_display.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

  group('setGameContext', () {
    test('stores the new gameContext in DB and returns the result', () {
      var gameContext = GameContext([], []);
      var action = SetGameContextAction(gameContext);
      var mockGameContext = MockGameContext();

      when(Mocks.gameService.save(any)).thenReturn(gameContext);

      expect(setGameContext(mockGameContext, action), gameContext);

      verify(Mocks.gameService.save(gameContext));
    });
  });

  group('addToScore', () {
    test('adds the result to the current score', () {
      var newUsScore = 120 + TestFactory.turnResult.verticalScore;
      var newThemScore = 430 + TestFactory.turnResult.horizontalScore;
      var scoreDisplay = ScoreDisplay(120, 430);
      var action = SetTurnResultAction(TestFactory.turnResult);

      expect(addToScore(scoreDisplay, action), ScoreDisplay(newUsScore, newThemScore));
    });

    test('returns current score when turnResult is null', () {
      var scoreDisplay = ScoreDisplay(120, 430);
      var action = SetTurnResultAction(null);

      expect(addToScore(scoreDisplay, action), scoreDisplay);
    });
  });
}
