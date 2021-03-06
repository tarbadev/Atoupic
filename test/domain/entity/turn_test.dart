import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/test_factory.dart';

void main() {
  group('Turn', () {
    var firstPlayer;
    var players;

    setUp(() {
      players = TestFactory.gameContext.players;
      firstPlayer = TestFactory.topPlayer;
    });

    group('calculatePoints', () {
      group('when taker is vertical', () {
        test('when last round adds 10 points', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Club
            ..cardRounds = [
              CardRound(TestFactory.topPlayer)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 27, Result.Success, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when requested color is trump', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.topPlayer)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 45, Result.Success, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when points above opponent', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..belote = Position.Top
            ..cardRounds = [
              CardRound(TestFactory.topPlayer) // 35
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // H17
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Jack),
              CardRound(TestFactory.topPlayer) // H17
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Jack),
              CardRound(TestFactory.topPlayer) // H17
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Jack),
              CardRound(TestFactory.topPlayer) // H17
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Jack),
              CardRound(TestFactory.topPlayer) // H17
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Jack),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Nine),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 85, 103, Result.Success, 85, 103);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when all points on taker side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.topPlayer) // 35
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 89, Result.Success, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Fail when all points on opponent side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace),
              CardRound(TestFactory.topPlayer) // H15
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Ace),
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 85, 0, Result.Failure, 252, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when Belote adds 20 points to team', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..belote = Position.Left
            ..cardRounds = [
              CardRound(TestFactory.topPlayer) // 35
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Queen)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Ten)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 20, 89, Result.Success, 20, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        group('declarations', () {
          test('adds points to the team', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Top] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..playerDeclarations[Position.Left] = [
                Declaration(DeclarationType.Tierce, []),
                Declaration(DeclarationType.Quarte, [])
              ]
              ..playerDeclarations[Position.Right] = [
                Declaration(DeclarationType.Quinte, []),
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.King)])
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Queen)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Ten)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 270, 89, Result.Failure, 432, 0);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });

          test('adds declaration points to the other team when losing but keeps belote', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Top] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..belote = Position.Top
              ..playerDeclarations[Position.Top] = [
                Declaration(DeclarationType.Tierce, []),
                Declaration(DeclarationType.Quarte, [])
              ]
              ..playerDeclarations[Position.Right] = [
                Declaration(DeclarationType.Quinte, []),
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.King)])
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Queen)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Ten)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 200, 179, Result.Failure, 432, 20);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });

          test('adds points when Square is Jack or Nines to the team', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Top] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..playerDeclarations[Position.Left] = [
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.Jack)]),
              ]
              ..playerDeclarations[Position.Right] = [
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.Nine)]),
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Queen)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Ten)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 350, 89, Result.Failure, 512, 0);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });
        });
      });

      group('when taker is horizontal', () {
        setUp(() {
          firstPlayer = TestFactory.leftPlayer;
        });

        test('when last round adds 10 points', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Club
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 27, Result.Failure, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when requested color is trump', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 45, 0, Result.Success, 252, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when points above 82', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace),
              CardRound(TestFactory.leftPlayer) // V27
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen),
              CardRound(TestFactory.topPlayer) // H15
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Ace),
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 85, 27, Result.Success, 85, 27);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when all points on taker side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace),
              CardRound(TestFactory.topPlayer) // H15
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Ace),
              CardRound(TestFactory.leftPlayer) // H35
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 85, 0, Result.Success, 252, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Fail when all points on opponent side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CardRound(TestFactory.topPlayer) // 35
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 89, Result.Failure, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when Belote adds points', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..belote = Position.Top
            ..cardRounds = [
              CardRound(TestFactory.topPlayer) // 35
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
              CardRound(TestFactory.topPlayer) // 27
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult = TurnResult(firstPlayer, 0, 109, Result.Failure, 0, 272);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        group('declarations', () {
          test('adds points to the team', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Left] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..playerDeclarations[Position.Left] = [
                Declaration(DeclarationType.Tierce, []),
                Declaration(DeclarationType.Quarte, [])
              ]
              ..playerDeclarations[Position.Right] = [
                Declaration(DeclarationType.Quinte, []),
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.King)])
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 270, 89, Result.Success, 270, 89);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });

          test('adds declaration points to the other team when losing but keeps belote', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Left] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..belote = Position.Left
              ..playerDeclarations[Position.Left] = [
                Declaration(DeclarationType.Tierce, []),
                Declaration(DeclarationType.Quarte, [])
              ]
              ..playerDeclarations[Position.Top] = [
                Declaration(DeclarationType.Quinte, []),
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.King)])
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Ten)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Queen)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 90, 289, Result.Failure, 20, 522);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });

          test('adds points when Square is Jack or Nines to the team', () {
            var turn = Turn(1, firstPlayer)
              ..playerDecisions[Position.Left] = Decision.Take
              ..card = Card(CardColor.Spade, CardHead.Ten)
              ..trumpColor = CardColor.Spade
              ..playerDeclarations[Position.Left] = [
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.Jack)]),
              ]
              ..playerDeclarations[Position.Right] = [
                Declaration(DeclarationType.Square, [Card(CardColor.Diamond, CardHead.Nine)]),
              ]
              ..cardRounds = [
                CardRound(TestFactory.topPlayer) // 35
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                  ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
                  ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.Queen)
                  ..playedCards[Position.Bottom] = Card(CardColor.Heart, CardHead.Ten)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Seven),
                CardRound(TestFactory.topPlayer) // 27
                  ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Ace)
                  ..playedCards[Position.Right] = Card(CardColor.Diamond, CardHead.Eight)
                  ..playedCards[Position.Bottom] = Card(CardColor.Diamond, CardHead.King)
                  ..playedCards[Position.Left] = Card(CardColor.Diamond, CardHead.Jack),
              ];
            var expectedTurnResult = TurnResult(firstPlayer, 350, 89, Result.Success, 350, 89);
            turn.calculatePoints(players);

            expect(turn.turnResult, expectedTurnResult);
          });
        });
      });
    });
  });
}
