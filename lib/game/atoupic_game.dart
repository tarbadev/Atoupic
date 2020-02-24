import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class AtoupicGame extends BaseGame {
  bool visible = false;

  AtoupicGame() {
    TextConfig regular = TextConfig(color: BasicPalette.white.color);
    add(TextComponent('In game', config: regular)
      ..x = 200
      ..y = 200
      ..anchor = Anchor.center);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }
}
