import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';

class AiService {
  Card chooseCard(List<Card> cards, Turn turn, bool isVertical) {
    return cards.reduce((card1, card2) => card1.head.order < card2.head.order ? card1 : card2);
  }
}