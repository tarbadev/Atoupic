import 'package:atoupic/bloc/bloc.dart';
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
      when(Mocks.currentTurnBloc.state).thenAnswer((_) => 12);

      await tester.pumpWidget(buildTestableWidget(
        InGameView(),
      ));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turn, 'Turn 12');
    });

    group('on TurnCreated state from GameBloc', () {
      testWidgets('adds a Pass event when player is computer', (WidgetTester tester) async {
        when(Mocks.gameBloc.state)
            .thenAnswer((_) => TurnCreated(Turn(1, TestFactory.computerPlayer)));

        await tester.pumpWidget(buildTestableWidget(InGameView()));

        verify(Mocks.takeOrPassBloc.add(Pass(TestFactory.computerPlayer)));
      });

      testWidgets('displays take of pass dialog when player is real player',
          (WidgetTester tester) async {
        var card = Card(CardColor.Heart, CardHead.Ace);
        when(Mocks.gameBloc.state)
            .thenAnswer((_) => TurnCreated(Turn(1, TestFactory.realPlayer)..card = card));

        await tester.pumpWidget(buildTestableWidget(InGameView()));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);
        expect(inGameViewTester.takeOrPass.isVisible, isTrue);
      });
    });

    group('on PlayerPassed state from TakeOrPassBloc', () {
      testWidgets('adds a Pass event when next player is computer', (WidgetTester tester) async {
        var mockedGameContext = MockGameContext();

        when(Mocks.takeOrPassBloc.state).thenAnswer((_) => PlayerPassed(mockedGameContext));
        when(mockedGameContext.lastTurn).thenReturn(Turn(1, TestFactory.computerPlayer));
        when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.computerPlayer);

        await tester.pumpWidget(buildTestableWidget(InGameView()));

        verify(Mocks.takeOrPassBloc.add(Pass(TestFactory.computerPlayer)));
      });

      testWidgets('displays take of pass dialog when player is real player',
          (WidgetTester tester) async {
        var mockedGameContext = MockGameContext();

        when(Mocks.takeOrPassBloc.state).thenAnswer((_) => PlayerPassed(mockedGameContext));
        when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
        when(mockedGameContext.lastTurn).thenReturn(
            Turn(1, TestFactory.computerPlayer)..card = Card(CardColor.Heart, CardHead.Ace));

        await tester.pumpWidget(buildTestableWidget(InGameView()));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);
        expect(inGameViewTester.takeOrPass.isVisible, isTrue);
      });

      testWidgets('adds a Pass event on pass tap', (WidgetTester tester) async {
        var mockedGameContext = MockGameContext();
        var turn = Turn(1, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace);

        when(Mocks.takeOrPassBloc.state).thenAnswer((_) => PlayerPassed(mockedGameContext));
        when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
        when(mockedGameContext.lastTurn).thenReturn(turn);

        await tester.pumpWidget(buildTestableWidget(InGameView()));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);
        await inGameViewTester.takeOrPass.tapOnPass();
        verify(Mocks.takeOrPassBloc.add(Pass(TestFactory.realPlayer)));
      });

      testWidgets('adds a Take event on take tap', (WidgetTester tester) async {
        var mockedGameContext = MockGameContext();
        var turn = Turn(1, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace);

        when(Mocks.takeOrPassBloc.state).thenAnswer((_) => PlayerPassed(mockedGameContext));
        when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
        when(mockedGameContext.lastTurn).thenReturn(turn);

        await tester.pumpWidget(buildTestableWidget(InGameView()));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);
        await inGameViewTester.takeOrPass.tapOnTake();
        verify(Mocks.takeOrPassBloc.add(Take(TestFactory.realPlayer, turn.card.color)));
      });

      testWidgets('displays take of pass round 2 dialog when player is real player',
          (WidgetTester tester) async {
        var mockedGameContext = MockGameContext();

        when(Mocks.takeOrPassBloc.state).thenAnswer((_) => PlayerPassed(mockedGameContext));
        when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
        when(mockedGameContext.lastTurn).thenReturn(Turn(1, TestFactory.computerPlayer)
          ..round = 2
          ..card = Card(CardColor.Heart, CardHead.Ace));

        await tester.pumpWidget(buildTestableWidget(InGameView()));
        await tester.pump();

        var inGameViewTester = InGameViewTester(tester);
        expect(inGameViewTester.takeOrPass.isVisible, isTrue);

        await inGameViewTester.takeOrPass.tapOnColorChoice(CardColor.Spade);
        await inGameViewTester.takeOrPass.tapOnTake();

        verify(Mocks.takeOrPassBloc.add(Take(TestFactory.realPlayer, CardColor.Spade)));
      });
    });

    testWidgets('triggers a NewTurn event on SoloGameInitialized', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => SoloGameInitialized());

      await tester.pumpWidget(buildTestableWidget(
        InGameView(),
        currentTurn: Turn(12, MockPlayer())..card = Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pumpAndSettle();

      verify(Mocks.gameBloc.add(NewTurn()));
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

        verify(Mocks.store.dispatch(SetCurrentViewAction(AtoupicView.Home)));
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

        verify(Mocks.store.dispatch(StartSoloGameAction()));
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
