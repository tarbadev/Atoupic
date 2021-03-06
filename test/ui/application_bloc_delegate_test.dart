import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:bloc/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../helper/mock_definition.dart';
import '../helper/test_factory.dart';

void main() {
  ApplicationBlocDelegate applicationBlocDelegate;

  setUp(() {
    applicationBlocDelegate = ApplicationBlocDelegate(
      Mocks.gameBloc,
      Mocks.takeOrPassBloc,
      Mocks.errorReporter,
      Mocks.declarationsBloc,
    );
  });

  group('On SoloGameInitialized', () {
    test('triggers NewTurn with turnAlreadyCreated true', () {
      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: StartSoloGame(),
            nextState: SoloGameInitialized(),
          ));

      verify(Mocks.gameBloc.add(NewTurn(turnAlreadyCreated: true)));
    });
  });

  group('on TurnCreated', () {
    test('adds a Pass event when player is computer', () {
      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: SoloGameInitialized(),
            event: NewTurn(turnAlreadyCreated: true),
            nextState: TurnCreated(Turn(1, TestFactory.topPlayer)),
          ));

      verify(Mocks.takeOrPassBloc
          .add(ComputerPlayerTurn(TestFactory.topPlayer, Turn(1, TestFactory.topPlayer))));
    });

    test('adds RealPlayerTurn event when player is real player', () {
      var card = Card(CardColor.Heart, CardHead.Ace);
      var turn = Turn(1, TestFactory.realPlayer)..card = card;

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: SoloGameInitialized(),
            event: NewTurn(turnAlreadyCreated: true),
            nextState: TurnCreated(turn),
          ));

      verify(Mocks.takeOrPassBloc.add(RealPlayerTurn(TestFactory.realPlayer, turn)));
    });
  });

  group('on PlayerPassed state', () {
    test('adds a ComputerPlayerTurn event when next player is computer', () {
      var mockedGameContext = MockGameContext();

      var turn = Turn(1, TestFactory.topPlayer);
      when(mockedGameContext.lastTurn).thenReturn(turn);
      when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.topPlayer);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: HideTakeOrPass(),
            event: Pass(null),
            nextState: PlayerPassed(mockedGameContext),
          ));

      verify(Mocks.takeOrPassBloc.add(ComputerPlayerTurn(TestFactory.topPlayer, turn)));
    });

    test('displays take of pass dialog when player is real player', () {
      var mockedGameContext = MockGameContext();
      var turn = Turn(1, TestFactory.topPlayer)..card = Card(CardColor.Heart, CardHead.Ace);

      when(mockedGameContext.nextPlayer()).thenReturn(TestFactory.realPlayer);
      when(mockedGameContext.lastTurn).thenReturn(turn);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: HideTakeOrPass(),
            event: Pass(null),
            nextState: PlayerPassed(mockedGameContext),
          ));

      verify(Mocks.takeOrPassBloc.add(RealPlayerTurn(TestFactory.realPlayer, turn)));
    });
  });

  group('On PlayerTook', () {
    test('triggers NewCardRound', () {
      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: HideTakeOrPass(),
            event: Take(null, null),
            nextState: PlayerTook(),
          ));

      verify(Mocks.gameBloc.add(NewCardRound()));
    });
  });

  group('On CardRoundCreated', () {
    test('triggers a AnalyzeDeclarations event on first cardRound', () {
      var mockGameContext = MockGameContext();

      when(mockGameContext.lastTurn).thenReturn(
          Turn(1, TestFactory.leftPlayer)..cardRounds = [CardRound(TestFactory.leftPlayer)]);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: CardRoundCreated(mockGameContext),
          ));

      verify(Mocks.declarationsBloc.add(AnalyseDeclarations(mockGameContext)));
    });

    group('after second card round', () {
      test('triggers a RealPlayerCanChooseCard when next card player is real player', () {
        var mockGameContext = MockGameContext();
        final player = TestFactory.realPlayerWithCards(TestFactory.cards.sublist(0, 2));

        when(mockGameContext.nextCardPlayer()).thenReturn(player);
        when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([TestFactory.cards[0]]);
        when(mockGameContext.lastTurn).thenReturn(
            Turn(1, TestFactory.leftPlayer)..cardRounds = [CardRound(TestFactory.leftPlayer), CardRound(TestFactory.leftPlayer)]);

        applicationBlocDelegate.onTransition(
            Mocks.gameBloc,
            Transition(
              currentState: NotStarted(),
              event: NewCardRound(),
              nextState: CardRoundCreated(mockGameContext),
            ));

        verify(mockGameContext.nextCardPlayer());
        verify(mockGameContext.getPossibleCardsToPlay(player));
        verify(Mocks.gameBloc.add(RealPlayerCanChooseCard([TestFactory.cards[0]])));
      });

      test('triggers a PlayCardForAi when next card player is computer player', () {
        var card = TestFactory.cards[0];
        var mockGameContext = MockGameContext();

        final player = TestFactory.topPlayer..cards = TestFactory.cards.sublist(0, 2);
        when(mockGameContext.nextCardPlayer()).thenReturn(player);
        when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([card]);
        when(mockGameContext.lastTurn).thenReturn(
            Turn(1, TestFactory.leftPlayer)..cardRounds = [CardRound(TestFactory.leftPlayer), CardRound(TestFactory.leftPlayer)]);

        applicationBlocDelegate.onTransition(
            Mocks.gameBloc,
            Transition(
              currentState: NotStarted(),
              event: NewCardRound(),
              nextState: CardRoundCreated(mockGameContext),
            ));

        verify(mockGameContext.nextCardPlayer());
        verify(mockGameContext.getPossibleCardsToPlay(player));
        verify(Mocks.gameBloc.add(PlayCardForAi(player, [card])));
      });
    });
  });

  group('On FinishedAnalyzingDeclarations', () {
    test('triggers a RealPlayerCanChooseCard when next card player is real player', () {
      var mockGameContext = MockGameContext();
      final player = TestFactory.realPlayerWithCards(TestFactory.cards.sublist(0, 2));

      when(mockGameContext.nextCardPlayer()).thenReturn(player);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([TestFactory.cards[0]]);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: FinishedAnalyzingDeclarations(mockGameContext),
          ));

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(player));
      verify(Mocks.gameBloc.add(RealPlayerCanChooseCard([TestFactory.cards[0]])));
    });

    test('triggers a PlayCardForAi when next card player is computer player', () {
      var card = TestFactory.cards[0];
      var mockGameContext = MockGameContext();

      final player = TestFactory.topPlayer..cards = TestFactory.cards.sublist(0, 2);
      when(mockGameContext.nextCardPlayer()).thenReturn(player);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([card]);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: FinishedAnalyzingDeclarations(mockGameContext),
          ));

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(player));
      verify(Mocks.gameBloc.add(PlayCardForAi(player, [card])));
    });
  });

  group('On CardPlayed', () {
    test('triggers a RealPlayerCanChooseCard when next card player is real player', () {
      var mockGameContext = MockGameContext();
      final player = TestFactory.realPlayerWithCards(TestFactory.cards.sublist(0, 2));

      when(mockGameContext.nextCardPlayer()).thenReturn(player);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([TestFactory.cards[0]]);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: CardPlayed(mockGameContext),
          ));

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(player));
      verify(Mocks.gameBloc.add(RealPlayerCanChooseCard([TestFactory.cards[0]])));
    });

    test('triggers a PlayCardForAi when next card player is computer player', () {
      final card = TestFactory.cards[0];
      final player = TestFactory.topPlayer..cards = TestFactory.cards.sublist(0, 2);
      final mockGameContext = MockGameContext();

      when(mockGameContext.nextCardPlayer()).thenReturn(player);
      when(mockGameContext.getPossibleCardsToPlay(any)).thenReturn([card]);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: CardPlayed(mockGameContext),
          ));

      verify(mockGameContext.nextCardPlayer());
      verify(mockGameContext.getPossibleCardsToPlay(player));
      verify(Mocks.gameBloc.add(PlayCardForAi(player, [card])));
    });

    test('triggers a EndCardRound when next card player null', () async {
      var mockGameContext = MockGameContext();

      when(mockGameContext.nextCardPlayer()).thenReturn(null);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: CardPlayed(mockGameContext),
          ));

      await Future.delayed(Duration(seconds: 1));

      verify(mockGameContext.nextCardPlayer());
      verify(Mocks.gameBloc.add(EndCardRound()));
    });

    test('triggers a PlayCard when next player has only 1 card', () async {
      final card = TestFactory.cards.first;
      final player = TestFactory.realPlayerWithCards([card]);
      final mockGameContext = MockGameContext();

      when(mockGameContext.nextCardPlayer()).thenReturn(player);

      applicationBlocDelegate.onTransition(
          Mocks.gameBloc,
          Transition(
            currentState: NotStarted(),
            event: NewCardRound(),
            nextState: CardPlayed(mockGameContext),
          ));

      verify(mockGameContext.nextCardPlayer());
      verify(Mocks.gameBloc.add(PlayCard(card, player)));
    });
  });

  group('On error', () {
    test('sends error to errorReporter', () {
      final stackTrace = StackTrace.fromString('some stack');
      final error = 'An error happened!';

      applicationBlocDelegate.onError(Mocks.gameBloc, error, stackTrace);

      verify(Mocks.errorReporter.report(error, stackTrace));
    });
  });
}
