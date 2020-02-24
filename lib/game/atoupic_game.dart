import 'dart:ui';

import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/game/components/background.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flame/game.dart';

class AtoupicGame extends BaseGame {
  Background _background;
  bool visible = false;

  AtoupicGame() {
    _background = Background(0xFF079992);

    add(_background);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  setPlayers(List<Player> players) {
    players.forEach((player) => add(PlayerComponent.fromPlayer(player)));
  }

  @override
  void resize(Size size) {
    _background.width = size.width;
    _background.height = size.height;

    super.resize(size);
  }
}
