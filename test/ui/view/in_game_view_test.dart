import 'package:atoupic/bloc/bloc.dart';
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
import '../tester/in_game_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.takeOrPassDialogBloc);
    reset(Mocks.gameBloc);
  });

  group('InGameView', () {
    testWidgets('displays current turn number', (WidgetTester tester) async {
      when(Mocks.currentTurnBloc.state).thenAnswer((_) => 12);

      await tester.pumpWidget(buildTestableWidget(InGameView()));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turn, 'Turn 12');
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
      verify(Mocks.gameBloc.add(NewTurn()));
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

      testWidgets('when click on home dispatches SetCurrentViewAction',
          (WidgetTester tester) async {
        var inGameView = InGameView();

        await tester.pumpWidget(buildTestableWidget(
          inGameView,
          usScore: 520,
          themScore: 102,
        ));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);

        await inGameViewTester.gameResult.tapOnHome();

        verify(Mocks.appBloc.add(GameFinished()));
      });

      testWidgets('when click on new game dispatches StartSoloGameAction',
          (WidgetTester tester) async {
        var inGameView = InGameView();

        await tester.pumpWidget(buildTestableWidget(
          inGameView,
          usScore: 520,
          themScore: 102,
        ));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);

        await inGameViewTester.gameResult.tapOnNewGame();

        verify(Mocks.gameBloc.add(StartSoloGame()));
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
