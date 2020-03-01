import 'dart:math';

import 'package:atoupic/application/domain/entity/card.dart';

class CardService {
  List<Card> pile = [];
  Random _random;

  CardService() {
    _random = Random();
    initializeCards();
  }

  initializeCards() {
    pile = [
      Card(CardColor.Spade, CardHead.Seven),
      Card(CardColor.Spade, CardHead.Eight),
      Card(CardColor.Spade, CardHead.Nine),
      Card(CardColor.Spade, CardHead.Ten),
      Card(CardColor.Spade, CardHead.Jack),
      Card(CardColor.Spade, CardHead.Queen),
      Card(CardColor.Spade, CardHead.King),
      Card(CardColor.Spade, CardHead.Ace),
      Card(CardColor.Heart, CardHead.Seven),
      Card(CardColor.Heart, CardHead.Eight),
      Card(CardColor.Heart, CardHead.Nine),
      Card(CardColor.Heart, CardHead.Ten),
      Card(CardColor.Heart, CardHead.Jack),
      Card(CardColor.Heart, CardHead.Queen),
      Card(CardColor.Heart, CardHead.King),
      Card(CardColor.Heart, CardHead.Ace),
      Card(CardColor.Diamond, CardHead.Seven),
      Card(CardColor.Diamond, CardHead.Eight),
      Card(CardColor.Diamond, CardHead.Nine),
      Card(CardColor.Diamond, CardHead.Ten),
      Card(CardColor.Diamond, CardHead.Jack),
      Card(CardColor.Diamond, CardHead.Queen),
      Card(CardColor.Diamond, CardHead.King),
      Card(CardColor.Diamond, CardHead.Ace),
      Card(CardColor.Club, CardHead.Seven),
      Card(CardColor.Club, CardHead.Eight),
      Card(CardColor.Club, CardHead.Nine),
      Card(CardColor.Club, CardHead.Ten),
      Card(CardColor.Club, CardHead.Jack),
      Card(CardColor.Club, CardHead.Queen),
      Card(CardColor.Club, CardHead.King),
      Card(CardColor.Club, CardHead.Ace),
    ];
  }

  List<Card> distributeCards(int count) {
    List<Card> cardsToDistribute = List();

    for(int i = 0; i < count; i++) {
      var card = pile[_random.nextInt(pile.length)];
      cardsToDistribute.add(card);
      pile.remove(card);
    }

    return cardsToDistribute;
  }
}
