import 'dart:math';

import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/application/repository/game_context_repository.dart';
import 'package:kiwi/kiwi.dart';

enum Decision { Pass, Take }

class GameService {
  final GameContextRepository _gameContextRepository;

  GameService(this._gameContextRepository);

  GameContext startSoloGame() {
    PlayerService playerService = Container().resolve();
    Player realPlayer = playerService.buildRealPlayer();
    List<Player> players = [
      playerService.buildComputerPlayer(Position.Left),
      playerService.buildComputerPlayer(Position.Top),
      playerService.buildComputerPlayer(Position.Right),
      realPlayer
    ];

    var firstPlayer = players[Random().nextInt(players.length)];

    var gameContext = GameContext(players, [Turn(1, firstPlayer)]);
    _gameContextRepository.save(gameContext);

    return gameContext;
  }

  GameContext save(GameContext gameContext) => _gameContextRepository.save(gameContext);
}
