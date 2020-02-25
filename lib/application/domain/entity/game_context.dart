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
    return _nextPlayer(1);

  }

  Player _nextPlayer(int count) {
    var lastTurnFirstPlayer = turns.last.firstPlayer;
    var index = players.indexOf(lastTurnFirstPlayer) + count;

    if (index == players.length) {
      index = 0;
    }

    var player = players[index];

    if (turns.last.playerDecisions[player] != null) {
      player = _nextPlayer(count + 1);
    }

    return player;
  }
}