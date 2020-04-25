import 'dart:collection';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum BeloteResult { Belote, Rebelote, None }

class GameContext extends Equatable {
  final UnmodifiableListView<Player> players;
  final UnmodifiableListView<Turn> turns;

  Turn get lastTurn => turns.last;

  GameContext(List<Player> players, List<Turn> turns)
      : players = UnmodifiableListView(players),
        turns = UnmodifiableListView(turns);

  @override
  List<Object> get props => [players, turns];

  @override
  bool get stringify => true;

  GameContext setDecision(Player player, Decision decision) {
    lastTurn.playerDecisions[player.position] = decision;
    return this;
  }

  Player nextPlayer() {
    if (lastTurn.playerDecisions.length == players.length) {
      return null;
    }
    final lastTurnFirstPlayer = lastTurn.firstPlayer;
    var index = players.indexOf(lastTurnFirstPlayer) + lastTurn.playerDecisions.length;

    if (index >= players.length) {
      index -= 4;
    }

    return players[index];
  }

  GameContext nextRound() {
    lastTurn.round = 2;
    lastTurn.playerDecisions.clear();
    return this;
  }

  GameContext nextTurn() {
    var firstPlayerIndex = players.indexOf(lastTurn.firstPlayer) + 1;
    if (firstPlayerIndex == players.length) {
      firstPlayerIndex = 0;
    }

    var firstPlayer = players[firstPlayerIndex];
    return GameContext(players, turns.toList()..add(Turn(lastTurn.number + 1, firstPlayer)));
  }

  GameContext setCardDecision(Card card, Player player) {
    lastTurn.lastCardRound.playedCards[player.position] = card;
    players.firstWhere((p) => p.position == player.position).cards.remove(card);

    if (isPlayedCardBelote(card, player) != BeloteResult.None) {
      lastTurn.belote = player.position;
    }

    return this;
  }

  GameContext newCardRound() {
    var cartRound;
    if (lastTurn.cardRounds.isEmpty) {
      cartRound = CardRound(lastTurn.firstPlayer);
    } else {
      var highestCardPosition = lastTurn.getCardRoundWinnerPosition(lastTurn.lastCardRound);
      cartRound = CardRound(players.firstWhere((player) => player.position == highestCardPosition));
    }

    lastTurn.cardRounds.add(cartRound);

    return this;
  }

  Player nextCardPlayer() {
    if (lastTurn.lastCardRound.playedCards.length == players.length) {
      return null;
    }

    var index = players.indexOf(lastTurn.lastCardRound.firstPlayer) +
        lastTurn.lastCardRound.playedCards.length;

    if (index >= players.length) {
      index -= 4;
    }

    return players[index];
  }

  List<Card> getPossibleCardsToPlay(Player player) {
    var lastCardRound = lastTurn.lastCardRound;

    if (player == lastCardRound.firstPlayer) {
      return player.cards;
    } else {
      List<Card> cardsForColor = _getCardsOfRequestedColor(lastCardRound, player);
      if (cardsForColor.length > 0) {
        return cardsForColor;
      } else {
        var trumpCards = player.cards.where((card) => card.color == lastTurn.trumpColor);
        if (trumpCards.isEmpty) {
          return player.cards;
        } else {
          var playedTrumpCards =
              lastCardRound.playedCards.values.where((card) => card.color == lastTurn.trumpColor);
          if (playedTrumpCards.isEmpty) {
            if (lastTurn.getCardRoundWinnerPosition(lastCardRound).isVertical ==
                player.position.isVertical) {
              return player.cards;
            }
            return trumpCards.toList();
          } else {
            var higherTrumpCards = trumpCards.where((card) => !playedTrumpCards
                .any((playedCard) => playedCard.head.trumpOrder > card.head.trumpOrder));
            return higherTrumpCards.isEmpty ? trumpCards.toList() : higherTrumpCards.toList();
          }
        }
      }
    }
  }

