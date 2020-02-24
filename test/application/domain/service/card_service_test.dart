import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_factory.dart';

void main() {
  group('CardService', () {
    CardService cardService;

    setUp(() {
      cardService = CardService();
    });

    test('initializeCards sets the cards to default', () {
      expect(cardService.cards, isEmpty);

      cardService.initializeCards();

      expect(listEquals(cardService.cards, TestFactory.cards), isTrue);
    });
  });
}
