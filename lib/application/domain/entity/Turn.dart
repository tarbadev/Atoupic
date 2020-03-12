import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
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
      [number, card, firstPlayer, playerDecisions, round, cardRounds];

  @override
  String toString() {
    return 'Turn{number: $number, firstPlayer: $firstPlayer, card: $card, playerDecisions: $playerDecisions, cardRounds: $cardRounds, round: $round}';
  }

  void calculatePoints(List<Player> players) {
    var takerPosition = playerDecisions.entries
        .where((entry) => entry.value == Decision.Take)
        .single
        .key;
    var taker = players.firstWhere((p) => p.position == takerPosition);

    var horizontalPoints = 0;
    var verticalPoints = 0;

    cardRounds.asMap().forEach((index, cardRound) {
      Position winnerPosition = getCardRoundWinner(cardRound);
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
      verticalScore = isSuccessful ? verticalPoints : 0;
      horizontalScore = !isSuccessful ? 162 : horizontalPoints;
    } else {
      verticalScore = !isSuccessful ? 162 : verticalPoints;
      horizontalScore = isSuccessful ? horizontalPoints : 0;
    }

    var turnResult = TurnResult(
      taker,
      horizontalPoints,
      verticalPoints,
      result,
      horizontalScore,
      verticalScore,
    );

    print('Result: $turnResult');

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

  Position getCardRoundWinner(CartRound cartRound) {
    var requestedColor =
        cartRound.playedCards[cartRound.firstPlayer.position].color;
    var trumpCards = cartRound.playedCards.entries
        .where((entry) => entry.value.color == trumpColor);
    var highestCardPosition;
    if (trumpCards.isEmpty) {
      highestCardPosition = cartRound.playedCards.entries
          .where((entry) => entry.value.color == requestedColor)
          .reduce((entry1, entry2) =>
              entry1.value.head.order > entry2.value.head.order
                  ? entry1
                  : entry2)
          .key;
    } else {
      highestCardPosition = trumpCards
          .reduce((entry1, entry2) =>
              entry1.value.head.trumpOrder > entry2.value.head.trumpOrder
                  ? entry1
                  : entry2)
          .key;
    }
    return highestCardPosition;
  }
}

enum Result { Success, Failure }

class TurnResult extends Equatable {
  final Player taker;
  final int horizontalCardPoints;
  final int verticalCardPoints;
  final int horizontalScore;
  final int verticalScore;
  final Result result;

  TurnResult(this.taker, this.horizontalCardPoints, this.verticalCardPoints,
      this.result, this.horizontalScore, this.verticalScore);

  @override
  List<Object> get props => [
        this.taker,
        this.horizontalCardPoints,
        this.verticalCardPoints,
        this.result,
        this.horizontalScore,
        this.verticalScore,
      ];

  @override
  String toString() {
    return 'TurnResult{taker: $taker, horizontalCardPoints: $horizontalCardPoints, verticalCardPoints: $verticalCardPoints, horizontalScore: $horizontalScore, verticalScore: $verticalScore, result: $result}';
  }
}
