import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/card_component.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';

class TopPlayerComponent extends PlayerComponent {
  TopPlayerComponent(Player player) : super(player);

  @override
  void resizePlayerName(Size size) {
    playerName
      ..anchor = Anchor.topCenter
      ..x = size.width / 2
      ..y = PlayerComponent.margin;
  }

  @override
  void resizePlayerDialog(Size size) {
    if (playerDialog != null) {
      playerDialog
        ..anchor = Anchor.topCenter
        ..x = size.width / 2
        ..y = (playerName.height + playerName.y) + 5;
    }
  }

  @override
  void resizeTrumpColor(Size size) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = Anchor.topLeft
        ..x = playerName.x + (playerName.width / 2)
        ..y = playerName.y;
    }
  }

  @override
  void resizeCardDeck(Size size) {
    final tileSize = size.width / 9;
    final rotation = 1.5708;
    final cardWidth = tileSize * 1.25;
    final fullDeckWidth = cardWidth * .25 * (cards.length - 1) + cardWidth;
    final initialX = (size.width / 2) - (fullDeckWidth / 2) + (cardWidth / 2);

    cards.asMap().forEach((index, card) {
      card.setWidthAndHeightFromTileSize(tileSize);
      card.x = initialX + (card.width * .25 * index);
      card.y = -(card.height * .25);
      card.angle = rotation * 2;
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
      midWidth,
      midHeight - PlayerComponent.playedCardDistance,
      width,
      height,
    );
  }
}
