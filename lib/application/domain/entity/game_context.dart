import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:equatable/equatable.dart';

class GameContext extends Equatable {
  final List<Player> players;
  List<Turn> turns;

  Turn get lastTurn => turns.last;

  GameContext(this.players, this.turns);

  @override
  List<Object> get props => [players, turns];

  @override
  String toString() {
    return 'GameContext{players: $players, turns: $turns}';
  }

  GameContext setDecision(Player player, Decision decision) {
    lastTurn.playerDecisions[player.position] = decision;
    return this;
  }

  Player nextPlayer() {
    if (lastTurn.playerDecisions.length == players.length) {
      return null;
    }
    final lastTurnFirstPlayer = lastTurn.firstPlayer;
    var index =
        players.indexOf(lastTurnFirstPlayer) + lastTurn.playerDecisions.length;

    if (index >= players.length) {
      index -= 4;
    }

    return players[index];
  }

  GameContext nextRound() {
    lastTurn.round = 2;
    lastTurn.playerDecisions.clear();
    return this;
  }

  GameContext nextTurn() {
    var firstPlayerIndex = players.indexOf(lastTurn.firstPlayer) + 1;
    if (firstPlayerIndex == players.length) {
      firstPlayerIndex = 0;
    }

    var firstPlayer = players[firstPlayerIndex];
    turns.add(Turn(lastTurn.number + 1, firstPlayer));
    return this;
  }

  GameContext setCardDecision(Card card, Player player) {
    lastTurn.lastCardRound[player.position] = card;
    players.firstWhere((p) => p.position == player.position).cards.remove(card);

    return this;
  }

  GameContext newCardRound() {
    lastTurn.cardRounds.add(Map());
    return this;
  }
}
