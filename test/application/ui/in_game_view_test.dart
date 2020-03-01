import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
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
    testWidgets('displays dialog if showTakeOrPassDialog is true',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        takeOrPassCard: Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.takeOrPass.isVisible, isTrue);
    });

    testWidgets('displays current turn number', (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        turn: 12,
      ));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turn, 'Turn 12');
    });

    testWidgets('dispatches a PassAction on pass tap',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        takeOrPassCard: Card(CardColor.Club, CardHead.Ace),
        realPlayer: TestFactory.realPlayer,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      await inGameViewTester.takeOrPass.tapOnPass();
      verify(Mocks.store.dispatch(ShowTakeOrPassDialogAction(false)));
      verify(Mocks.store.dispatch(PassDecisionAction(TestFactory.realPlayer)));
    });

    testWidgets('dispatches a TakeAction on take tap',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        takeOrPassCard: Card(CardColor.Club, CardHead.Ace),
        realPlayer: TestFactory.realPlayer,
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      await inGameViewTester.takeOrPass.tapOnTake();
      verify(Mocks.store.dispatch(ShowTakeOrPassDialogAction(false)));
      verify(Mocks.store.dispatch(TakeDecisionAction(TestFactory.realPlayer)));
    });
  });
}
