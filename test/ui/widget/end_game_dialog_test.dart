import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/widget/end_game_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/testable_widget.dart';
import '../tester/game_result_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.takeOrPassDialogBloc);
  });

  group('on GameEnded state from GameBloc', () {
    testWidgets('displays result for winner', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => GameEnded(520, 102));

      await tester.pumpWidget(buildTestableWidget(EndGameDialog()));

      var gameResultTester = GameResultTester(tester);
      expect(gameResultTester.isVisible, isFalse);

      await tester.pump();

      expect(gameResultTester.isVisible, isTrue);
      expect(gameResultTester.usScore, 520);
      expect(gameResultTester.themScore, 102);
      expect(gameResultTester.result, 'Congratulations!');
    });

    testWidgets('displays result for looser', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => GameEnded(102, 520));

      await tester.pumpWidget(buildTestableWidget(EndGameDialog()));

      var gameResultTester = GameResultTester(tester);
      expect(gameResultTester.isVisible, isFalse);

      await tester.pump();

      expect(gameResultTester.isVisible, isTrue);
      expect(gameResultTester.usScore, 102);
      expect(gameResultTester.themScore, 520);
      expect(gameResultTester.result, 'You Lost!');
    });

    testWidgets('when click on home dispatches SetCurrentViewAction', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => GameEnded(520, 102));

      await tester.pumpWidget(buildTestableWidget(EndGameDialog()));
      await tester.pump();

      var gameResultTester = GameResultTester(tester);

      await gameResultTester.tapOnHome();

      verify(Mocks.appBloc.add(GameFinished()));
    });

    testWidgets('when click on new game dispatches StartSoloGameAction',
        (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => GameEnded(520, 102));

      await tester.pumpWidget(buildTestableWidget(EndGameDialog()));
      await tester.pump();

      var gameResultTester = GameResultTester(tester);

      await gameResultTester.tapOnNewGame();

      verify(Mocks.gameBloc.add(StartSoloGame()));
    });
  });
}
