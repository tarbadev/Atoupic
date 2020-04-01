import 'package:atoupic/bloc/bloc.dart';
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
    reset(Mocks.gameBloc);
  });

  group('InGameView', () {
    testWidgets('displays current turn number', (WidgetTester tester) async {
      when(Mocks.currentTurnBloc.state).thenAnswer((_) => 12);

      await tester.pumpWidget(buildTestableWidget(InGameView()));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.turn, 'Turn 12');
    });

    testWidgets('displays current score', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => TurnEnded(TestFactory.turnResult));

      await tester.pumpWidget(buildTestableWidget(InGameView()));

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.score.isVisible, isTrue);
      expect(inGameViewTester.score.them, 102);
      expect(inGameViewTester.score.us, 50);
    });
  });
}
