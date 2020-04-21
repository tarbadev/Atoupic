import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';
import 'package:flutter/gestures.dart';

class BottomPlayerComponent extends PlayerComponent {
  BottomPlayerComponent(Player player) : super(player, true, player.name);

  @override
  void resizePlayerName(Size size) {}

  @override
  void resizePlayerDialog(Size size) {}

  @override
  void resizeTrumpColor(
    Size size,
    double firstCardX,
    double cardWidth,
  ) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = Anchor.bottomRight
        ..x = firstCardX - (cardWidth / 2) - 10
        ..y = size.height;
    }
  }

  @override
  double resizeCardDeck(Size size) {
    final tileSize = size.width / 9;
    final cardWidth = tileSize * 1.25;
    final cardHeight = tileSize * 1.25 * 1.39444;
    final fullDeckWidth = cardWidth * .25 * (cards.length - 1) + cardWidth;
    final initialX = (size.width / 2) - (fullDeckWidth / 2) + (cardWidth / 2);

    final playedCardWidth = tileSize * .75 * 1.25;
    final playedCardHeight = tileSize * .75 * 1.25 * 1.39444;
    Rect playedCardTarget = Rect.fromLTWH(
      (size.width / 2),
      (size.height / 2) + 10,
      playedCardWidth,
      playedCardHeight,
    );

    cards.asMap().forEach((index, card) {
      card.x = initialX + (cardWidth * .25 * index);
      card.y = size.height - (cardHeight * .25);
      card.fullyDisplayed = index == cards.length - 1;
      card.playedCardTarget = playedCardTarget;
    });

    return initialX;
  }

  @override
  void handleTapUp(TapUpDetails details) {
    if (isDown) {
      isDown = false;
      super.handleTapUp(details);
    }
  }

  @override
  void handleTapDown(TapDownDetails details) {
    if (!isDown) {
      isDown = true;
      super.handleTapDown(details);
    }
  }
}
