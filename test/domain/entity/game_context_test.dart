import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/test_factory.dart';

void main() {
  group('GameContext', () {
    group('setDecision', () {
      test('stores the players decision', () {
        var firstPlayer = TestFactory.topPlayer;
        List<Player> players = [
          TestFactory.leftPlayer,
          firstPlayer,
          TestFactory.rightPlayer,
          TestFactory.realPlayer
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        var newGameContext = gameContext.setDecision(firstPlayer, Decision.Pass);
        expect(newGameContext.turns[0].playerDecisions[firstPlayer.position], Decision.Pass);
      });
    });

    group('nextPlayer', () {
      test('when no decision yet returns the first player', () {
        var firstPlayer = TestFactory.topPlayer;
        List<Player> players = [
          TestFactory.leftPlayer,
          TestFactory.rightPlayer,
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
        expect(gameContext.nextPlayer(), firstPlayer);
      });

      test('when next player is after the first player', () {
        var firstPlayer = TestFactory.topPlayer;
        List<Player> players = [
          TestFactory.leftPlayer,
          TestFactory.rightPlayer,
          firstPlayer,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(
            players, [Turn(1, firstPlayer)..playerDecisions[firstPlayer.position] = Decision.Pass]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when next player is first players list', () {
        var firstPlayer = TestFactory.topPlayer;
        List<Player> players = [
          TestFactory.realPlayer,
          TestFactory.leftPlayer,
          TestFactory.rightPlayer,
          firstPlayer,
        ];
        var gameContext = GameContext(
            players, [Turn(1, firstPlayer)..playerDecisions[firstPlayer.position] = Decision.Pass]);
        expect(gameContext.nextPlayer(), TestFactory.realPlayer);
      });

      test('when other players already passed', () {
        var firstPlayer = TestFactory.topPlayer;
        var secondPlayer = TestFactory.leftPlayer;
        var thirdPlayer = TestFactory.rightPlayer;
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
        var firstPlayer = TestFactory.topPlayer;
        var secondPlayer = TestFactory.leftPlayer;
        var thirdPlayer = TestFactory.rightPlayer;
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
        var turn = Turn(1, TestFactory.topPlayer)
          ..playerDecisions[TestFactory.realPlayer.position] = Decision.Pass;
        var gameContext = GameContext([], [turn]);
        var newGameContext = gameContext.nextRound();
        expect(newGameContext.turns[0].round, 2);
        expect(newGameContext.turns[0].playerDecisions, isEmpty);
      });
    });

    group('nextTurn', () {
      test('returns new gameContext with new turn and first player', () {
        var turn = Turn(1, TestFactory.topPlayer);
        var gameContext = GameContext([TestFactory.topPlayer, TestFactory.realPlayer], [turn]);
        var newGameContext = gameContext.nextTurn();
        expect(newGameContext.turns[1], Turn(2, TestFactory.realPlayer));
      });

      test('when first player is last in players list', () {
        var turn = Turn(1, TestFactory.topPlayer);
        var gameContext = GameContext([TestFactory.realPlayer, TestFactory.topPlayer], [turn]);
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
          Turn(1, TestFactory.realPlayer)..cardRounds = [CardRound(TestFactory.realPlayer)]
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

      test('stores players position in turn when it is a Belote card', () {
        Card card = Card(CardColor.Diamond, CardHead.King);
        var otherCard = Card(CardColor.Diamond, CardHead.Queen);
        var player = TestFactory.realPlayer..cards = [card, otherCard];
        var gameContext = GameContext([
          player
        ], [
          Turn(1, TestFactory.realPlayer)
            ..trumpColor = CardColor.Diamond
            ..cardRounds = [CardRound(TestFactory.realPlayer)]
        ]);
        var newGameContext = gameContext.setCardDecision(card, player);
        expect(newGameContext.turns[0].belote, TestFactory.realPlayer.position);
      });
    });

    group('newCardRound', () {
      test('when it is the first card round adds a new CardRound with the next player', () {
        var gameContext = GameContext([TestFactory.realPlayer], [Turn(1, TestFactory.realPlayer)]);
        var newGameContext = gameContext.newCardRound();
        expect(newGameContext.turns[0].cardRounds.length, 1);
        expect(
          newGameContext.turns[0].cardRounds[0],
          CardRound(TestFactory.realPlayer),
        );
      });

      group('when it is not the first card round', () {
        test('adds a new CardRound with the highest card player', () {
          var gameContext = TestFactory.gameContext
            ..lastTurn.cardRounds = [
              CardRound(TestFactory.topPlayer)
                ..playedCards[TestFactory.realPlayer.position] =
                    Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Nine),
            ];
          var newGameContext = gameContext.newCardRound();
          expect(
            newGameContext.turns[0].cardRounds[1],
            CardRound(TestFactory.rightPlayer),
          );
        });

        test('and only card of the requested color adds a new CardRound with the first player', () {
          var gameContext = TestFactory.gameContext
            ..lastTurn.cardRounds = [
              CardRound(TestFactory.topPlayer)
                ..playedCards[TestFactory.realPlayer.position] =
                    Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                ..playedCards[Position.Top] = Card(CardColor.Diamond, CardHead.Nine),
            ];
          var newGameContext = gameContext.newCardRound();
          expect(
            newGameContext.turns[0].cardRounds[1],
            CardRound(TestFactory.topPlayer),
          );
        });

        test('and requested color is trump color adds a new CardRound with the highest card player',
            () {
          var gameContext = TestFactory.gameContext
            ..lastTurn.trumpColor = CardColor.Club
            ..lastTurn.cardRounds = [
              CardRound(TestFactory.topPlayer)
                ..playedCards[TestFactory.realPlayer.position] =
                    Card(CardColor.Heart, CardHead.Eight)
                ..playedCards[Position.Right] = Card(CardColor.Heart, CardHead.King)
                ..playedCards[Position.Left] = Card(CardColor.Club, CardHead.Ace)
                ..playedCards[Position.Top] = Card(CardColor.Heart, CardHead.Nine),
            ];
          var newGameContext = gameContext.newCardRound();
          expect(
            newGameContext.turns[0].cardRounds[1],
            CardRound(TestFactory.leftPlayer),
          );
        });
      });
    });

    group('nextCardPlayer', () {
      test('returns firstPlayer when no card played', () {
        var firstPlayer = TestFactory.topPlayer;
        var gameContext = GameContext([
          TestFactory.realPlayer,
          firstPlayer
        ], [
          Turn(1, firstPlayer)
            ..cardRounds = [CardRound(firstPlayer), CardRound(TestFactory.realPlayer)]
        ]);
        var nextPlayer = gameContext.nextCardPlayer();
        expect(
          nextPlayer,
          TestFactory.realPlayer,
        );
      });

      test('returns next player when firstplayer already played', () {
        var firstPlayer = TestFactory.topPlayer;
        var player = TestFactory.rightPlayer;
        List<Player> players = [
          TestFactory.leftPlayer,
          firstPlayer,
          player,
          TestFactory.realPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..cardRounds = [CardRound(firstPlayer)]
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
        var firstPlayer = TestFactory.topPlayer;
        var player = TestFactory.rightPlayer;
        List<Player> players = [
          player,
          TestFactory.leftPlayer,
          TestFactory.realPlayer,
          firstPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..cardRounds = [CardRound(firstPlayer)]
            ..lastCardRound.playedCards[firstPlayer.position] = TestFactory.cards[0]
        ]);
        var nextPlayer = gameContext.nextCardPlayer();
        expect(
          nextPlayer,
          player,
        );
      });

      test('returns null when all cards played', () {
        var firstPlayer = TestFactory.topPlayer;
        var player = TestFactory.rightPlayer;
        List<Player> players = [
          player,
          TestFactory.leftPlayer,
          TestFactory.realPlayer,
          firstPlayer,
        ];
        var gameContext = GameContext(players, [
          Turn(1, firstPlayer)
            ..cardRounds = [CardRound(firstPlayer)]
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
                CardRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Heart, CardHead.King)
              ]
          ]);
        });

        group('when has card of requested color', () {
          test('returns cards of requested color', () {
            var card1 = Card(CardColor.Heart, CardHead.Eight);
            var card2 = Card(CardColor.Heart, CardHead.Seven);
            var player = TestFactory.topPlayer
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
                CardRound(firstPlayer)
                  ..playedCards[firstPlayer.position] = Card(CardColor.Spade, CardHead.King)
              ];
            var card1 = Card(CardColor.Spade, CardHead.Ace);
            var card2 = Card(CardColor.Spade, CardHead.Jack);
            var player = TestFactory.topPlayer
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
            var player = TestFactory.topPlayer
              ..cards = [
                Card(CardColor.Club, CardHead.Eight),
                Card(CardColor.Diamond, CardHead.Eight),
              ];

            expect(gameContext.getPossibleCardsToPlay(player), player.cards);
          });

          group('and has trump color', () {
            test('returns all trump cards', () {
              gameContext.lastTurn.lastCardRound.playedCards[Position.Left] =
                  Card(CardColor.Heart, CardHead.Ace);
              var player = TestFactory.topPlayer
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
                var player = TestFactory.topPlayer..cards = cards;

                expect(gameContext.getPossibleCardsToPlay(player), cards);
              });
            });

            group('and trump cards have already been played', () {
              test('and player does not have higher card returns all trump cards', () {
                gameContext.lastTurn.lastCardRound
                  ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Nine);
                var player = TestFactory.topPlayer
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
                var player = TestFactory.topPlayer
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
            Turn(1, player)..cardRounds = [CardRound(player)]
          ]);
        });

        test('dispatches a SetCardDecisionAction with a random card', () {
          var card = Card(CardColor.Club, CardHead.Eight);
          player.cards = [card];

          expect(gameContext.getPossibleCardsToPlay(player), player.cards);
        });
      });
    });

    group('isPlayedCardBelote', () {
      test('when card is not a belote card', () {
        var gameContext =
            GameContext([], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);
        var card = Card(CardColor.Diamond, CardHead.Ace);
        expect(gameContext.isPlayedCardBelote(card, TestFactory.leftPlayer), BeloteResult.None);
      });

      test('when card is a belote card and player does not have the other belote card', () {
        var gameContext =
            GameContext([], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);
        var card = Card(CardColor.Diamond, CardHead.Queen);
        var player = TestFactory.leftPlayer..cards = [Card(CardColor.Spade, CardHead.King)];
        expect(gameContext.isPlayedCardBelote(card, player), BeloteResult.None);
      });

      test('when card is a belote card and player has the other belote card', () {
        var player = TestFactory.leftPlayer..cards = [Card(CardColor.Diamond, CardHead.King)];
        var card = Card(CardColor.Diamond, CardHead.Queen);
        var gameContext = GameContext([], [
          Turn(1, TestFactory.leftPlayer)
            ..trumpColor = CardColor.Diamond
            ..cardRounds = [CardRound(TestFactory.leftPlayer)..playedCards[player.position] = card]
        ]);
        expect(gameContext.isPlayedCardBelote(card, player), BeloteResult.Belote);
      });

      test('when card is a belote card and player played the other belote card', () {
        var player = TestFactory.leftPlayer..cards = [];
        var card = Card(CardColor.Diamond, CardHead.Queen);
        var gameContext = GameContext([], [
          Turn(1, TestFactory.leftPlayer)
            ..trumpColor = CardColor.Diamond
            ..cardRounds = [
              CardRound(TestFactory.leftPlayer)..playedCards[player.position] = card,
              CardRound(TestFactory.leftPlayer)
                ..playedCards[player.position] = Card(CardColor.Diamond, CardHead.King)
            ]
        ]);
        expect(gameContext.isPlayedCardBelote(card, player), BeloteResult.Rebelote);
      });
    });

    group('analyseDeclarations', () {
      test('finds Tierce and stores it in lastTurn', () {
        final cards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
        ];
        final orderedCards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        final expectedDeclarations = {
          Position.Left: [Declaration(DeclarationType.Tierce, orderedCards)]
        };
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('finds several Declarations and stores it in lastTurn', () {
        final cards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Queen),
          Card(CardColor.Spade, CardHead.Ace),
        ];
        final orderedDiamondsCards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
        ];
        final orderedSpadeCards = [
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Queen),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Ace),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Tierce, orderedDiamondsCards),
            Declaration(DeclarationType.Quinte, orderedSpadeCards),
          ]
        };
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('finds Quarte and stores it in lastTurn', () {
        final cards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.Ace),
        ];
        final orderedCards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Ace),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        final expectedDeclarations = {
          Position.Left: [Declaration(DeclarationType.Quarte, orderedCards)]
        };
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('finds Square and stores it in lastTurn', () {
        final kingSquare = [
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Heart, CardHead.King),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Club, CardHead.King),
        ];
        final queenSquare = [
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Heart, CardHead.Queen),
          Card(CardColor.Spade, CardHead.Queen),
          Card(CardColor.Club, CardHead.Queen),
        ];
        final cards = [
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Heart, CardHead.King),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Heart, CardHead.Queen),
          Card(CardColor.Spade, CardHead.Queen),
          Card(CardColor.Club, CardHead.Queen),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Square, kingSquare),
            Declaration(DeclarationType.Square, queenSquare),
          ]
        };
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('ignores squares of 8 and 7', () {
        final cards = [
          Card(CardColor.Diamond, CardHead.Eight),
          Card(CardColor.Heart, CardHead.Eight),
          Card(CardColor.Spade, CardHead.Eight),
          Card(CardColor.Club, CardHead.Eight),
          Card(CardColor.Diamond, CardHead.Seven),
          Card(CardColor.Heart, CardHead.Seven),
          Card(CardColor.Spade, CardHead.Seven),
          Card(CardColor.Club, CardHead.Seven),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, isEmpty);
      });

      test('finds Square and stores it in lastTurn with jacks and nines', () {
        final jackSquare = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Heart, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Club, CardHead.Jack),
        ];
        final nineSquare = [
          Card(CardColor.Diamond, CardHead.Nine),
          Card(CardColor.Heart, CardHead.Nine),
          Card(CardColor.Spade, CardHead.Nine),
          Card(CardColor.Club, CardHead.Nine),
        ];
        final cards = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Heart, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Nine),
          Card(CardColor.Heart, CardHead.Nine),
          Card(CardColor.Spade, CardHead.Nine),
          Card(CardColor.Club, CardHead.Nine),
        ];
        final player = TestFactory.leftPlayer..cards = cards;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Square, jackSquare),
            Declaration(DeclarationType.Square, nineSquare),
          ]
        };
        var gameContext = GameContext(
            [player], [Turn(1, TestFactory.leftPlayer)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('removes lower sequence if 2 teams have a Tierce', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Club, CardHead.Ace),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Queen),
        ];
        final cards2 = [
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Queen),
        ];
        final orderedCards1 = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
        ];
        final orderedCards2 = [
          Card(CardColor.Club, CardHead.Queen),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Tierce, orderedCards1),
            Declaration(DeclarationType.Tierce, orderedCards2),
          ]
        };
        var gameContext = GameContext(
            [player1, player2], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('removes regular sequence if 2 teams have a Tierce of with same high card but one is at Trump color', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Queen),
        ];
        final cards2 = [
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Queen),
        ];
        final orderedCards1 = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Tierce, orderedCards1),
          ]
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('removes both sequence if 2 teams have a Tierce of with same high card none at Trump color', () {
        final cards1 = [
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Queen),
        ];
        final cards2 = [
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Queen),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, isEmpty);
      });

      test('removes lowest sequence if 2 teams have a Tierce and a Quarte', () {
        final cards1 = [
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Queen),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final cards2 = [
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Queen),
        ];
        final orderedCards1 = [
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Club, CardHead.Queen),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Quarte, orderedCards1),
          ]
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('removes lowest sequence if 2 teams have a Tierce and a Quinte', () {
        final cards1 = [
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Queen),
          Card(CardColor.Club, CardHead.Ten),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final cards2 = [
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Queen),
        ];
        final orderedCards1 = [
          Card(CardColor.Club, CardHead.Ten),
          Card(CardColor.Club, CardHead.Jack),
          Card(CardColor.Club, CardHead.Queen),
          Card(CardColor.Club, CardHead.King),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Quinte, orderedCards1),
          ]
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('removes lowest square if 2 teams have a Square', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Jack),
          Card(CardColor.Heart, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Club, CardHead.Jack),
        ];
        final cards2 = [
          Card(CardColor.Diamond, CardHead.Nine),
          Card(CardColor.Heart, CardHead.Nine),
          Card(CardColor.Spade, CardHead.Nine),
          Card(CardColor.Club, CardHead.Nine),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Left: [
            Declaration(DeclarationType.Square, cards1),
          ]
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('cancels square if 2 teams have a Square of same value', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Ten),
          Card(CardColor.Heart, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Club, CardHead.Ten),
        ];
        final cards2 = [
          Card(CardColor.Diamond, CardHead.Ace),
          Card(CardColor.Heart, CardHead.Ace),
          Card(CardColor.Spade, CardHead.Ace),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final player1 = TestFactory.leftPlayer..cards = cards1;
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Top: [
            Declaration(DeclarationType.Square, cards2),
          ]
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('cancels only square if 2 teams have a Square of same value and a Tierce', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Ten),
          Card(CardColor.Heart, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Club, CardHead.Ten),
        ];
        final cards2 = [
          Card(CardColor.Diamond, CardHead.Ace),
          Card(CardColor.Heart, CardHead.Ace),
          Card(CardColor.Spade, CardHead.Ace),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final cards3 = [
          Card(CardColor.Diamond, CardHead.Queen),
          Card(CardColor.Diamond, CardHead.King),
          Card(CardColor.Diamond, CardHead.Ace),
        ];
        final player1 = TestFactory.leftPlayer..cards = (cards1.toList()..addAll(cards3));
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Top: [
            Declaration(DeclarationType.Square, cards2),
          ],
          Position.Left: [
            Declaration(DeclarationType.Tierce, cards3),
          ],
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });

      test('2 cards cannot be of the same declaration', () {
        final cards1 = [
          Card(CardColor.Diamond, CardHead.Ten),
          Card(CardColor.Heart, CardHead.Ten),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Club, CardHead.Ten),
        ];
        final cards2 = [
          Card(CardColor.Diamond, CardHead.Ace),
          Card(CardColor.Heart, CardHead.Ace),
          Card(CardColor.Spade, CardHead.Ace),
          Card(CardColor.Club, CardHead.Ace),
        ];
        final cards3 = [
          Card(CardColor.Diamond, CardHead.Seven),
          Card(CardColor.Diamond, CardHead.Eight),
          Card(CardColor.Diamond, CardHead.Nine),
        ];
        final player1 = TestFactory.leftPlayer..cards = (cards1.toList()..addAll(cards3));
        final player2 = TestFactory.topPlayer..cards = cards2;
        final expectedDeclarations = {
          Position.Top: [
            Declaration(DeclarationType.Square, cards2),
          ],
          Position.Left: [
            Declaration(DeclarationType.Tierce, cards3),
          ],
        };
        var gameContext = GameContext(
            [player2, player1], [Turn(1, player1)..trumpColor = CardColor.Diamond]);

        expect(gameContext.analyseDeclarations().lastTurn.playerDeclarations, expectedDeclarations);
      });
    });
  });
}
