import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final int number;
  final Player firstPlayer;
  Card card;
  Map<Position, Decision> playerDecisions = Map();
  List<Map<Position, Card>> cardRounds = List();
  int round = 1;

  Map<Position, Card> get lastCardRound => cardRounds.length > 0 ? cardRounds.last : null;

  Turn(this.number, this.firstPlayer);

  @override
  List<Object> get props =>
      [number, card, firstPlayer, playerDecisions, round, cardRounds];

  @override
  String toString() {
    return 'Turn{number: $number, firstPlayer: $firstPlayer, card: $card, playerDecisions: $playerDecisions, cardRounds: $cardRounds, round: $round}';
  }
}
