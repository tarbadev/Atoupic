import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/game/components/card_component.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class AtoupicGame extends BaseGame with HasWidgetsOverlay {
  bool visible = false;
  int _turn = 1;
  TextComponent _turnComponent;
  List<PlayerComponent> _players = List();
  PlayerComponent _currentPlayer;
  CardComponent _takeOrPassCard;

  AtoupicGame() {
    TextConfig regular = TextConfig(color: BasicPalette.white.color);
    _turnComponent = TextComponent('Turn $_turn', config: regular)
      ..x = 10
      ..y = 5
      ..anchor = Anchor.topLeft;

    add(_turnComponent);
  }

  @override
  Color backgroundColor() => Color(0xFF079992);

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  setPlayers(List<Player> players) {
    players.forEach((player) {
      var playerComponent = PlayerComponent.fromPlayer(player);
      _players.add(playerComponent);
      add(playerComponent);
    });
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }

  setCurrentPlayer(Player player, Function onTakeOrPassDecision) {
    _currentPlayer = _players.firstWhere(
        (playerComponent) => player.position == playerComponent.position);

    if (_currentPlayer.isRealPlayer) {
      print('Current player!');
    } else {
      _currentPlayer.displayPassed();
      onTakeOrPassDecision(player, Decision.Pass);
    }
  }

  setTakeOrPassCard(AtoupicCard.Card card) {
    _takeOrPassCard = CardComponent.fromCard(card);
  }
}
