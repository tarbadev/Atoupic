import 'dart:collection';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/game_service.dart';
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
}