  List<Card> _getCardsOfRequestedColor(CardRound lastCardRound, Player player) {
    var requestedColor = lastCardRound.playedCards[lastCardRound.firstPlayer.position].color;
    var cardsForColor = player.cards.where((card) => card.color == requestedColor).toList();
    if (requestedColor == lastTurn.trumpColor) {
      var highestTrumpPlayedValue = lastCardRound.playedCards.values
          .where((card) => card.color == lastTurn.trumpColor)
          .reduce((card1, card2) => card1.head.trumpOrder > card2.head.trumpOrder ? card1 : card2)
          .head
          .trumpOrder;
      cardsForColor =
          cardsForColor.where((card) => card.head.trumpOrder > highestTrumpPlayedValue).toList();
    }
    return cardsForColor;
  }

  BeloteResult isPlayedCardBelote(Card card, Player player) {
    var beloteCards = [
      Card(lastTurn.trumpColor, CardHead.King),
      Card(lastTurn.trumpColor, CardHead.Queen)
    ];
    if (beloteCards.contains(card)) {
      var allPlayerCards = player.cards.toList()..add(card);
      if (allPlayerCards.where((playerCard) => beloteCards.contains(playerCard)).length == 2) {
        return BeloteResult.Belote;
      } else if (lastTurn.cardRounds
              .where((cardRound) => beloteCards.contains(cardRound.playedCards[player.position]))
              .length ==
          2) {
        return BeloteResult.Rebelote;
      }
    }

    return BeloteResult.None;
  }

  GameContext analyseDeclarations() {
    Map<Position, List<Declaration>> playerDeclarations = _getAllPlayerDeclarations();
    final playerSequenceDeclarations = playerDeclarations.entries.where(
      (entry) =>
          entry.value.where((declaration) => declaration.type != DeclarationType.Square).isNotEmpty,
    );
    final playerSquareDeclarations = playerDeclarations.entries.where(
      (entry) =>
          entry.value.where((declaration) => declaration.type == DeclarationType.Square).isNotEmpty,
    );

    if (playerSequenceDeclarations.isNotEmpty) {
      final bestSequenceDeclarationByPlayer = playerSequenceDeclarations.map((entry) => MapEntry(
          entry.key, entry.value.reduce((a, b) => a.cards.length > b.cards.length ? a : b)));
      var bestSequence = bestSequenceDeclarationByPlayer.length > 1
          ? bestSequenceDeclarationByPlayer.reduce((entry1, entry2) =>
              entry1.value.cards.length > entry2.value.cards.length ? entry1 : entry2)
          : bestSequenceDeclarationByPlayer.first;

      final otherEqualSequences = bestSequenceDeclarationByPlayer.where((entry) =>
          entry.value.cards.length == bestSequence.value.cards.length &&
          entry.key != bestSequence.key);

      Declaration bestSequenceDeclaration = bestSequence.value;
      if (otherEqualSequences.isNotEmpty) {
        otherEqualSequences.forEach((entry) {
          if (bestSequenceDeclaration == null) {
            bestSequenceDeclaration = entry.value;
          } else {
            if (bestSequenceDeclaration.cards.last.head.sequenceOrder <
                entry.value.cards.last.head.sequenceOrder) {
              bestSequenceDeclaration = entry.value;
            } else if (bestSequenceDeclaration.cards.last.head.sequenceOrder ==
                    entry.value.cards.last.head.sequenceOrder &&
                entry.value.cards.last.color == lastTurn.trumpColor) {
              bestSequenceDeclaration = entry.value;
            } else if (bestSequenceDeclaration.cards.last.head.sequenceOrder ==
                    entry.value.cards.last.head.sequenceOrder &&
                entry.value.cards.last.color != lastTurn.trumpColor &&
                bestSequenceDeclaration.cards.last.color != lastTurn.trumpColor) {
              bestSequenceDeclaration = null;
            }
          }
        });
      }

      if (bestSequenceDeclaration == null) {
        playerDeclarations = {};
      } else {
        final bestSequencePosition = bestSequenceDeclarationByPlayer
            .firstWhere((entry) => entry.value == bestSequenceDeclaration)
            .key;
        playerDeclarations.entries.forEach((entry) => entry.value.removeWhere((declaration) =>
            entry.key.isVertical != bestSequencePosition.isVertical &&
            declaration.type != DeclarationType.Square));
      }
    }

    if (playerSquareDeclarations.isNotEmpty) {
      var bestSquareDeclaration = playerSquareDeclarations
          .map((entry) => MapEntry(
              entry.key,
              entry.value.reduce((declaration1, declaration2) =>
                  lastTurn.getPointsForDeclaration(declaration1) >
                          lastTurn.getPointsForDeclaration(declaration2)
                      ? declaration1
                      : declaration2)))
          .reduce((entry1, entry2) => lastTurn.getPointsForDeclaration(entry1.value) >
                  lastTurn.getPointsForDeclaration(entry2.value)
              ? entry1
              : entry2);
      if (bestSquareDeclaration.value.cards.first.head != CardHead.Jack &&
          bestSquareDeclaration.value.cards.first.head != CardHead.Nine) {
        var otherSquares = playerSquareDeclarations.where((entry) => entry.value
            .where((declaration) => declaration != bestSquareDeclaration.value)
            .isNotEmpty);
        if (otherSquares.isNotEmpty) {
          otherSquares.forEach((entry) {
            entry.value.forEach((declaration) {
              if (declaration.cards.first.head.sequenceOrder >
                  bestSquareDeclaration.value.cards.first.head.sequenceOrder) {
                bestSquareDeclaration = MapEntry(entry.key, declaration);
              }
            });
          });
        }
      }

      final bestSequencePosition = bestSquareDeclaration.key;
      playerDeclarations.entries.forEach((entry) => entry.value.removeWhere((declaration) =>
          entry.key.isVertical != bestSequencePosition.isVertical &&
          declaration.type == DeclarationType.Square));
    }

    playerDeclarations.removeWhere((position, declarations) => declarations.isEmpty);

    lastTurn.playerDeclarations = playerDeclarations;
    return this;
  }

