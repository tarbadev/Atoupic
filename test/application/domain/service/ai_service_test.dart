import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helper/mock_definition.dart';
import '../../../helper/test_factory.dart';

void main() {
  group('AiService', () {
    Player firstPlayer = TestFactory.realPlayer;
    AiService aiService;

    setUp(() {
      aiService = AiService(Mocks.cardService);

      when(Mocks.cardService.getAllCards()).thenReturn(TestFactory.cards);
    });

    group('chooseCard', () {
      group('when cards have already been played', () {
        group('when has a card that can win the round', () {
          test('returns highest card', () {
            var cards = [
              Card(CardColor.Heart, CardHead.Eight),
              Card(CardColor.Heart, CardHead.Queen),
              Card(CardColor.Heart, CardHead.Ace),
            ];
            var turn = Turn(1, firstPlayer)
              ..cardRounds = [
                CartRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.Seven)
                  ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ten)
              ];

            expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Ace));
          });

          group('when not winning the current round and winner is trump color', () {
            test('returns lowest card', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Ten),
                Card(CardColor.Heart, CardHead.Ace),
              ];
              var turn = Turn(1, firstPlayer)
              ..trumpColor = CardColor.Spade
                ..cardRounds = [
                  CartRound(firstPlayer)
                    ..playedCards[firstPlayer.position] = Card(CardColor.Spade, CardHead.Nine)
                ];

              expect(
                  aiService.chooseCard(cards, turn, false), Card(CardColor.Heart, CardHead.Eight));
            });
          });
        });

        group('when does not have a card that can win the round', () {
          group('when not winning the current round', () {
            test('returns lowest card', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Ten),
                Card(CardColor.Heart, CardHead.King),
              ];
              var turn = Turn(1, firstPlayer)
                ..cardRounds = [
                  CartRound(firstPlayer)
                    ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.Seven)
                    ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Queen)
                ];

              expect(
                  aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Eight));
            });
          });

          group('when winning the current round', () {
            test('returns highest card', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Queen),
                Card(CardColor.Heart, CardHead.King),
              ];
              var turn = Turn(1, firstPlayer)
                ..trumpColor = CardColor.Spade
                ..cardRounds = [
                  CartRound(firstPlayer)
                    ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.Ace)
                    ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ten)
                ];

              expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.King));
            });

            group('when partner cut the round', () {
              test('returns highest card', () {
                var cards = [
                  Card(CardColor.Heart, CardHead.Jack),
                  Card(CardColor.Heart, CardHead.Queen),
                  Card(CardColor.Heart, CardHead.King),
                ];
                var turn = Turn(1, firstPlayer)
                  ..trumpColor = CardColor.Spade
                  ..cardRounds = [
                    CartRound(Player(Position.Left))
                      ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ace)
                      ..playedCards[firstPlayer.position] = Card(CardColor.Spade, CardHead.Seven)
                  ];

                expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.King));
              });
            });
          });
        });
      });
      group('when first card to play', () {
        group('when has a card that can win the round', () {
          test('returns highest card', () {
            var cards = [
              Card(CardColor.Heart, CardHead.Eight),
              Card(CardColor.Heart, CardHead.Queen),
              Card(CardColor.Heart, CardHead.Ace),
            ];
            var turn = Turn(1, firstPlayer)..cardRounds = [CartRound(firstPlayer)];

            expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Ace));
          });
        });

        group('when does not have a card that can win the round', () {
          test('returns lowest card', () {
            var cards = [
              Card(CardColor.Heart, CardHead.Eight),
              Card(CardColor.Heart, CardHead.Queen),
              Card(CardColor.Heart, CardHead.Ten),
              Card(CardColor.Spade, CardHead.Seven),
              Card(CardColor.Spade, CardHead.Queen),
              Card(CardColor.Club, CardHead.Seven),
              Card(CardColor.Club, CardHead.King),
            ];
            var turn = Turn(1, firstPlayer)..cardRounds = [CartRound(firstPlayer)];

            expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Spade, CardHead.Seven));
          });
        });
      });
    });
  });
}
