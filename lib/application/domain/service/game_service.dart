import 'dart:math';

import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';

class GameService {
  startSoloGame() {
    PlayerService playerService = Container().resolve();
    AtoupicGame atoupicGame = Container().resolve();
    var realPlayer = playerService.buildRealPlayer();
    var players = [
      playerService.buildComputerPlayer(Position.Left),
      playerService.buildComputerPlayer(Position.Top),
      playerService.buildComputerPlayer(Position.Right),
      realPlayer
    ];

    atoupicGame.setPlayers(players);
    atoupicGame.setCurrentPlayer(players[Random().nextInt(players.length)], onTakeOrPassDecision);

    atoupicGame.visible = true;
  }

  onTakeOrPassDecision() {
  }
}