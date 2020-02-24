import 'dart:ui';

import 'package:atoupic/application/domain/entity/player.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';

import 'card_component.dart';

class PlayerComponent extends PositionComponent
    with HasGameRef, Tapable, Resizable, ComposedComponent {
  final List<CardComponent> cards;
  final Position position;
  final bool isRealPlayer;

  PlayerComponent(this.cards, this.position, this.isRealPlayer) {
    this.cards.forEach((card) => add(card));
  }

  @override
  void resize(Size size) {
    cards.forEach((card) => card.setWidthAndHeightFromTileSize(size.width / 9));

    double cardHeight = cards.first.height;
    double fullDeckWidth = cards.first.width * .25 * (cards.length - 1) + cards.first.width;
    double initialX = 0;
    double initialY = 0;
    double cardX = 0;
    double cardY = 0;
    double cardAngle = 0;

    double rotation = 1.5708;

    if (position == Position.Bottom) {
      initialX = (size.width / 2) - (fullDeckWidth / 2);
      cardY = size.height - (cardHeight * .75);
    } else if (position == Position.Top) {
      initialX = (size.width / 2) - (fullDeckWidth / 2) + cards.first.width;
      cardY = cardHeight * .25;
      cardAngle = rotation * 2;
    } else if (position == Position.Left) {
      cardX = cardHeight * .25;
      initialY = (size.height / 2) - (fullDeckWidth / 2);
      cardAngle = rotation;
    } else if (position == Position.Right) {
      cardX = size.width - cardHeight * .25;
      initialY = (size.height / 2) - (fullDeckWidth / 2) + cards.first.width;
      cardAngle = -rotation;
    }

    cards.asMap().forEach((index, card) {
      if (position == Position.Top || position == Position.Bottom) {
        cardX = initialX + (cards.first.width * .25 * index);
      } else {
        cardY = initialY + (cards.first.width * .25 * index);
      }

      card.x = cardX;
      card.y = cardY;
      card.angle = cardAngle;
    });
    super.resize(size);
  }

  static PlayerComponent fromPlayer(Player player) {
    List<CardComponent> cards = player.cards.map((card) => CardComponent.fromCard(card)).toList().cast();
    return PlayerComponent(
      cards,
      player.position,
      player.isRealPlayer,
    );
  }
}