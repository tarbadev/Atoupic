import 'package:equatable/equatable.dart';

enum CardColor { Spade, Heart, Club, Diamond }

extension ColorExtension on CardColor {
  String get folder {
    return '${this.toString().toLowerCase().replaceFirst('cardcolor.', '')}s';
  }

  String get symbol {
    switch (this) {
      case CardColor.Spade:
        return '♠';
      case CardColor.Heart:
        return '♥';
      case CardColor.Club:
        return '♣';
      case CardColor.Diamond:
        return '♦';
      default:
        return '';
    }
  }
}

enum CardHead {
  Seven,
  Eight,
  Nine,
  Ten,
  Jack,
  Queen,
  King,
  Ace,
}

extension CardHeadExtension on CardHead {
  String get fileName {
    switch (this) {
      case CardHead.Seven:
        return '7.png';
      case CardHead.Eight:
        return '8.png';
      case CardHead.Nine:
        return '9.png';
      case CardHead.Ten:
        return '10.png';
      case CardHead.Jack:
        return 'J.png';
      case CardHead.Queen:
        return 'Q.png';
      case CardHead.King:
        return 'K.png';
      case CardHead.Ace:
        return 'A.png';
      default:
        return '';
    }
  }

  int get order {
    switch (this) {
      case CardHead.Seven:
        return 0;
      case CardHead.Eight:
        return 1;
      case CardHead.Nine:
        return 2;
      case CardHead.Jack:
        return 3;
      case CardHead.Queen:
        return 4;
      case CardHead.King:
        return 5;
      case CardHead.Ten:
        return 6;
      case CardHead.Ace:
        return 7;
      default:
        return 0;
    }
  }
}

class Card extends Equatable {
  final CardColor color;
  final CardHead head;

  Card(this.color, this.head);

  @override
  List<Object> get props => [color, head];

  @override
  String toString() {
    return 'Card{color: $color, head: $head}';
  }
}
