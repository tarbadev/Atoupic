import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:atoupic/game/components/player_component.dart';
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
      reset(Mocks.atoupicGame);
      reset(Mocks.gameService);
      reset(Mocks.cardService);

      card = Card(CardColor.Club, CardHead.Ace);
      firstPlayer = TestFactory.computerPlayer;
      List<Player> players = [
        Player(TestFactory.cards.sublist(0, 5), Position.Left),
        firstPlayer,
        TestFactory.realPlayer,
        Player(TestFactory.cards.sublist(0, 5), Position.Right),
      ];
      gameContext = GameContext(players, [Turn(1, firstPlayer)]);

      when(Mocks.gameService.startSoloGame()).thenReturn(gameContext);
      when(Mocks.gameService.save(any)).thenReturn(gameContext);
      when(Mocks.cardService.distributeCards(any)).thenReturn([card]);
    });

    testWidgets('calls startSoloGame and sets current player in game',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(inGameView));
      inGameView.startSoloGame();

      expect(inGameView.gameContext, gameContext);

      List<PlayerComponent> capturedList =
          verify(Mocks.atoupicGame.setPlayers(captureAny)).captured[0];
      expect(capturedList.length, gameContext.players.length);
      verifyInOrder([
        Mocks.atoupicGame.visible = true,
        Mocks.cardService.distributeCards(1),
      ]);
    });

    group('takeOrPass', () {
      testWidgets('gets one card and display takeOrPassDialog to real Player',
          (WidgetTester tester) async {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(TestFactory.cards.sublist(0, 5), Position.Left),
          Player(TestFactory.cards.sublist(0, 5), Position.Right),
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        var inGameView = InGameView()..gameContext = gameContext;

        await tester.pumpWidget(buildTestableWidget(inGameView));

        when(Mocks.cardService.distributeCards(any)).thenReturn([card]);

        inGameView.takeOrPass();

        verifyInOrder([
          Mocks.cardService.distributeCards(1),
        ]);
      });
    });

    group('onTakeOrPassDecision', () {
      testWidgets(
          'sets the decision, saves the new context and sets the next player',
          (WidgetTester tester) async {
        var inGameView = InGameView();
        var computerPlayer = Player(TestFactory.cards, Position.Top);
        var updatedGameContext = MockGameContext();

        await tester.pumpWidget(buildTestableWidget(inGameView));

        var originalGameContext = MockGameContext();
        inGameView.gameContext = originalGameContext;

        when(inGameView.gameContext.setDecision(any, any))
            .thenReturn(updatedGameContext);
        when(updatedGameContext.nextPlayer())
            .thenReturn(TestFactory.realPlayer);
        when(Mocks.gameService.save(any)).thenReturn(updatedGameContext);
        when(updatedGameContext.players).thenReturn([computerPlayer]);
        when(updatedGameContext.turns).thenReturn([
          Turn(1, computerPlayer)
            ..playerDecisions[computerPlayer] = Decision.Pass
        ]);

        inGameView.onTakeOrPassDecision(computerPlayer, Decision.Pass);

        verify(originalGameContext.setDecision(
          computerPlayer,
          Decision.Pass,
        ));
        verify(Mocks.gameService.save(updatedGameContext));
        verify(updatedGameContext.nextPlayer());
        List<PlayerComponent> capturedList =
            verify(Mocks.atoupicGame.setPlayers(captureAny)).captured.single;
        expect(capturedList[0].isRealPlayer, isFalse);
        expect(capturedList[0].passed, true);
        expect(capturedList[0].position, Position.Top);
      });
    });
  });
}
