import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class Turn extends Equatable {
  final int number;
  Player firstPlayer;
  Map<Player, Decision> playerDecisions = Map();

  Turn(this.number, this.firstPlayer);

  @override
  List<Object> get props => [number, firstPlayer, playerDecisions];

  @override
  String toString() {
    return 'Turn{number: $number, firstPlayer: $firstPlayer, playerDecisions: $playerDecisions}';
  }
}