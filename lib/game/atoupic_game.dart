import 'dart:ui';

import 'package:atoupic/game/components/player_component.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class AtoupicGame extends BaseGame {
  bool visible = false;
  List<PlayerComponent> _players = List();

  @override
  Color backgroundColor() => Color(0xFF079992);

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  void setPlayers(List<PlayerComponent> players) {
    _players.forEach((playerComponent) => playerComponent.shouldDestroy = true);
    _setPlayers(players);
  }

  void _setPlayers(List<PlayerComponent> players) {
    players.forEach((playerComponent) {
      _players.add(playerComponent);
      add(playerComponent);
    });
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }
}
