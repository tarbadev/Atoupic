import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final int number;
  final Player firstPlayer;
  Card card;
  Map<Player, Decision> playerDecisions = Map();
  int round = 1;

  Turn(this.number, this.firstPlayer);

  @override
  List<Object> get props => [number, card, firstPlayer, playerDecisions];

  @override
  String toString() {
    return 'Turn{number: $number, firstPlayer: $firstPlayer, playerDecisions: $playerDecisions}';
  }
}