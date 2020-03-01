import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

class CardComponent extends SpriteComponent with Resizable, Tapable {
  final String _spriteFileName;
  final Function onCardPlayed;
  bool fullyDisplayed = false;

  @override
  Rect toRect() {
    var fullRect = super.toRect();
    var width = fullyDisplayed ? fullRect.width : fullRect.width * .25;
    return Rect.fromLTWH(fullRect.left, fullRect.top, width, fullRect.height);
  }

  CardComponent(this._spriteFileName, this.onCardPlayed) {
    sprite = Sprite(_spriteFileName);
  }

  void setWidthAndHeightFromTileSize(double tileSize) {
    width = tileSize * 1.25;
    height = tileSize * 1.25 * 1.39444;
  }

  static fromCard(Card card, {bool showBackFace = false, Function onCardPlayed}) {
    return CardComponent(
      showBackFace
          ? 'cards/BackFace.png'
          : 'cards/${card.color.folder}/${card.head.fileName}',
      onCardPlayed
    );
  }

  @override
  void onTapUp(TapUpDetails details) {
    onCardPlayed();
  }
}
