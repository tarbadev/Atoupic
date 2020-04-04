import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/widget/score.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../tester/score_tester.dart';

void main() {
  group('Score', () {
    testWidgets('initializes at 0 and updates current score on TurnEnded',
        (WidgetTester tester) async {
      whenListen(
          Mocks.gameBloc, Stream.fromIterable([NotStarted(), TurnEnded(TestFactory.turnResult)]));

      await tester.pumpWidget(buildTestableWidget(Score()));

      var scoreTester = ScoreTester(tester);
      expect(scoreTester.isVisible, isTrue);
      expect(scoreTester.them, 0);
      expect(scoreTester.us, 0);

      await tester.pump();

      expect(scoreTester.them, 102);
      expect(scoreTester.us, 50);
    });

    testWidgets('resets current score on first TurnCreated', (WidgetTester tester) async {
      when(Mocks.gameBloc.state).thenAnswer((_) => TurnEnded(TestFactory.turnResult));
      whenListen(
          Mocks.gameBloc,
          Stream.fromIterable([
            NotStarted(),
            TurnCreated(Turn(1, null)),
          ]));

      await tester.pumpWidget(buildTestableWidget(Score()));
      await tester.pump();

      var scoreTester = ScoreTester(tester);
      expect(scoreTester.isVisible, isTrue);
      expect(scoreTester.them, 0);
      expect(scoreTester.us, 0);
    });
  });
}
