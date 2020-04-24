import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/declaration.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn_result.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final int number;
  final Player firstPlayer;
  Card card;
  Map<Position, Decision> playerDecisions = Map();
  Map<Position, List<Declaration>> playerDeclarations = Map();
  List<CardRound> cardRounds = List();
  int round = 1;
  CardColor trumpColor;
  TurnResult turnResult;
  Position belote;

  CardRound get lastCardRound => cardRounds.length > 0 ? cardRounds.last : null;

  Turn(this.number, this.firstPlayer);

  @override
  List<Object> get props =>
      [number, card, firstPlayer, playerDecisions, round, cardRounds, trumpColor, turnResult];

  @override
  bool get stringify => true;

  void calculatePoints(List<Player> players) {
    var takerPosition =
        playerDecisions.entries.where((entry) => entry.value == Decision.Take).single.key;
    var taker = players.firstWhere((p) => p.position == takerPosition);

    var horizontalCardPoints = 0;
    var verticalCardPoints = 0;

    cardRounds.asMap().forEach((index, cardRound) {
      Position winnerPosition = getCardRoundWinnerPosition(cardRound);
      var isLastRound = index == cardRounds.length - 1;
      if (winnerPosition.isVertical) {
        verticalCardPoints += _calculateRoundPoints(isLastRound, cardRound);
      } else {
        horizontalCardPoints += _calculateRoundPoints(isLastRound, cardRound);
      }
    });

    final verticalDeclarations = playerDeclarations.entries.where((entry) => entry.key.isVertical);
    final horizontalDeclarations =
        playerDeclarations.entries.where((entry) => !entry.key.isVertical);
    var verticalDeclarationPoints =
        verticalDeclarations.isEmpty ? 0 : _calculateDeclarations(verticalDeclarations);
    var horizontalDeclarationPoints =
        horizontalDeclarations.isEmpty ? 0 : _calculateDeclarations(horizontalDeclarations);

    if (belote != null) {
      if (belote.isVertical) {
        verticalDeclarationPoints += 20;
      } else {
        horizontalDeclarationPoints += 20;
      }
    }

    var verticalPoints = verticalCardPoints + verticalDeclarationPoints;
    var horizontalPoints = horizontalCardPoints + horizontalDeclarationPoints;

    var isTakerVertical = takerPosition.isVertical;
    var isSuccessful = isTakerVertical && verticalPoints >= horizontalPoints ||
        !isTakerVertical && horizontalPoints >= verticalPoints;
    var result = isSuccessful ? Result.Success : Result.Failure;
    var verticalScore = 0;
    var horizontalScore = 0;

    if (isTakerVertical) {
      if (isSuccessful) {
        verticalScore = horizontalCardPoints == 0 ? 252 : verticalCardPoints;
        horizontalScore = horizontalCardPoints;
      } else {
        verticalScore = 0;
        horizontalScore = verticalCardPoints == 0 ? 252 : 162;
      }
    } else {
      if (isSuccessful) {
        verticalScore = verticalCardPoints;
        horizontalScore = verticalCardPoints == 0 ? 252 : horizontalCardPoints;
      } else {
        verticalScore = horizontalCardPoints == 0 ? 252 : 162;
        horizontalScore = 0;
      }
    }

    verticalScore += verticalDeclarationPoints;
    horizontalScore += horizontalDeclarationPoints;

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

  int _calculateRoundPoints(bool isLastRound, CardRound cardRound) {
    var points = 0;

    if (isLastRound) {
      points += 10;
    }

    points += calculatePointsFromCards(cardRound.playedCards.values.toList(), trumpColor);

    return points;
  }

  int calculatePointsFromCards(List<Card> cards, CardColor trumpColor) {
    var points = 0;

    cards.forEach(
        (card) => points += card.color == trumpColor ? card.head.trumpPoints : card.head.points);

    return points;
  }

  Position getCardRoundWinnerPosition(CardRound cartRound) =>
      cartRound.getCardRoundWinner(trumpColor).key;

  int _calculateDeclarations(Iterable<MapEntry<Position, List<Declaration>>> verticalDeclarations) {
    return verticalDeclarations
        .map((entry) => entry.value.map(_getPointsForDeclaration).reduce((a, b) => a + b))
        .reduce((a, b) => a + b);
  }

  int _getPointsForDeclaration(Declaration declaration) {
    switch (declaration.type) {
      case DeclarationType.Tierce:
        return 20;
      case DeclarationType.Quarte:
        return 50;
      case DeclarationType.Quinte:
        return 100;
      case DeclarationType.Square:
        if (declaration.cards.first.head == CardHead.Jack) {
          return 200;
        } else if (declaration.cards.first.head == CardHead.Nine) {
          return 150;
        }

        return 100;
      default:
        return 0;
    }
  }
}
