import 'package:atoupic/domain/service/card_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helper/test_factory.dart';

void main() {
  group('CardService', () {
    CardService cardService;

    setUp(() {
      cardService = CardService();
    });

    test('initializes pile on initialize', () {
      cardService.initializeCards();

      expect(cardService.pile.length, 32);
      expect(cardService.pile, TestFactory.cards);
    });

    test(
        'distributeCards returns the number of cards specified and removes them from the pile',
        () {
      var cards = cardService.distributeCards(10);

      expect(cardService.pile.length, 22);
      cards.forEach((card) => expect(cardService.pile.contains(card), isFalse));
    });
  });
}
