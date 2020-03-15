import 'dart:math';

import 'package:atoupic/domain/entity/card.dart';

class CardService {
  List<Card> pile = [];
  Random _random;

  CardService() {
    _random = Random();
    initializeCards();
  }

  initializeCards() {
    pile = getAllCards();
  }

  List<Card> distributeCards(int count) {
    List<Card> cardsToDistribute = List();

    for (int i = 0; i < count; i++) {
      var card = pile[_random.nextInt(pile.length)];
      cardsToDistribute.add(card);
      pile.remove(card);
    }

    return cardsToDistribute;
  }

  List<Card> getAllCards() {
    return CardColor.values
        .map((color) =>
        CardHead.values.map((head) => Card(color, head)).toList())
        .reduce((list1, list2) => list1..addAll(list2));
  }
}
