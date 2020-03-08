import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

class CardComponent extends SpriteComponent with Resizable, Tapable {
  String _spriteFileName;
  final Card card;
  Function onCardPlayed;
  final Paint maskPaint = Paint()..color = Color(0x88000000);
  bool fullyDisplayed = false;
  bool canBePlayed = false;
  bool shouldDestroy = false;

  @override
  Rect toRect() {
    var fullRect = super.toRect();
    var width = fullyDisplayed ? fullRect.width : fullRect.width * .25;
    return Rect.fromLTWH(fullRect.left, fullRect.top, width, fullRect.height);
  }

  @override
  bool destroy() {
    return shouldDestroy;
  }

  CardComponent(this._spriteFileName, this.onCardPlayed, this.card) {
    sprite = Sprite(_spriteFileName);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.restore();
    if (onCardPlayed != null && !canBePlayed) {
      var fullRect = toRect();
      var rect = Rect.fromLTWH(
        fullRect.left,
        fullRect.top + 1,
        width - 1,
        fullRect.height - 2,
      );
      canvas.drawRect(rect, maskPaint);
    }
  }

  void setWidthAndHeightFromTileSize(double tileSize) {
    width = tileSize * 1.25;
    height = tileSize * 1.25 * 1.39444;
  }

  static CardComponent fromCard(
    Card card, {
    bool showBackFace = false,
    Function onCardPlayed,
  }) {
    return CardComponent(
      showBackFace
          ? 'cards/BackFace.png'
          : 'cards/${card.color.folder}/${card.head.fileName}',
      onCardPlayed,
      card,
    );
  }

  @override
  void onTapUp(TapUpDetails details) {
    if (onCardPlayed != null && canBePlayed) {
      onCardPlayed();
    }
  }

  void revealCard() {
    if (_spriteFileName == 'cards/BackFace.png') {
      _spriteFileName = 'cards/${card.color.folder}/${card.head.fileName}';
      sprite = Sprite(_spriteFileName);
    }
  }
}
