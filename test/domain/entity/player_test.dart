import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Player', () {
    group('sortCards', () {
      test('when no trump color', () {
        var cards = [
          Card(CardColor.Heart, CardHead.Ace),
          Card(CardColor.Heart, CardHead.Ten),
          Card(CardColor.Heart, CardHead.King),
          Card(CardColor.Heart, CardHead.Queen),
          Card(CardColor.Heart, CardHead.Jack),
          Card(CardColor.Heart, CardHead.Nine),
          Card(CardColor.Heart, CardHead.Eight),
          Card(CardColor.Heart, CardHead.Seven),
        ];
        var player = Player(Position.Right)
          ..cards = (cards.toList()
            ..shuffle());
        expect(player.cards, isNot(cards));

        player.sortCards();

        expect(player.cards, cards);
      });
    });

    group('sortCards', () {
      test('when trump color', () {
        var cards = [
          Card(CardColor.Heart, CardHead.Ace),
          Card(CardColor.Heart, CardHead.Ten),
          Card(CardColor.Heart, CardHead.King),
          Card(CardColor.Heart, CardHead.Queen),
          Card(CardColor.Heart, CardHead.Jack),
          Card(CardColor.Heart, CardHead.Nine),
          Card(CardColor.Heart, CardHead.Eight),
          Card(CardColor.Heart, CardHead.Seven),
          Card(CardColor.Spade, CardHead.Jack),
          Card(CardColor.Spade, CardHead.Nine),
          Card(CardColor.Spade, CardHead.Ace),
          Card(CardColor.Spade, CardHead.Ten),
          Card(CardColor.Spade, CardHead.King),
          Card(CardColor.Spade, CardHead.Queen),
          Card(CardColor.Spade, CardHead.Eight),
          Card(CardColor.Spade, CardHead.Seven),
        ];
        var player = Player(Position.Right)
          ..cards = (cards.toList()
            ..shuffle());
        expect(player.cards, isNot(cards));

        player.sortCards(trumpColor: CardColor.Spade);

        expect(player.cards, cards);
      });
    });
  });
}
