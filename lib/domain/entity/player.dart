import 'package:equatable/equatable.dart';

import 'card.dart';

enum Position { Top, Bottom, Left, Right }

extension PositionExtension on Position {
  bool get isVertical {
    return this == Position.Bottom || this == Position.Top;
  }
}

class Player extends Equatable {
  final bool isRealPlayer;
  final Position position;
  List<Card> cards;

  Player(this.position, {this.isRealPlayer = false});

  @override
  List<Object> get props => [isRealPlayer, position, cards];

  @override
  String toString() {
    return 'Player{isRealPlayer: $isRealPlayer, position: $position, cards: $cards}';
  }

  void sortCards({CardColor trumpColor}) {
    cards.sort((card1, card2) => _compareCards(card1, card2, trumpColor));
  }

  int _compareCards(Card card1, Card card2, CardColor trumpColor) {
    var order1Value = _getComparableOrder(card1, card1.color == trumpColor);
    var order2Value = _getComparableOrder(card2, card2.color == trumpColor);
    return order2Value.compareTo(order1Value);
  }

  int _getComparableOrder(Card card, bool isTrumpColor) {
    var colorValue = card.color.index * 10;
    var headValue = isTrumpColor ? card.head.trumpOrder : card.head.order;
    return colorValue + headValue;
  }

  int compareTrumpCards(Card card1, Card card2) {
    return card2.head.trumpOrder.compareTo(card1.head.trumpOrder);
  }
}
