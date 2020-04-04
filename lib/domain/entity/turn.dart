import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final int number;
  final Player firstPlayer;
  Card card;
  Map<Position, Decision> playerDecisions = Map();
  List<CartRound> cardRounds = List();
  int round = 1;
  CardColor trumpColor;
  TurnResult turnResult;

  CartRound get lastCardRound => cardRounds.length > 0 ? cardRounds.last : null;

  Turn(this.number, this.firstPlayer);

  @override
  List<Object> get props =>
      [number, card, firstPlayer, playerDecisions, round, cardRounds, trumpColor, turnResult];

  @override
  bool get stringify => true;

  void calculatePoints(List<Player> players) {
    var takerPosition = playerDecisions.entries
        .where((entry) => entry.value == Decision.Take)
        .single
        .key;
    var taker = players.firstWhere((p) => p.position == takerPosition);

    var horizontalPoints = 0;
    var verticalPoints = 0;

    cardRounds.asMap().forEach((index, cardRound) {
      Position winnerPosition = getCardRoundWinnerPosition(cardRound);
      var isLastRound = index == cardRounds.length - 1;
      if (winnerPosition.isVertical) {
        verticalPoints += _calculateRoundPoints(isLastRound, cardRound);
      } else {
        horizontalPoints += _calculateRoundPoints(isLastRound, cardRound);
      }
    });

    var isTakerVertical = takerPosition.isVertical;
    final minimumPoints = 82;
    var isSuccessful = isTakerVertical && verticalPoints >= minimumPoints ||
        !isTakerVertical && horizontalPoints >= minimumPoints;
    var result = isSuccessful ? Result.Success : Result.Failure;
    var verticalScore = 0;
    var horizontalScore = 0;

    if (isTakerVertical) {
      if (isSuccessful) {
        verticalScore = horizontalPoints == 0 ? 252 : verticalPoints;
        horizontalScore = horizontalPoints;
      } else {
        verticalScore = 0;
        horizontalScore = verticalPoints == 0 ? 252 : 162;
      }
    } else {
      if (isSuccessful) {
        verticalScore = verticalPoints;
        horizontalScore = verticalPoints == 0 ? 252 : horizontalPoints;
      } else {
        verticalScore = horizontalPoints == 0 ? 252 : 162;
        horizontalScore = 0;
      }
    }

    var turnResult = TurnResult(
      taker,
      horizontalPoints,
      verticalPoints,
      result,
      horizontalScore,
      verticalScore,
    );

    this.turnResult = turnResult;
  }

  int _calculateRoundPoints(bool isLastRound, CartRound cardRound) {
    var points = 0;

    if (isLastRound) {
      points += 10;
    }

    cardRound.playedCards.values.forEach((card) => points +=
        card.color == trumpColor ? card.head.trumpPoints : card.head.points);

    return points;
  }

  Position getCardRoundWinnerPosition(CartRound cartRound) => getCardRoundWinner(cartRound).key;

  MapEntry<Position, Card> getCardRoundWinner(CartRound cartRound) {
    var requestedColor =
        cartRound.playedCards[cartRound.firstPlayer.position].color;
    var trumpCards = cartRound.playedCards.entries
        .where((entry) => entry.value.color == trumpColor);
    var winner;
    if (trumpCards.isEmpty) {
      winner = cartRound.playedCards.entries
          .where((entry) => entry.value.color == requestedColor)
          .reduce((entry1, entry2) =>
              entry1.value.head.order > entry2.value.head.order
                  ? entry1
                  : entry2);
    } else {
      winner = trumpCards
          .reduce((entry1, entry2) =>
              entry1.value.head.trumpOrder > entry2.value.head.trumpOrder
                  ? entry1
                  : entry2);
    }
    return winner;
  }
}
