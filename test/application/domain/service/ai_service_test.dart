import 'package:atoupic/application/domain/entity/turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/ai_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helper/mock_definition.dart';
import '../../../helper/test_factory.dart';

void main() {
  group('AiService', () {
    Player firstPlayer = TestFactory.realPlayer;
    AiService aiService;
    var turn = Turn(1, firstPlayer)
      ..trumpColor = CardColor.Spade
      ..playerDecisions[Position.Left] = Decision.Take;

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
            turn.cardRounds = [
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
              turn.cardRounds = [
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
              turn.cardRounds = [
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
              turn.cardRounds = [
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
                turn.cardRounds = [
                  CartRound(Player(Position.Left))
                    ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ace)
                    ..playedCards[firstPlayer.position] = Card(CardColor.Spade, CardHead.Seven)
                ];

                expect(
                    aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.King));
              });
            });
          });
        });
      });

      group('when first card to play', () {
        setUp(() {
          turn.cardRounds = [CartRound(firstPlayer)];
        });

        group('when has a card that can win the round', () {
          group('when does not have trump cards', () {
            test('returns winning card', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Queen),
                Card(CardColor.Heart, CardHead.Ace),
              ];

              expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Ace));
            });
          });

          group('when has trump cards', () {
            group('when is not in the team taker', () {
              test('returns winning non trump card', () {
                var cards = [
                  Card(CardColor.Spade, CardHead.Jack),
                  Card(CardColor.Heart, CardHead.Eight),
                  Card(CardColor.Heart, CardHead.Queen),
                  Card(CardColor.Heart, CardHead.Ace),
                ];

                expect(
                    aiService.chooseCard(cards, turn, true), Card(CardColor.Heart, CardHead.Ace));
              });
            });

            group('when is in the team taker', () {
              test('returns winning trump card', () {
                var cards = [
                  Card(CardColor.Heart, CardHead.Eight),
                  Card(CardColor.Heart, CardHead.Queen),
                  Card(CardColor.Heart, CardHead.Ace),
                  Card(CardColor.Spade, CardHead.Jack),
                ];

                expect(
                    aiService.chooseCard(cards, turn, false), Card(CardColor.Spade, CardHead.Jack));
              });
            });
          });
        });

        group('when does not have a card that can win the round', () {
          group('when has trump cards', () {
            group('when not in taker team', () {
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

                expect(
                    aiService.chooseCard(cards, turn, true), Card(CardColor.Spade, CardHead.Seven));
              });
            });

            group('when in taker team', () {
              test('returns highest trump card', () {
                var cards = [
                  Card(CardColor.Heart, CardHead.Eight),
                  Card(CardColor.Heart, CardHead.Queen),
                  Card(CardColor.Heart, CardHead.Ten),
                  Card(CardColor.Spade, CardHead.Seven),
                  Card(CardColor.Spade, CardHead.Queen),
                  Card(CardColor.Club, CardHead.Seven),
                  Card(CardColor.Club, CardHead.King),
                ];

                expect(aiService.chooseCard(cards, turn, false),
                    Card(CardColor.Spade, CardHead.Queen));
              });
            });
          });

          group('when does not have trump cards', () {
            test('returns lowest card', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Queen),
                Card(CardColor.Heart, CardHead.Ten),
                Card(CardColor.Club, CardHead.Seven),
                Card(CardColor.Club, CardHead.King),
              ];

              expect(
                  aiService.chooseCard(cards, turn, true), Card(CardColor.Club, CardHead.Seven));
            });
          });
        });
      });
    });
  });
}
