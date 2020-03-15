import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_reducer.dart';
import 'package:atoupic/application/ui/entity/score_display.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/test_factory.dart';

void main() {
  setupDependencyInjectorForTest();

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
