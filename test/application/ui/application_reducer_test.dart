import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/application_reducer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';

void main() {
  setupDependencyInjectorForTest();

  group('setGameContext',(){
    test('stores the new gameContext in DB and returns the result', () {
      var gameContext = GameContext([], []);
      var action = SetGameContextAction(gameContext);
      var mockGameContext = MockGameContext();

      when(Mocks.gameService.save(any)).thenReturn(gameContext);

      expect(setGameContext(mockGameContext, action), gameContext);

      verify(Mocks.gameService.save(gameContext));
    });
  });
}