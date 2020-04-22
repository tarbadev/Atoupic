import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/widget/take_or_pass.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../tester/take_or_pass_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  setUp(() {
    reset(Mocks.takeOrPassBloc);
  });

  group('TakeOrPass', () {
    group('on TurnCreated state from GameBloc', () {
      testWidgets('displays card', (WidgetTester tester) async {
        when(Mocks.gameBloc.state).thenAnswer((_) => TurnCreated(
            Turn(1, TestFactory.realPlayer)..card = Card(CardColor.Heart, CardHead.Ace)));

        await tester.pumpWidget(buildTestableWidget(TakeOrPass()));
        await tester.pump();

        var takeOrPassTester = TakeOrPassTester(tester);
        expect(takeOrPassTester.isVisible, isTrue);
      });

      testWidgets('adds a Take event on take tap', (WidgetTester tester) async {
        when(Mocks.gameBloc.state).thenAnswer((_) => TurnCreated(
            Turn(1, TestFactory.realPlayer)..card = Card(CardColor.Heart, CardHead.Ace)));
        when(Mocks.takeOrPassBloc.state)
            .thenAnswer((_) => ShowTakeOrPassRound1(TestFactory.realPlayer));

        await tester.pumpWidget(buildTestableWidget(TakeOrPass()));
        await tester.pump();

        var takeOrPassTester = TakeOrPassTester(tester);
        await takeOrPassTester.tapOnTake();
        verify(Mocks.takeOrPassBloc.add(Take(TestFactory.realPlayer, CardColor.Heart)));
      });

      testWidgets('adds a Pass event on pass tap', (WidgetTester tester) async {
        when(Mocks.gameBloc.state).thenAnswer((_) => TurnCreated(
            Turn(1, TestFactory.realPlayer)..card = Card(CardColor.Heart, CardHead.Ace)));
        when(Mocks.takeOrPassBloc.state)
            .thenAnswer((_) => ShowTakeOrPassRound1(TestFactory.realPlayer));

        await tester.pumpWidget(buildTestableWidget(TakeOrPass()));
        await tester.pump();

        var takeOrPassTester = TakeOrPassTester(tester);
        await takeOrPassTester.tapOnPass();
        verify(Mocks.takeOrPassBloc.add(Pass(TestFactory.realPlayer)));
      });

      testWidgets('displays take or pass round 2 dialog', (WidgetTester tester) async {
        when(Mocks.gameBloc.state).thenAnswer((_) => TurnCreated(
            Turn(1, TestFactory.realPlayer)..card = Card(CardColor.Heart, CardHead.Ace)));
        when(Mocks.takeOrPassBloc.state)
            .thenAnswer((_) => ShowTakeOrPassRound2(TestFactory.realPlayer));

        await tester.pumpWidget(buildTestableWidget(TakeOrPass()));
        await tester.pump();

        var takeOrPassTester = TakeOrPassTester(tester);
        expect(takeOrPassTester.isVisible, isTrue);
        expect(takeOrPassTester.colorChoices, [CardColor.Spade, CardColor.Club, CardColor.Diamond]);

        await takeOrPassTester.tapOnColorChoice(CardColor.Spade);

        verify(Mocks.takeOrPassBloc.add(Take(TestFactory.realPlayer, CardColor.Spade)));
      });
    });
  });
}