  Map<Position, List<Declaration>> _getAllPlayerDeclarations() {
    var playerDeclarations = <Position, List<Declaration>>{};

    players.forEach((player) {
      final playerCards = player.cards.toList();

      List<Declaration> carreDeclarations = _getCarreDeclarations(playerCards);
      List<Declaration> sequenceDeclarations = _getSequenceDeclarations(playerCards
        ..removeWhere((card) =>
            carreDeclarations.where((declaration) => declaration.cards.contains(card)).isNotEmpty));

      if (sequenceDeclarations.isNotEmpty || carreDeclarations.isNotEmpty) {
        playerDeclarations[player.position] = sequenceDeclarations.toList()
          ..addAll(carreDeclarations);
      }
    });
    return playerDeclarations;
  }

  List<Declaration> _getSequenceDeclarations(List<Card> playerCards) {
    var declarations = List<Declaration>();
    var cardsByColor = groupBy(playerCards, (playedCard) => playedCard.color)
      ..removeWhere((color, cards) => cards.length < 3);
    if (cardsByColor.isNotEmpty) {
      cardsByColor.forEach((color, cards) {
        final sortedCards = cards.toList()
          ..sort((a, b) => a.head.sequenceOrder.compareTo(b.head.sequenceOrder));

        var counter = 0;
        var lastSequenceIndex = -100;
        var declarationCards = List<Card>();
        sortedCards.forEach((card) {
          if (lastSequenceIndex != card.head.sequenceOrder - counter) {
            declarationCards.clear();
            counter = 0;
            lastSequenceIndex = card.head.sequenceOrder;
          }

          declarationCards.add(card);
          counter++;

          if (counter == 3) {
            declarations.add(Declaration(DeclarationType.Tierce, declarationCards));
          } else if (counter == 4) {
            declarations.removeLast();
            declarations.add(Declaration(DeclarationType.Quarte, declarationCards));
          } else if (counter == 5) {
            declarations.removeLast();
            declarations.add(Declaration(DeclarationType.Quinte, declarationCards));
          }
        });
      });
    }
    return declarations;
  }

  List<Declaration> _getCarreDeclarations(List<Card> playerCards) {
    return groupBy(playerCards, (card) => card.head)
        .entries
        .where((entry) =>
            entry.value.length == 4 &&
            entry.value.first.head != CardHead.Seven &&
            entry.value.first.head != CardHead.Eight)
        .map((entry) => Declaration(DeclarationType.Square, entry.value))
        .toList();
  }
}
