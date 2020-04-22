import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:collection/collection.dart';

class AiService {
  final CardService _cardService;

  AiService(this._cardService);

  Card chooseCard(List<Card> cards, Turn turn, Position playerPosition) {
    var lastCardRound = turn.lastCardRound;
    var winningCards = _getWinningCards(turn, cards);
    var didCurrentTeamTake = _didCurrentTeamTake(turn, playerPosition.isVertical);
    var takerPosition =
        turn.playerDecisions.entries.firstWhere((entry) => entry.value == Decision.Take).key;

    if (lastCardRound.playedCards.isEmpty) {
      if (didCurrentTeamTake && winningCards.isEmpty) {
        var trumpCards = _filterCardsByTrump(cards, turn.trumpColor, true);
        if (takerPosition == playerPosition) {
          final bestTrumpCards = [
            Card(turn.trumpColor, CardHead.Jack),
            Card(turn.trumpColor, CardHead.Nine),
            Card(turn.trumpColor, CardHead.Ace)
          ];
          trumpCards = trumpCards.toList()..removeWhere((card) => bestTrumpCards.contains(card));
        }
        return _getBestCard(trumpCards.isEmpty ? cards : trumpCards, true);
      } else if (didCurrentTeamTake) {
        winningCards = _filterCardsByTrump(winningCards, turn.trumpColor, true);
      } else {
        winningCards = _filterCardsByTrump(winningCards, turn.trumpColor, false);
      }

      return winningCards.isEmpty ? _getLowestCard(cards) : winningCards.first;
    } else {
      var requestedColor = lastCardRound.playedCards[lastCardRound.firstPlayer.position].color;
      var cardRoundWinner = lastCardRound.getCardRoundWinner(turn.trumpColor);
      var isPartnerWinning = cardRoundWinner.key.isVertical == playerPosition.isVertical;
      if (isPartnerWinning) {
        var partnerPlayedWinningCard = _getHighestCardByColor(turn)
            .values
            .where((card) => card == cardRoundWinner.value)
            .isNotEmpty;
        if (partnerPlayedWinningCard || cardRoundWinner.value.color == turn.trumpColor) {
          return _getBestCard(cards, requestedColor == turn.trumpColor);
        } else {
          return _getLowestCard(cards);
        }
      } else {
        if (cardRoundWinner.value.color == turn.trumpColor) {
          return _getLowestCard(cards);
        } else {
          return _winningCardOrLowestCard(winningCards, cards, requestedColor);
        }
      }
    }
  }

  Iterable<Card> _filterCardsByTrump(
          Iterable<Card> cards, CardColor trumpColor, bool justTrumpColor) =>
      cards.where((card) => (card.color == trumpColor) == justTrumpColor);

  bool _didCurrentTeamTake(Turn turn, bool isVertical) {
    return turn.playerDecisions.entries
            .firstWhere((entry) => entry.value == Decision.Take)
            .key
            .isVertical ==
        isVertical;
  }

  Iterable<Card> _getWinningCards(Turn turn, List<Card> cards) {
    var highestCardByColor = _getHighestCardByColor(turn);
    var winningCards = cards.where((card) => highestCardByColor.values.contains(card));
    return winningCards;
  }

  Card _winningCardOrLowestCard(
      Iterable<Card> winningCards, List<Card> cards, CardColor requestedColor) {
    if (winningCards.isEmpty) {
      return _getLowestCard(cards);
    } else {
      return winningCards.firstWhere(
        (card) => card.color == requestedColor,
        orElse: () => _getLowestCard(cards),
      );
    }
  }

  Card _getLowestCard(Iterable<Card> cards) {
    return cards.reduce((card1, card2) => card1.head.order <= card2.head.order ? card1 : card2);
  }

  Map<CardColor, Card> _getHighestCardByColor(Turn turn) {
    Map<CardColor, Card> resultMap = Map();
    final previousCardRounds = turn.cardRounds.toList()..removeLast();
    var allPlayedCards = previousCardRounds.isEmpty
        ? <Card>[]
        : previousCardRounds
            .map((cardRound) => cardRound.playedCards.values)
            .reduce((cards1, cards2) => cards1.toList()..addAll(cards2));

    var remainingCards = _cardService.getAllCards()
      ..removeWhere((card) => allPlayedCards.contains(card));

    Map<CardColor, Iterable<Card>> cardsByColor =
        groupBy(remainingCards, (playedCard) => playedCard.color);
    cardsByColor.keys.forEach(
        (color) => resultMap[color] = _getBestCard(cardsByColor[color], color == turn.trumpColor));

    return resultMap;
  }

  Card _getBestCard(Iterable<Card> cards, bool isTrumpColor) {
    if (isTrumpColor) {
      return cards
          .reduce((card1, card2) => card1.head.trumpOrder > card2.head.trumpOrder ? card1 : card2);
    } else {
      return cards.reduce((card1, card2) => card1.head.order > card2.head.order ? card1 : card2);
    }
  }

  CardColor takeOrPass(List<Card> cards, Turn turn) {
    final potentialCards = cards.toList()..add(turn.card);
    if (turn.round == 1 && _canTakeForTrumpColor(turn, potentialCards, turn.card.color)) {
      return turn.card.color;
    } else {
      final otherColors = CardColor.values.where((color) => color != turn.card.color);
      var selectedColor;
      for (final color in otherColors) {
        if (_canTakeForTrumpColor(turn, potentialCards, color)) {
          selectedColor = color;
          break;
        }
      }
      return selectedColor;
    }
  }

  bool _canTakeForTrumpColor(Turn turn, List<Card> cards, CardColor trumpColor) {
    final bestTrumpCards = [
      Card(trumpColor, CardHead.Jack),
      Card(trumpColor, CardHead.Nine),
      Card(trumpColor, CardHead.Ace),
    ];
    final trumpCards = cards.where((card) => card.color == trumpColor);
    final numberOfBestTrumpCards = bestTrumpCards.where((card) => trumpCards.contains(card)).length;
    if (trumpCards.length >= 5) {
      return true;
    } else {
      if (numberOfBestTrumpCards >= 2) {
        final nonTrumpCards = cards.where((card) => !trumpCards.contains(card)).toList();
        final nonTrumpPoints = turn.calculatePointsFromCards(nonTrumpCards, trumpColor);
        if (nonTrumpPoints >= 6) {
          return true;
        }
      }
    }

    return false;
  }
}
