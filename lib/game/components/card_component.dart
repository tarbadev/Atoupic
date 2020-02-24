import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/sprite.dart';

class CardComponent extends SpriteComponent with Resizable {
  final String _spriteFileName;

  CardComponent(this._spriteFileName) {
    sprite = Sprite(_spriteFileName);
  }

  void setWidthAndHeightFromTileSize(double tileSize) {
    width = tileSize * 1.25;
    height = tileSize * 1.25 * 1.39444;
  }

  static fromCard(Card card) {
    return CardComponent('cards/${card.color.folder}/${card.head.fileName}');
  }
}