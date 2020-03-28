import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/player.dart';
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
      firstPlayer = TestFactory.computerPlayer;
    });

    group('calculatePoints', () {
      group('when taker is vertical', () {
        test('when last round adds 10 points', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Club
            ..cardRounds = [
              CartRound(Player(Position.Top))
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] =
                    Card(CardColor.Spade, CardHead.Seven),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 0, 27, Result.Failure, 162, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when requested color is trump', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Top))
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] =
                    Card(CardColor.Spade, CardHead.Seven),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 0, 45, Result.Failure, 162, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when points above 82', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Top)) // 35
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] =
                    Card(CardColor.Spade, CardHead.Seven),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] =
                    Card(CardColor.Diamond, CardHead.Seven),
              CartRound(Player(Position.Top)) // 17
                ..playedCards[Position.Top] =
                Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] =
                Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] =
                Card(CardColor.Heart, CardHead.Jack),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                    Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] =
                    Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] =
                    Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 17, 89, Result.Success, 17, 89);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when all points on taker side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Top)) // 35
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Seven),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Seven),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] =
                Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult =
          TurnResult(firstPlayer, 0, 89, Result.Success, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Fail when all points on opponent side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Top] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Spade, CardHead.Ace),
              CartRound(Player(Position.Top)) // H15
                ..playedCards[Position.Top] =
                Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] =
                Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Ace),
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] =
                Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] =
                Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult =
          TurnResult(firstPlayer, 85, 0, Result.Failure, 252, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });
      });

      group('when taker is horizontal', () {
        setUp(() {
          firstPlayer = Player(Position.Left);
        });

        test('when last round adds 10 points', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Club
            ..cardRounds = [
              CartRound(Player(Position.Left))
                ..playedCards[Position.Left] =
                    Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 0, 27, Result.Failure, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('when requested color is trump', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Left))
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 45, 0, Result.Failure, 0, 162);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when points above 82', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Spade, CardHead.Ace),
              CartRound(Player(Position.Left)) // V27
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Top] =
                    Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] =
                    Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Heart, CardHead.Queen),
              CartRound(Player(Position.Top)) // H15
                ..playedCards[Position.Top] =
                    Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] =
                    Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] =
                    Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] =
                    Card(CardColor.Diamond, CardHead.Ace),
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] =
                Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] =
                Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult =
              TurnResult(firstPlayer, 85, 27, Result.Success, 85, 27);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Success when all points on taker side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Seven)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Spade, CardHead.Ace),
              CartRound(Player(Position.Top)) // H15
                ..playedCards[Position.Top] =
                Card(CardColor.Diamond, CardHead.Nine)
                ..playedCards[Position.Right] =
                Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.Seven)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Ace),
              CartRound(Player(Position.Left)) // H35
                ..playedCards[Position.Left] =
                Card(CardColor.Heart, CardHead.Nine)
                ..playedCards[Position.Top] =
                Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Right] =
                Card(CardColor.Heart, CardHead.Ace)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.Ten),
            ];
          var expectedTurnResult =
          TurnResult(firstPlayer, 85, 0, Result.Success, 252, 0);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });

        test('Fail when all points on opponent side', () {
          var turn = Turn(1, firstPlayer)
            ..playerDecisions[Position.Left] = Decision.Take
            ..card = Card(CardColor.Spade, CardHead.Ten)
            ..trumpColor = CardColor.Spade
            ..cardRounds = [
              CartRound(Player(Position.Top)) // 35
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Jack)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Spade, CardHead.Ace)
                ..playedCards[Position.Left] =
                Card(CardColor.Spade, CardHead.Seven),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                Card(CardColor.Spade, CardHead.Nine)
                ..playedCards[Position.Right] =
                Card(CardColor.Spade, CardHead.Ten)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Heart, CardHead.Queen)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Seven),
              CartRound(Player(Position.Top)) // 27
                ..playedCards[Position.Top] =
                Card(CardColor.Diamond, CardHead.Ace)
                ..playedCards[Position.Right] =
                Card(CardColor.Diamond, CardHead.Eight)
                ..playedCards[Position.Bottom] =
                Card(CardColor.Diamond, CardHead.King)
                ..playedCards[Position.Left] =
                Card(CardColor.Diamond, CardHead.Jack),
            ];
          var expectedTurnResult =
          TurnResult(firstPlayer, 0, 89, Result.Failure, 0, 252);
          turn.calculatePoints(players);

          expect(turn.turnResult, expectedTurnResult);
        });
      });
    });
  });
}
