import 'package:flame/anchor.dart';
import 'package:flame/components/text_component.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';

class AtoupicGame extends BaseGame {

  AtoupicGame(){
    TextConfig regular = TextConfig(color: BasicPalette.white.color);
    add(TextComponent('In game', config: regular)
      ..x = 20
      ..y = 20
      ..anchor = Anchor.topRight
    );
  }
}