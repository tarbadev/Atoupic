import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'card.dart';

enum Position { Top, Bottom, Left, Right }

class Player extends Equatable {
  final bool isRealPlayer;
  final Position position;
  List<Card> cards;

  Player(this.cards, this.position, {this.isRealPlayer = false}) {
    initializeCards();
  }

  @override
  List<Object> get props => [isRealPlayer, position, cards];

  @override
  String toString() {
    return 'Player{isRealPlayer: $isRealPlayer, position: $position, cards: $cards}';
  }

  void initializeCards() {
    if (isRealPlayer) {
      this.sortCards();
    }
  }

  int compareCards(Card card1, Card card2) {
    return card2.head.order.compareTo(card1.head.order);
  }

  void sortCards() {
    var cardsByColor = groupBy(cards, (Card card) => card.color);
    cardsByColor.values
        .forEach((unSortedCards) => unSortedCards.sort(compareCards));
    cards = new List();
    CardColor.values.forEach((color) {
      if (cardsByColor.containsKey(color)) {
        cards.addAll(cardsByColor[color]);
      }
    });
  }
//
//  void addCards(List<Card> cards) {
//    this.cards.addAll(cards);
//  }
}
