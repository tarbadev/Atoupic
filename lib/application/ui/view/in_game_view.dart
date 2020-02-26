import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/game/atoupic_game.dart';
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
    gameContext = _gameService.startSoloGame();

    _atoupicGame.setPlayers(gameContext.players);

    var card = _cardService.distributeCards(1).first;
    _atoupicGame.setCurrentPlayer(gameContext.turns[0].firstPlayer, onTakeOrPassDecision);

    _atoupicGame.visible = true;
  }

  onTakeOrPassDecision(Player player, Decision decision) {
    var newGameContext = gameContext.setDecision(player, decision);
    _gameService.save(newGameContext);
    _atoupicGame.setCurrentPlayer(newGameContext.nextPlayer(), onTakeOrPassDecision);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('InGame__Container'),
      backgroundColor: Colors.transparent,
    );
  }
}
