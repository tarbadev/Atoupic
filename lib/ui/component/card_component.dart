import 'dart:ui';

import 'package:atoupic/domain/entity/card.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

class CardComponent extends SpriteComponent with Resizable, Tapable {
  final int animationDuration = 500;
  String _spriteFileName;
  final Card card;
  Function onCardPlayed;
  final Paint maskPaint = Paint()..color = Color(0x88000000);
  bool fullyDisplayed = false;
  bool canBePlayed = false;
  bool shouldDestroy = false;
  bool animatePlayedCard = false;
  DateTime animateStart;
  Rect playedCardTarget;
  double tileSize;

  Function onAnimationDoneCallback;

  CardComponent(this._spriteFileName, this.onCardPlayed, this.card) {
    sprite = Sprite(_spriteFileName);
  }

  @override
  bool destroy() {
    return shouldDestroy;
  }

  @override
  Rect toRect() {
    var fullRect = super.toRect();
    var width = fullyDisplayed ? fullRect.width : fullRect.width * .25;
    return Rect.fromLTWH(fullRect.left, fullRect.top, width, fullRect.height);
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

  @override
  void onTapUp(TapUpDetails details) {
    if (onCardPlayed != null && canBePlayed) {
      onCardPlayed();
    }
  }

  @override
  void update(double t) {
    super.update(t);
    if (animatePlayedCard && playedCardTarget != null) {
      int difference = DateTime.now().difference(animateStart).inMilliseconds;
      var differencePercent = difference / animationDuration;
      if (differencePercent > 1) {
        differencePercent = 1;
      }

      var currentRect = toRect();
      Offset toTarget = Offset(
        (playedCardTarget.left - currentRect.left) * differencePercent,
        (playedCardTarget.top - currentRect.top) * differencePercent,
      );
      Rect newRect = toRect().shift(toTarget);

      x = newRect.left;
      y = newRect.top;
      width -= (width - playedCardTarget.width) * differencePercent;
      height -= (height - playedCardTarget.height) * differencePercent;

      if (x == playedCardTarget.left &&
          y == playedCardTarget.top &&
          width == playedCardTarget.width &&
          height == playedCardTarget.height) {
        animatePlayedCard = false;
        onAnimationDoneCallback();
      }
    }
  }

  void setWidthAndHeightFromTileSize(double tileSize) {
    this.tileSize = tileSize;
    width = tileSize * 1.25;
    height = tileSize * 1.25 * 1.39444;
  }

  void revealCard() {
    if (_spriteFileName == 'cards/BackFace.png') {
      _spriteFileName = 'cards/${card.color.folder}/${card.head.fileName}';
      sprite = Sprite(_spriteFileName);
    }
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
}
