import 'dart:ui';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/destroyable.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

class CardComponent extends SpriteComponent with Resizable, Tapable, Destroyable {
  final int animationDuration = 500;
  String _spriteFileName;
  final Card card;
  Function onCardPlayed;
  final Paint maskPaint = Paint()..color = Color(0x88000000);
  bool fullyDisplayed = false;
  bool canBePlayed = false;
  bool animatePlayedCard = false;
  DateTime animateStart;
  Rect playedCardTarget;
  double tileSize;
  Offset destinationOffset;

  Function onAnimationDoneCallback;

  CardComponent(this._spriteFileName, this.onCardPlayed, this.card) {
    sprite = Sprite(_spriteFileName);
    anchor = Anchor.center;
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
        (playedCardTarget.left - currentRect.left - (width / 2)) * differencePercent,
        (playedCardTarget.top - currentRect.top - (height / 2)) * differencePercent,
      );
      Rect newRect = currentRect.shift(toTarget);

      x = newRect.left + (width / 2);
      y = newRect.top + (height / 2);
      width -= (width - playedCardTarget.width) * differencePercent;
      height -= (height - playedCardTarget.height) * differencePercent;

      if ((x == playedCardTarget.left &&
              y == playedCardTarget.top &&
              width == playedCardTarget.width &&
              height == playedCardTarget.height) ||
          differencePercent == 1) {
        animatePlayedCard = false;
        onAnimationDoneCallback();
      }
    }

    if (destinationOffset != null) {
      var speed = tileSize * 6;
      double stepDistance = speed * t;
      Rect currentRect = super.toRect();
      Offset toTarget = destinationOffset - Offset(currentRect.left, currentRect.top);
      if (stepDistance < toTarget.distance) {
        Offset stepToTarget = Offset.fromDirection(toTarget.direction, stepDistance);
        currentRect = currentRect.shift(stepToTarget);
      } else {
        currentRect = currentRect.shift(toTarget);
        destinationOffset = null;
        onAnimationDoneCallback();
      }

      x = currentRect.left + (width / 2);
      y = currentRect.top + (height / 2);
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
      showBackFace ? 'cards/BackFace.png' : 'cards/${card.color.folder}/${card.head.fileName}',
      onCardPlayed,
      card,
    );
  }

  void animateToCenter(Function onAnimationEnd) {
    onAnimationDoneCallback = onAnimationEnd;
    destinationOffset = Offset(
      size.width / 2 - (width / 2),
      size.height / 2 - (height),
    );
  }

  void animateToWinnerPile(Position winner, Function onAnimationEnd) {
    onAnimationDoneCallback = onAnimationEnd;
    switch (winner) {
      case Position.Top:
        destinationOffset = Offset(size.width / 2 - (width / 2), -height);
        break;
      case Position.Bottom:
        destinationOffset = Offset(size.width / 2 - (width / 2), size.height + height);
        break;
      case Position.Left:
        destinationOffset = Offset(-width, size.height / 2 - (height / 2));
        break;
      case Position.Right:
        destinationOffset = Offset(size.width + width, size.height / 2 - (height / 2));
        break;
    }
  }
}
