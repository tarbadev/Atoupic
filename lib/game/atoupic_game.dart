import 'dart:ui';

import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/game/components/background.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class AtoupicGame extends BaseGame {
  Background _background;
  bool visible = false;
  int _turn = 1;
  TextComponent _turnComponent;

  AtoupicGame() {
    _background = Background(0xFF079992);

    TextConfig regular = TextConfig(color: BasicPalette.white.color);
    _turnComponent = TextComponent('Turn $_turn', config: regular)
      ..x = 10
      ..y = 5
      ..anchor = Anchor.topLeft;

    add(_background);
    add(_turnComponent);
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
