import 'dart:math';

import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:kiwi/kiwi.dart';

enum Decision { Pass, Take }

class GameService {
  final GameContextRepository _gameContextRepository;
  final CardService _cardService;

  GameService(this._gameContextRepository, this._cardService);

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

  GameContext read() => _gameContextRepository.read();

  GameContext startTurn(bool turnAlreadyCreated) {
    GameContext gameContext = turnAlreadyCreated
        ? _gameContextRepository.read()
        : _gameContextRepository.read().nextTurn();

    _cardService.initializeCards();

    gameContext.players.forEach((player) => player.cards = _cardService.distributeCards(5));
    gameContext.players.firstWhere((player) => player.isRealPlayer).sortCards();

    gameContext.lastTurn.card = _cardService.distributeCards(1).single;

    return _gameContextRepository.save(gameContext);
  }
}
