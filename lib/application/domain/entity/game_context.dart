import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class GameContext extends Equatable {
  final List<Player> players;
  final List<Turn> turns;

  Turn get lastTurn => turns.last;

  GameContext(this.players, this.turns);

  @override
  List<Object> get props => [players, turns];

  @override
  String toString() {
    return 'GameContext{players: $players, turns: $turns}';
  }

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
    turns.add(Turn(lastTurn.number + 1, firstPlayer));
    return this;
  }

  GameContext setCardDecision(Card card, Player player) {
    lastTurn.lastCardRound.playedCards[player.position] = card;
    players.firstWhere((p) => p.position == player.position).cards.remove(card);

    return this;
  }

  GameContext newCardRound() {
    var cartRound;
    if (lastTurn.cardRounds.isEmpty) {
      cartRound = CartRound(lastTurn.firstPlayer);
    } else {
      var highestCardPosition = lastTurn.getCardRoundWinner(lastTurn.lastCardRound);
      cartRound = CartRound(players.firstWhere((player) => player.position == highestCardPosition));
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
}
