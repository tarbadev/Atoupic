import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'card.dart';

enum Position { Top, Bottom, Left, Right }

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
    var cardsByColor = groupBy(cards, (Card card) => card.color);
    cardsByColor.entries
        .forEach((entry) => entry.value.sort(entry.key == trumpColor ? compareTrumpCards : compareCards));
    cards = new List();
    CardColor.values.forEach((color) {
      if (cardsByColor.containsKey(color)) {
        cards.addAll(cardsByColor[color]);
      }
    });
  }

  int compareCards(Card card1, Card card2) {
    return card2.head.order.compareTo(card1.head.order);
  }

  int compareTrumpCards(Card card1, Card card2) {
    return card2.head.trumpOrder.compareTo(card1.head.trumpOrder);
  }
}
