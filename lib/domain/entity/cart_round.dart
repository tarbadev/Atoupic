import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

class CardRound extends Equatable {
  final Map<Position, Card> playedCards = Map();
  final Player firstPlayer;

  CardRound(this.firstPlayer);

  @override
  List<Object> get props => [playedCards, firstPlayer];

  @override
  bool get stringify => true;

  MapEntry<Position, Card> getCardRoundWinner(CardColor trumpColor) {
    var requestedColor = playedCards[firstPlayer.position].color;
    var trumpCards = playedCards.entries.where((entry) => entry.value.color == trumpColor);
    var winner;
    if (trumpCards.isEmpty) {
      winner = playedCards.entries.where((entry) => entry.value.color == requestedColor).reduce(
          (entry1, entry2) => entry1.value.head.order > entry2.value.head.order ? entry1 : entry2);
    } else {
      winner = trumpCards.reduce((entry1, entry2) =>
          entry1.value.head.trumpOrder > entry2.value.head.trumpOrder ? entry1 : entry2);
    }
    return winner;
  }
}
