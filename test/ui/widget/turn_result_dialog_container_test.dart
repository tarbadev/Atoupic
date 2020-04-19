import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/widget/turn_result_dialog_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../tester/turn_result_dialog_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.takeOrPassDialogBloc);
  });

  group('on TurnEnded state from GameBloc', () {
    testWidgets('displays turn result dialog', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => TurnEnded(TestFactory.turnResult));

      await tester.pumpWidget(buildTestableWidget(TurnResultDialogContainer()));
      await tester.pump();

      var turnResultTester = TurnResultTester(tester);
      expect(turnResultTester.isVisible, isTrue);
      expect(turnResultTester.taker, 'Taker: ${TestFactory.leftPlayer.name}');
      expect(turnResultTester.win, isTrue);
      expect(turnResultTester.takerScore, 102);
      expect(turnResultTester.opponentScore, 50);
    });

    testWidgets('dispatches a StartTurnAction and resets turn result when pressing Next',
        (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => TurnEnded(TestFactory.turnResult));

      await tester.pumpWidget(buildTestableWidget(TurnResultDialogContainer()));
      await tester.pump();

      var turnResultTester = TurnResultTester(tester);
      expect(turnResultTester.isVisible, isTrue);

      await turnResultTester.tapOnNext();

      verify(Mocks.gameBloc.add(NewTurn()));
    });
  });
}
