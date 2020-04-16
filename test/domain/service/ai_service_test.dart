import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';

void main() {
  group('AiService', () {
    Player firstPlayer = TestFactory.realPlayer;
    AiService aiService;
    var turn = Turn(1, firstPlayer)
      ..card = Card(CardColor.Spade, CardHead.Ace)
      ..trumpColor = CardColor.Spade
      ..playerDecisions[Position.Left] = Decision.Take;

    setUp(() {
      aiService = AiService(Mocks.cardService);

      when(Mocks.cardService.getAllCards()).thenReturn(TestFactory.cards);
    });

    group('chooseCard', () {
      group('when cards have already been played', () {
        group('when has a card that can win the round', () {
          group('when has a card that can win the round', () {
            test('when winning card is of requested color', () {
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

            test('when no card of requested color available', () {
              var cards = [
                Card(CardColor.Diamond, CardHead.Eight),
                Card(CardColor.Diamond, CardHead.Queen),
                Card(CardColor.Diamond, CardHead.Ace),
              ];
              turn.cardRounds = [
                CartRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.Seven)
                  ..playedCards[Position.Left] = Card(CardColor.Heart, CardHead.Ten)
              ];

              expect(
                  aiService.chooseCard(cards, turn, true), Card(CardColor.Diamond, CardHead.Eight));
            });
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
                  CartRound(TestFactory.leftPlayer)
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

            test('when only one card', () {
              var cards = [
                Card(CardColor.Spade, CardHead.Eight),
              ];

              expect(
                  aiService.chooseCard(cards, turn, true), Card(CardColor.Spade, CardHead.Eight));
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

              expect(aiService.chooseCard(cards, turn, true), Card(CardColor.Club, CardHead.Seven));
            });

            test('when in taker team', () {
              var cards = [
                Card(CardColor.Heart, CardHead.Eight),
                Card(CardColor.Heart, CardHead.Seven),
              ];

              expect(
                  aiService.chooseCard(cards, turn, false), Card(CardColor.Heart, CardHead.Eight));
            });
          });
        });
      });
    });

    group('takeOrPass', () {
      group('when turn.round == 1', () {
        test('returns card color when computer has enough points to take', () {
          var cards = [
            Card(CardColor.Spade, CardHead.Jack),
            Card(CardColor.Spade, CardHead.Nine),
            Card(CardColor.Spade, CardHead.King),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Spade);
        });

        test('returns card color when computer has only trump cards', () {
          var cards = [
            Card(CardColor.Spade, CardHead.Jack),
            Card(CardColor.Spade, CardHead.Nine),
            Card(CardColor.Spade, CardHead.King),
            Card(CardColor.Spade, CardHead.Queen),
            Card(CardColor.Spade, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Spade);
        });

        test('returns card color when added card makes it feasible', () {
          var cards = [
            Card(CardColor.Spade, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Eight),
            Card(CardColor.Spade, CardHead.King),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Spade);
        });

        test('returns null when too difficult', () {
          var cards = [
            Card(CardColor.Club, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Eight),
            Card(CardColor.Spade, CardHead.King),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), isNull);
        });
      });

      group('when turn.round == 2', () {
        var turn = Turn(1, firstPlayer)
          ..card = Card(CardColor.Spade, CardHead.Ace)
          ..round = 2;
        test('returns false when too difficult', () {
          var cards = [
            Card(CardColor.Club, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Eight),
            Card(CardColor.Spade, CardHead.King),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), isNull);
        });

        test('returns chosen color when computer has enough points to take', () {
          var cards = [
            Card(CardColor.Diamond, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Nine),
            Card(CardColor.Diamond, CardHead.King),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Diamond);
        });

        test('returns chosen color when computer has only trump cards', () {
          var cards = [
            Card(CardColor.Diamond, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Nine),
            Card(CardColor.Diamond, CardHead.King),
            Card(CardColor.Diamond, CardHead.Queen),
            Card(CardColor.Diamond, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Diamond);
        });

        test('returns card color when added card makes it feasible', () {
          var cards = [
            Card(CardColor.Spade, CardHead.Jack),
            Card(CardColor.Diamond, CardHead.Eight),
            Card(CardColor.Heart, CardHead.Jack),
            Card(CardColor.Heart, CardHead.Ace),
            Card(CardColor.Heart, CardHead.Seven),
          ];
          expect(aiService.takeOrPass(cards, turn), CardColor.Heart);
        });
      });
    });
  });
}
