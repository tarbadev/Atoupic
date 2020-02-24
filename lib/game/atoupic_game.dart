import 'dart:ui';

import 'package:atoupic/application/domain/entity/player.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class AtoupicGame extends BaseGame {
  bool visible = false;

  AtoupicGame() {
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  setPlayers(List<Player> players) {}
}
