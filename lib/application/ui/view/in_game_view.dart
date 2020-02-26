import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class InGameView extends StatelessWidget {
  GameContext gameContext;

  GameService _gameService;
  CardService _cardService;
  AtoupicGame _atoupicGame;

  InGameView() {
    var container = kiwi.Container();
    _gameService = container.resolve<GameService>();
    _atoupicGame = container.resolve();
    _cardService = container.resolve();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('InGame__Container'),
      backgroundColor: Colors.transparent,
    );
  }

  void startSoloGame() {
    gameContext = _gameService.startSoloGame();

    _setPlayersInGame();

    _atoupicGame.visible = true;

    takeOrPass();
  }

  void _setPlayersInGame() {
    _atoupicGame.setPlayers(gameContext.players
        .map((player) => PlayerComponent.fromPlayer(
              player,
              passed: gameContext.turns.last.playerDecisions[player] ==
                  Decision.Pass,
            ))
        .toList());
  }

  void takeOrPass() {
    _cardService.distributeCards(1).first;

    _proposeCardToPlayer(gameContext.nextPlayer());
  }

  void _proposeCardToPlayer(Player player) {
    if (player.isRealPlayer) {
    } else {
      onTakeOrPassDecision(gameContext.nextPlayer(), Decision.Pass);
    }
  }

  onTakeOrPassDecision(Player player, Decision decision) {
    var newGameContext = gameContext.setDecision(player, decision);
    gameContext = _gameService.save(newGameContext);

    _setPlayersInGame();

    _nextAction();
  }

  void _nextAction() {
    _proposeCardToPlayer(gameContext.nextPlayer());
  }
}
