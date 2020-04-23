import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/card_component.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';

class LeftPlayerComponent extends PlayerComponent {
  LeftPlayerComponent(Player player) : super(player);

  @override
  void resizePlayerName(Size size) {
    playerName
      ..anchor = Anchor.bottomLeft
      ..x = PlayerComponent.margin
      ..y = size.height / 2 - 5;
  }

  @override
  void resizePlayerDialog(Size size) {
    if (playerDialog != null) {
      playerDialog
        ..anchor = Anchor.topLeft
        ..x = PlayerComponent.margin
        ..y = size.height / 2;
    }
  }

  @override
  void resizeTrumpColor(Size size) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = playerName.anchor
        ..x = playerName.x + playerName.width
        ..y = playerName.y;
    }
  }

  @override
  void resizeCardDeck(Size size) {
    final tileSize = size.width / 9;
    final rotation = 1.5708;
    final cardWidth = tileSize * 1.25;
    final fullDeckWidth = cardWidth * .25 * (cards.length - 1) + cardWidth;
    final initialY = (size.height / 2) - (fullDeckWidth / 2) + (cardWidth / 2);

    cards.asMap().forEach((index, card) {
      card.setWidthAndHeightFromTileSize(tileSize);
      card.x = -(card.height * .25);
      card.y = initialY + (card.width * .25 * index);
      card.angle = rotation;
      card.fullyDisplayed = index == cards.length - 1;
    });
  }

  @override
  Rect getPlayedCardRect(Size size, Rect contentRect) {
    final tileSize = size.width / 9;
    final width = tileSize * .75 * 1.25;
    final height = width * CardComponent.heightFactor;
    final midHeight = contentRect.top + ((contentRect.bottom - contentRect.top) / 2);
    final midWidth = size.width / 2;

    return Rect.fromLTWH(
      midWidth - PlayerComponent.playedCardDistance,
      midHeight,
      width,
      height,
    );
  }
}
