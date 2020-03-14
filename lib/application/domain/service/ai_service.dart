import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:collection/collection.dart';

class AiService {
  final CardService _cardService;

  AiService(this._cardService);

  Card chooseCard(List<Card> cards, Turn turn, bool isVertical) {
    var lastCardRound = turn.lastCardRound;
    var cardRoundWinner = turn.getCardRoundWinner(lastCardRound);
    var highestCardByColor = _getHighestCardByColor(turn);

    var winningCards = cards.where((card) => highestCardByColor.values.contains(card));
    if (winningCards.isEmpty) {
      var isPartnerWinning = cardRoundWinner.key.isVertical == isVertical;
      if (isPartnerWinning) {
        return _getBestCard(cards, cardRoundWinner.value.color == turn.trumpColor);
      } else {
        return cards.reduce((card1, card2) => card1.head.order < card2.head.order ? card1 : card2);
      }
    } else {
      return winningCards.first;
    }
  }

  Map<CardColor, Card> _getHighestCardByColor(Turn turn) {
    Map<CardColor, Card> resultMap = Map();
    var allPlayedCards = turn.cardRounds
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
}
