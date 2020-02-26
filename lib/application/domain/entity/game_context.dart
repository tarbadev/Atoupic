import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class GameContext extends Equatable {
  final List<Player> players;
  List<Turn> turns;

  GameContext(this.players, this.turns);

  @override
  List<Object> get props => [players, turns];

  @override
  String toString() {
    return 'GameContext{players: $players, turns: $turns}';
  }

  GameContext setDecision(Player player, Decision decision) {
    turns.last.playerDecisions[player] = decision;
    return this;
  }

  Player nextPlayer() {
    var lastTurnFirstPlayer = turns.last.firstPlayer;
    var index = players.indexOf(lastTurnFirstPlayer) + turns.last.playerDecisions.length;

    if (index >= players.length) {
      index -= 4;
    }

    return players[index];
  }
}