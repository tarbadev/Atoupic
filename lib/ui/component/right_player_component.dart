import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';

class RightPlayerComponent extends PlayerComponent {
  RightPlayerComponent(Player player) : super(player);

  @override
  void resizePlayerName(Size size) {
    playerName
      ..anchor = Anchor.bottomRight
      ..x = size.width - PlayerComponent.margin
      ..y = size.height / 2 - 5;
  }

  @override
  void resizePlayerDialog(Size size) {
    if (playerDialog != null) {
      playerDialog
        ..anchor = Anchor.topRight
        ..x = size.width - PlayerComponent.margin
        ..y = size.height / 2;
    }
  }

  @override
  void resizeTrumpColor(Size size) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = playerName.anchor
        ..x = playerName.x - playerName.width
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

    final playedCardWidth = tileSize * .75 * 1.25;
    final playedCardHeight = tileSize * .75 * 1.25 * 1.39444;
    Rect playedCardTarget = Rect.fromLTWH(
      (size.width / 2) + (playedCardWidth * 1.5),
      (size.height / 2) - (playedCardHeight / 2),
      playedCardWidth,
      playedCardHeight,
    );

    cards.asMap().forEach((index, card) {
      card.setWidthAndHeightFromTileSize(tileSize);
      card.x = size.width + card.height * .25;
      card.y = initialY + (card.width * .25 * index);
      card.angle = -rotation;
      card.fullyDisplayed = index == cards.length - 1;
      card.playedCardTarget = playedCardTarget;
    });
  }
}
