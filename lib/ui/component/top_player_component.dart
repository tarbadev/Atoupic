import 'dart:ui';

import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/anchor.dart';

class TopPlayerComponent extends PlayerComponent {
  TopPlayerComponent(Player player) : super(player, false, player.name);

  @override
  void resizePlayerName(Size size) {
    playerName
      ..anchor = Anchor.topCenter
      ..x = size.width / 2
      ..y = 10;
  }

  @override
  void resizePlayerDialog(Size size) {
    if (playerDialog != null) {
      playerDialog
        ..anchor = Anchor.topCenter
        ..x = size.width / 2
        ..y = 10;
    }
  }

  @override
  void resizeTrumpColor(
    Size size,
    double firstCardX,
    double cardWidth,
  ) {
    if (trumpColor != null) {
      trumpColor
        ..anchor = Anchor.topLeft
        ..x = playerName.x + (playerName.width / 2)
        ..y = playerName.y;
    }
  }

  @override
  double resizeCardDeck(Size size) {
    final tileSize = size.width / 9;
    final rotation = 1.5708;
    final cardWidth = tileSize * 1.25;
    final cardHeight = tileSize * 1.25 * 1.39444;
    final fullDeckWidth = cardWidth * .25 * (cards.length - 1) + cardWidth;
    final initialX = (size.width / 2) - (fullDeckWidth / 2) + (cardWidth / 2);

    final playedCardWidth = tileSize * .75 * 1.25;
    final playedCardHeight = tileSize * .75 * 1.25 * 1.39444;
    Rect playedCardTarget = Rect.fromLTWH(
      (size.width / 2),
      (size.height / 2) - (playedCardHeight) - 10,
      playedCardWidth,
      playedCardHeight,
    );

    cards.asMap().forEach((index, card) {
      card.x = initialX + (cardWidth * .25 * index);
      card.y = -(cardHeight * .25);
      card.angle = rotation * 2;
      card.fullyDisplayed = index == cards.length - 1;
      card.playedCardTarget = playedCardTarget;
    });
    return initialX;
  }
}
