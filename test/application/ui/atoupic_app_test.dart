import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../home_view_tester.dart';
import '../../helper/fake_application_injector.dart';
import '../../in_game_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  group('AtoupicApp', () {
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

    testWidgets('loads the game on startup', (WidgetTester tester) async {
      await tester.pumpWidget(AtoupicApp());

      verify(Mocks.atoupicGame.widget);
    });

    testWidgets('changes view when clicking on solo', (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);
      var inGameViewTester = InGameViewTester(tester);

      await tester.pumpWidget(AtoupicApp());

      expect(homeViewTester.isVisible, isTrue);
      expect(inGameViewTester.isVisible, isFalse);

      await homeViewTester.tapOnSolo();
      await tester.pump();

      expect(homeViewTester.isVisible, isFalse);
      expect(inGameViewTester.isVisible, isTrue);
    });
  });
}
