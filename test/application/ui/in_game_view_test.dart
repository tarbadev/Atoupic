import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';

void main() {
  setupDependencyInjectorForTest();

  group('InGameView', () {
    var gameContext;
    var firstPlayer;
    var card;

    setUp(() {
      card = Card(CardColor.Club, CardHead.Ace);
      firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
        TestFactory.realPlayer
      ];
      gameContext = GameContext(players, [Turn(1, firstPlayer)]);

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
    });

    testWidgets('calls startSoloGame and sets current player in game',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);

      await tester.pumpWidget(buildTestableWidget(inGameView));

      expect(inGameView.gameContext, gameContext);

      verifyInOrder([
        Mocks.atoupicGame.setPlayers(gameContext.players),
        Mocks.cardService.distributeCards(1),
        Mocks.atoupicGame
            .setCurrentPlayer(firstPlayer, inGameView.onTakeOrPassDecision),
        Mocks.atoupicGame.visible = true,
      ]);
    });

    group('onTakeOrPassDecision', () {
      testWidgets('sets the decision, saves the new context and sets the next player',
          (WidgetTester tester) async {
        var inGameView = InGameView();
        var computerPlayer = Player(TestFactory.cards, Position.Top);
        var updatedGameContext = MockGameContext();

        await tester.pumpWidget(buildTestableWidget(inGameView));

        inGameView.gameContext = MockGameContext();

        when(inGameView.gameContext.setDecision(any, any)).thenReturn(updatedGameContext);
        when(updatedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);

        inGameView.onTakeOrPassDecision(computerPlayer, Decision.Pass);

        verify(inGameView.gameContext.setDecision(
          computerPlayer,
          Decision.Pass,
        ));
        verify(Mocks.gameService.save(updatedGameContext));
        verify(updatedGameContext.nextPlayer());
        verify(Mocks.atoupicGame.setCurrentPlayer(
          TestFactory.realPlayer,
          inGameView.onTakeOrPassDecision,
        ));
      });
    });
  });
}
