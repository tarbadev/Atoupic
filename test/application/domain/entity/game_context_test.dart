import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helper/test_factory.dart';

void main() {
  group('GameContext', () {
    group('setDecision', () {
      test('stores the players decision', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(Position.Left),
          firstPlayer,
          Player(Position.Right),
          TestFactory.realPlayer
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        var newGameContext = gameContext.setDecision(firstPlayer, Decision.Pass);
        expect(newGameContext.turns[0].playerDecisions[firstPlayer.position], Decision.Pass);
      });
    });

    group('nextPlayer', () {
      test('when no decision yet returns the first player', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(Position.Left),
          Player(Position.Right),
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        expect(gameContext.nextPlayer(), firstPlayer);
      });

      test('when next player is after the first player', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          Player(Position.Left),
          Player(Position.Right),
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(
            players, [Turn(1, firstPlayer)
          ..playerDecisions[firstPlayer.position] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when next player is first players list', () {
        var firstPlayer = TestFactory.computerPlayer;
        List<Player> players = [
          TestFactory.realPlayer,
          Player(Position.Left),
          Player(Position.Right),
          firstPlayer,
        ];
        var gameContext = GameContext(
            players, [Turn(1, firstPlayer)
          ..playerDecisions[firstPlayer.position] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when other players already passed', () {
        var firstPlayer = TestFactory.computerPlayer;
        var secondPlayer = Player(Position.Left);
        var thirdPlayer = Player(Position.Right);
        List<Player> players = [
          thirdPlayer,
          TestFactory.realPlayer,
          firstPlayer,
          secondPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..playerDecisions[firstPlayer.position] = Decision.Pass
            ..playerDecisions[secondPlayer.position] = Decision.Pass
            ..playerDecisions[thirdPlayer.position] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when all passed return null', () {
        var firstPlayer = TestFactory.computerPlayer;
        var secondPlayer = Player(Position.Left);
        var thirdPlayer = Player(Position.Right);
        List<Player> players = [
          thirdPlayer,
          TestFactory.realPlayer,
          firstPlayer,
          secondPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..playerDecisions[firstPlayer.position] = Decision.Pass
            ..playerDecisions[secondPlayer.position] = Decision.Pass
            ..playerDecisions[thirdPlayer.position] = Decision.Pass
            ..playerDecisions[TestFactory.realPlayer.position] = Decision.Pass
        ]);
        expect(gameContext.nextPlayer(), isNull);
      });
    });

    group('nextRound', () {
      test('when round is 1 changes the round to 2', () {
        var turn = Turn(1, TestFactory.computerPlayer)
          ..playerDecisions[TestFactory.realPlayer.position] = Decision.Pass;
        var gameContext = GameContext([], [turn]);
        var newGameContext = gameContext.nextRound();
        expect(newGameContext.turns[0].round, 2);
        expect(newGameContext.turns[0].playerDecisions, isEmpty);
      });
    });

    group('nextTurn', () {
      test('returns new gameContext with new turn and first player', () {
        var turn = Turn(1, TestFactory.computerPlayer);
        var gameContext = GameContext([TestFactory.computerPlayer, TestFactory.realPlayer], [turn]);
        var newGameContext = gameContext.nextTurn();
        expect(newGameContext.turns[1], Turn(2, TestFactory.realPlayer));
      });

      test('when first player is last in players list', () {
        var turn = Turn(1, TestFactory.computerPlayer);
        var gameContext = GameContext([TestFactory.realPlayer, TestFactory.computerPlayer], [turn]);
        var newGameContext = gameContext.nextTurn();
        expect(newGameContext.turns[1], Turn(2, TestFactory.realPlayer));
      });
    });

    group('setCardDecision', () {
      test('stores the players decision and removes card from deck', () {
        Card card = TestFactory.cards[0];
        var otherCard = TestFactory.cards[2];
        var player = TestFactory.realPlayer..cards = [card, otherCard];
        var gameContext = GameContext([
          player
        ], [
          Turn(1, TestFactory.realPlayer)
            ..cardRounds = [CartRound(TestFactory.realPlayer)]
        ]);
        var newGameContext = gameContext.setCardDecision(card, TestFactory.realPlayer);
        expect(
          newGameContext.turns[0].cardRounds[0].playedCards[TestFactory.realPlayer.position],
          card,
        );
        expect(
          newGameContext.players[0].cards,
          [otherCard],
        );
      });
    });

    group('newCardRound', () {
      test('when it is the first card round adds a new CardRound with the next player', () {
        var gameContext = GameContext([TestFactory.realPlayer], [Turn(1, TestFactory.realPlayer)]);
        var newGameContext = gameContext.newCardRound();
        expect(newGameContext.turns[0].cardRounds.length, 1);
        expect(
          newGameContext.turns[0].cardRounds[0],
          CartRound(TestFactory.realPlayer),
        );
      });

      group('when it is not the first card round', () {
        test('adds a new CardRound with the highest card player', () {
          var gameContext = TestFactory.gameContext
            ..lastTurn.cardRounds = [
              CartRound(Player(Position.Top))
                ..playedCards[TestFactory.realPlayer.position] =
                Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Nine),
            ];
          var newGameContext = gameContext.newCardRound();
          expect(
            newGameContext.turns[0].cardRounds[1],
            CartRound(Player(Position.Right)),
          );
        });

        test('and only card of the requested color adds a new CardRound with the first player', () {
          var gameContext = TestFactory.gameContext
            ..lastTurn.cardRounds = [
              CartRound(Player(Position.Top))
                ..playedCards[TestFactory.realPlayer.position] =
                Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Nine),
            ];
          var newGameContext = gameContext.newCardRound();
          expect(
            newGameContext.turns[0].cardRounds[1],
            CartRound(Player(Position.Top)),
          );
        });

        test('and requested color is trump color adds a new CardRound with the highest card player',
                () {
              var gameContext = TestFactory.gameContext
                ..lastTurn.trumpColor = CardColor.Club
                ..lastTurn.cardRounds = [
                  CartRound(Player(Position.Top))
                    ..playedCards[TestFactory.realPlayer.position] =
                    Card(CardColor.Heart, CardHead.Eight)
                    ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.King)
                    ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                    ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Nine),
                ];
              var newGameContext = gameContext.newCardRound();
              expect(
                newGameContext.turns[0].cardRounds[1],
                CartRound(Player(Position.Left)),
              );
            });
      });
    });

    group('nextCardPlayer', () {
      test('returns firstPlayer when no card played', () {
        var firstPlayer = TestFactory.computerPlayer;
        var gameContext = GameContext([
          TestFactory.realPlayer,
          firstPlayer
        ], [
          Turn(1, firstPlayer)
            ..cardRounds = [CartRound(firstPlayer), CartRound(TestFactory.realPlayer)]
        ]);
        var nextPlayer = gameContext.nextCardPlayer();
        expect(
          nextPlayer,
          TestFactory.realPlayer,
        );
      });

      test('returns next player when firstplayer already played', () {
        var firstPlayer = TestFactory.computerPlayer;
        var player = Player(Position.Right);
        List<Player> players = [
          Player(Position.Left),
          firstPlayer,
          player,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..cardRounds = [CartRound(firstPlayer)]
            ..lastCardRound.playedCards[firstPlayer.position] = TestFactory.cards[0]
        ]);
        var nextPlayer = gameContext.nextCardPlayer();
        expect(
          nextPlayer,
          player,
        );
      });

      test('returns next player when firstplayer already played and firstPlayer is last in list',
              () {
            var firstPlayer = TestFactory.computerPlayer;
            var player = Player(Position.Right);
            List<Player> players = [
              player,
              Player(Position.Left),
              TestFactory.realPlayer,
              firstPlayer,
            ];
            var gameContext = GameContext(players, [
              Turn(1, firstPlayer)
                ..cardRounds = [CartRound(firstPlayer)]
                ..lastCardRound.playedCards[firstPlayer.position] = TestFactory.cards[0]
            ]);
            var nextPlayer = gameContext.nextCardPlayer();
            expect(
              nextPlayer,
              player,
            );
          });

      test('returns null when all cards played', () {
        var firstPlayer = TestFactory.computerPlayer;
        var player = Player(Position.Right);
        List<Player> players = [
          player,
          Player(Position.Left),
          TestFactory.realPlayer,
          firstPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..cardRounds = [CartRound(firstPlayer)]
            ..lastCardRound.playedCards[Position.Bottom] = TestFactory.cards[0]
            ..lastCardRound.playedCards[Position.Right] = TestFactory.cards[1]
            ..lastCardRound.playedCards[Position.Left] = TestFactory.cards[2]
            ..lastCardRound.playedCards[Position.Top] = TestFactory.cards[3]
        ]);
        expect(gameContext.nextCardPlayer(), isNull);
      });
    });

    group('getPossibleCardsToPlay', () {
      group('when not the first player', () {
        GameContext gameContext;
        var firstPlayer = TestFactory.realPlayer;

        setUp(() {
          gameContext = GameContext([], [
            Turn(1, firstPlayer)
              ..trumpColor = CardColor.Spade
              ..cardRounds = [
                CartRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.King)
              ]
          ]);
        });

        group('when has card of requested color', () {
          test('returns cards of requested color', () {
            var card1 = Card(CardColor.Heart, CardHead.Eight);
            var card2 = Card(CardColor.Heart, CardHead.Seven);
            var player = TestFactory.computerPlayer
              ..cards = [
                Card(CardColor.Club, CardHead.Eight),
                Card(CardColor.Spade, CardHead.Eight),
                Card(CardColor.Diamond, CardHead.Eight),
                card1,
                card2,
              ];

            expect(gameContext.getPossibleCardsToPlay(player), [card1, card2]);
          });
          test('and requested color is trump returns cards of higher card', () {
            gameContext.lastTurn
              ..trumpColor = CardColor.Spade
              ..cardRounds = [
                CartRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Spade, CardHead.King)
              ];
            var card1 = Card(CardColor.Spade, CardHead.Ace);
            var card2 = Card(CardColor.Spade, CardHead.Jack);
            var player = TestFactory.computerPlayer
              ..cards = [
                Card(CardColor.Club, CardHead.Eight),
                Card(CardColor.Spade, CardHead.Eight),
                Card(CardColor.Diamond, CardHead.Eight),
                card1,
                card2,
              ];

            expect(gameContext.getPossibleCardsToPlay(player), [card1, card2]);
          });
        });

        group('when does not have card of requested color', () {
          test('returns all cards', () {
            var player = TestFactory.computerPlayer
              ..cards = [
                Card(CardColor.Club, CardHead.Eight),
                Card(CardColor.Diamond, CardHead.Eight),
              ];

            expect(gameContext.getPossibleCardsToPlay(player), player.cards);
          });

          group('and has trump color', () {
            test('returns all trump cards', () {
              gameContext.lastTurn.lastCardRound.playedCards[Position.Left] = Card(CardColor.Heart,
                  CardHead.Ace);
              var player = TestFactory.computerPlayer
                ..cards = [
                  Card(CardColor.Club, CardHead.Eight),
                  Card(CardColor.Spade, CardHead.Eight),
                  Card(CardColor.Diamond, CardHead.Eight),
                ];

              expect(gameContext.getPossibleCardsToPlay(player),
                  [Card(CardColor.Spade, CardHead.Eight)]);
            });

            group('and partner is winning round', () {
              test('returns all cards', () {
                gameContext.lastTurn.lastCardRound
                  ..playedCards[Position.Bottom] = Card(CardColor.Club, CardHead.Ace);
                var cards = [
                  Card(CardColor.Spade, CardHead.Eight),
                  Card(CardColor.Diamond, CardHead.Eight),
                ];
                var player = TestFactory.computerPlayer..cards = cards;

                expect(gameContext.getPossibleCardsToPlay(player), cards);
              });
            });

            group('and trump cards have already been played', () {
              test('and player does not have higher card returns all trump cards', () {
                gameContext.lastTurn.lastCardRound
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Nine);
                var player = TestFactory.computerPlayer
                  ..cards = [
                    Card(CardColor.Club, CardHead.Eight),
                    Card(CardColor.Spade, CardHead.Eight),
                    Card(CardColor.Diamond, CardHead.Eight),
                  ];

                expect(gameContext.getPossibleCardsToPlay(player),
                    [Card(CardColor.Spade, CardHead.Eight)]);
              });

              test('and player has higher card returns all higher trump cards', () {
                gameContext.lastTurn.lastCardRound
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Nine);
                var player = TestFactory.computerPlayer
                  ..cards = [
                    Card(CardColor.Club, CardHead.Eight),
                    Card(CardColor.Spade, CardHead.Eight),
                    Card(CardColor.Spade, CardHead.Jack),
                  ];

                expect(gameContext.getPossibleCardsToPlay(player),
                    [Card(CardColor.Spade, CardHead.Jack)]);
              });
            });
          });
        });
      });

      group('when first player', () {
        var gameContext;
        var player = TestFactory.realPlayer;

        setUp(() {
          gameContext = GameContext([], [
            Turn(1, player)
              ..cardRounds = [CartRound(player)]
          ]);
        });

        test('dispatches a SetCardDecisionAction with a random card', () {
          var card = Card(CardColor.Club, CardHead.Eight);
          player.cards = [card];

          expect(gameContext.getPossibleCardsToPlay(player), player.cards);
        });
      });
    });
  });
}
