import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/view/in_game_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../../in_game_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  group('InGameView', () {
    testWidgets('displays dialog if showTakeOrPassDialog is true', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        currentTurn: Turn(1, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.takeOrPass.isVisible, isTrue);
    });

    testWidgets('displays round 2 dialog if showTakeOrPassDialog is true and round = 2',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        currentTurn: Turn(1, MockPlayer())
          ..round = 2
          ..card = Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.takeOrPass.isVisible, isTrue);
      expect(inGameViewTester.takeOrPass.colorChoices,
          [CardColor.Spade, CardColor.Heart, CardColor.Diamond]);
    });

    testWidgets('displays current turn number', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        currentTurn: Turn(12, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace),
      ));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turn, 'Turn 12');
    });

    testWidgets('dispatches a PassAction on pass tap', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        currentTurn: Turn(1, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace),
        realPlayer: TestFactory.realPlayer,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      await inGameViewTester.takeOrPass.tapOnPass();
      verify(Mocks.store.dispatch(ShowTakeOrPassDialogAction(false)));
      verify(Mocks.store.dispatch(PassDecisionAction(TestFactory.realPlayer)));
    });

    testWidgets('dispatches a TakeAction on take tap', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        currentTurn: Turn(1, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace),
        realPlayer: TestFactory.realPlayer,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      await inGameViewTester.takeOrPass.tapOnTake();
      verify(Mocks.store.dispatch(ShowTakeOrPassDialogAction(false)));
      verify(Mocks.store.dispatch(TakeDecisionAction(TestFactory.realPlayer, CardColor.Club)));
    });

    testWidgets('dispatches a TakeAction on round 2 take tap', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        realPlayer: TestFactory.realPlayer,
        currentTurn: Turn(1, MockPlayer())
          ..round = 2
          ..card = Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      await inGameViewTester.takeOrPass.tapOnColorChoice(CardColor.Heart);
      await inGameViewTester.takeOrPass.tapOnTake();
      verify(Mocks.store.dispatch(ShowTakeOrPassDialogAction(false)));
      verify(Mocks.store.dispatch(TakeDecisionAction(TestFactory.realPlayer, CardColor.Heart)));
    });

    testWidgets('displays dialog when turnResult is not null', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        currentTurn: Turn(1, TestFactory.computerPlayer)..turnResult = TestFactory.turnResult,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turnResult.isVisible, isTrue);
      expect(inGameViewTester.turnResult.taker, Position.Left);
      expect(inGameViewTester.turnResult.win, isTrue);
      expect(inGameViewTester.turnResult.takerScore, 102);
      expect(inGameViewTester.turnResult.opponentScore, 50);
    });

    testWidgets('dispatches a StartTurnAction and resets turn result when pressing Next',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        usScore: 102,
        themScore: 31,
        currentTurn: Turn(1, TestFactory.computerPlayer)..turnResult = TestFactory.turnResult,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turnResult.isVisible, isTrue);

      await inGameViewTester.turnResult.tapOnNext();

      verify(Mocks.store.dispatch(SetTurnResultAction(null)));
      verify(Mocks.store.dispatch(StartTurnAction()));
    });

    group('when game is over', () {
      testWidgets('displays result for winner', (WidgetTester tester) async {
        var inGameView = InGameView();

        await tester.pumpWidget(buildTestableWidget(
          inGameView,
          usScore: 520,
          themScore: 102,
        ));

        var inGameViewTester = InGameViewTester(tester);
        expect(inGameViewTester.gameResult.isVisible, isFalse);

        await tester.pump();

        expect(inGameViewTester.gameResult.isVisible, isTrue);
        expect(inGameViewTester.gameResult.usScore, 520);
        expect(inGameViewTester.gameResult.themScore, 102);
        expect(inGameViewTester.gameResult.result, 'Congratulations!');
      });

      testWidgets('displays result for looser', (WidgetTester tester) async {
        var inGameView = InGameView();

        await tester.pumpWidget(buildTestableWidget(
          inGameView,
          usScore: 102,
          themScore: 520,
        ));

        var inGameViewTester = InGameViewTester(tester);
        expect(inGameViewTester.gameResult.isVisible, isFalse);

        await tester.pump();

        expect(inGameViewTester.gameResult.isVisible, isTrue);
        expect(inGameViewTester.gameResult.usScore, 102);
        expect(inGameViewTester.gameResult.themScore, 520);
        expect(inGameViewTester.gameResult.result, 'You Lost!');
      });

      testWidgets('when click on home dispatches SetCurrentViewAction', (WidgetTester tester) async {
        var inGameView = InGameView();

        await tester.pumpWidget(buildTestableWidget(
          inGameView,
          usScore: 520,
          themScore: 102,
        ));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);

        await inGameViewTester.gameResult.tapOnHome();

        verify(Mocks.store.dispatch(SetCurrentViewAction(AtoupicView.Home)));
      });
    });

    testWidgets('displays current score', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        usScore: 102,
        themScore: 430,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.score.isVisible, isTrue);
      expect(inGameViewTester.score.them, 430);
      expect(inGameViewTester.score.us, 102);
    });
  });
}
