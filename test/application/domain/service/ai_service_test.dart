import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helper/test_factory.dart';

void main() {
  group('AiService', () {
    Player firstPlayer = TestFactory.realPlayer;

    group('chooseCard', () {
      group('when cards have already been played', () {
        group('when not winning the current round', () {
          test('returns lowest card', () {
            var cards = [
              Card(CardColor.Heart, CardHead.Eight),
              Card(CardColor.Heart, CardHead.Queen),
              Card(CardColor.Heart, CardHead.King),
            ];
            var turn = Turn(1, firstPlayer)
              ..cardRounds = [CartRound(firstPlayer)
                ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.Seven)
                ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ten)
              ];

            expect(
                AiService().chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Eight));
          });
        });
      });
    });
  });
}
