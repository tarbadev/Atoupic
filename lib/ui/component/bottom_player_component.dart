import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';
import 'package:flutter/gestures.dart';

class BottomPlayerComponent extends PlayerComponent {
  BottomPlayerComponent(Player player) : super(player);

  @override
  void resizePlayerName(Size size) {
    if (cards.isNotEmpty) {
      playerName
        ..anchor = Anchor.bottomLeft
        ..x = cards.last.x + (cards.last.width / 2) + PlayerComponent.margin
        ..y = size.height - ((size.height - (cards.last.y - (cards.last.height / 2))) / 2);
    } else {
      playerName
        ..anchor = Anchor.bottomCenter
        ..x = size.width / 2
        ..y = size.height - PlayerComponent.margin - playerName.height;
    }
  }

  @override
  void resizePlayerDialog(Size size) {
    if (playerDialog != null) {
      playerDialog
        ..anchor = Anchor.topLeft
        ..x = playerName.x
        ..y = playerName.y + 5;
    }
  }

  @override
  void resizeTrumpColor(Size size) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = Anchor.bottomLeft
        ..x = (playerName.x + playerName.width)
        ..y = playerName.y;
    }
  }

  @override
  void resizeCardDeck(Size size) {
    final tileSize = size.width / 9;
    final cardWidth = tileSize * 1.25;
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
      card.setWidthAndHeightFromTileSize(tileSize);
      card.x = initialX + (card.width * .25 * index);
      card.y = size.height - (card.height * .25);
      card.fullyDisplayed = index == cards.length - 1;
      card.playedCardTarget = playedCardTarget;
    });
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
