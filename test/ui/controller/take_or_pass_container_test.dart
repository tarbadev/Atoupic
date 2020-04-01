import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/ui/controller/take_or_pass_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../tester/take_or_pass_dialog_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.takeOrPassDialogBloc);
  });

  group('on ShowTakeOrPassDialog state from TakeOrPassDialogBloc', () {
    testWidgets('displays take or pass dialog', (WidgetTester tester) async {
      when(Mocks.takeOrPassDialogBloc.state).thenAnswer((_) =>
          ShowTakeOrPassDialog(TestFactory.realPlayer, Card(CardColor.Heart, CardHead.Ace), false));

      await tester.pumpWidget(buildTestableWidget(TakeOrPassDialogContainer()));
      await tester.pump();

      var takeOrPassTester = TakeOrPassDialogTester(tester);
      expect(takeOrPassTester.isVisible, isTrue);
    });

    testWidgets('adds a Take event on take tap', (WidgetTester tester) async {
      when(Mocks.takeOrPassDialogBloc.state).thenAnswer((_) =>
          ShowTakeOrPassDialog(TestFactory.realPlayer, Card(CardColor.Heart, CardHead.Ace), false));

      await tester.pumpWidget(buildTestableWidget(TakeOrPassDialogContainer()));
      await tester.pump();

      var takeOrPassTester = TakeOrPassDialogTester(tester);
      await takeOrPassTester.tapOnTake();
      verify(Mocks.takeOrPassDialogBloc.add(Take(TestFactory.realPlayer, CardColor.Heart)));
    });

    testWidgets('adds a Pass event on pass tap', (WidgetTester tester) async {
      when(Mocks.takeOrPassDialogBloc.state).thenAnswer((_) =>
          ShowTakeOrPassDialog(TestFactory.realPlayer, Card(CardColor.Heart, CardHead.Ace), false));

      await tester.pumpWidget(buildTestableWidget(TakeOrPassDialogContainer()));
      await tester.pump();

      var takeOrPassTester = TakeOrPassDialogTester(tester);
      await takeOrPassTester.tapOnPass();
      verify(Mocks.takeOrPassDialogBloc.add(Pass(TestFactory.realPlayer)));
    });

    testWidgets('displays take or pass round 2 dialog', (WidgetTester tester) async {
      when(Mocks.takeOrPassDialogBloc.state).thenAnswer((_) =>
          ShowTakeOrPassDialog(TestFactory.realPlayer, Card(CardColor.Heart, CardHead.Ace), true));

      await tester.pumpWidget(buildTestableWidget(TakeOrPassDialogContainer()));
      await tester.pump();

      var takeOrPassTester = TakeOrPassDialogTester(tester);
      expect(takeOrPassTester.isVisible, isTrue);
      expect(takeOrPassTester.colorChoices, [CardColor.Spade, CardColor.Club, CardColor.Diamond]);

      await takeOrPassTester.tapOnColorChoice(CardColor.Spade);
      await takeOrPassTester.tapOnTake();

      verify(Mocks.takeOrPassDialogBloc.add(Take(TestFactory.realPlayer, CardColor.Spade)));
    });
  });
}
