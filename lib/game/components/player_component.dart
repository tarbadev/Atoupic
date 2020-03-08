import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/game/components/passed_caption.dart';
import 'package:atoupic/game/components/trump_color.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flutter/gestures.dart';

import 'card_component.dart';

class PlayerComponent extends PositionComponent
    with HasGameRef, Tapable, Resizable, ComposedComponent {
  final Player player;
  final List<CardComponent> cards = List();
  final Position position;
  final bool isRealPlayer;
  CardComponent lastPlayedCard;
  bool isDown = false;
  PassedCaption _passedCaption;
  bool _shouldDestroy = false;
  TrumpColor _trumpColor;

  set passed(bool newPassed) => _passedCaption.visible = newPassed;

  PlayerComponent(this.player, this.position, this.isRealPlayer) {
    _passedCaption = PassedCaption();
    add(_passedCaption);
  }

  void setToDestroy() {
    _shouldDestroy = true;
  }

  @override
  bool destroy() {
    return _shouldDestroy;
  }

  @override
  void resize(Size size) {
    var tileSize = size.width / 9;
    cards.forEach((card) => card.setWidthAndHeightFromTileSize(tileSize));

    double cardWidth = tileSize * 1.25;
    double cardHeight = tileSize * 1.25 * 1.39444;
    double fullDeckWidth = cardWidth * .25 * (cards.length - 1) + cardWidth;
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
      initialX = (size.width / 2) - (fullDeckWidth / 2) + cardWidth;
      cardY = cardHeight * .25;
      cardAngle = rotation * 2;
    } else if (position == Position.Left) {
      cardX = cardHeight * .25;
      initialY = (size.height / 2) - (fullDeckWidth / 2);
      cardAngle = rotation;
    } else if (position == Position.Right) {
      cardX = size.width - cardHeight * .25;
      initialY = (size.height / 2) - (fullDeckWidth / 2) + cardWidth;
      cardAngle = -rotation;
    }

    cards.asMap().forEach((index, card) {
      if (position == Position.Top || position == Position.Bottom) {
        cardX = initialX + (cardWidth * .25 * index);
      } else {
        cardY = initialY + (cardWidth * .25 * index);
      }

      card.x = cardX;
      card.y = cardY;
      card.angle = cardAngle;
      card.fullyDisplayed = index == cards.length - 1;
    });

    _resizeLastPlayedCard(tileSize, size);
    _resizeTrumpColor(cardX, initialX, size, cardY, fullDeckWidth, cardWidth);
    _resizePassedCaption(cardX, cardY, cardHeight, fullDeckWidth, cardWidth);

    super.resize(size);
  }

  void _resizePassedCaption(double cardX, double cardY, double cardHeight, double fullDeckWidth, double cardWidth) {
    if (position == Position.Top) {
      _passedCaption
        ..anchor = Anchor.bottomLeft
        ..x = cardX
        ..y = cardY;
    } else if (position == Position.Left) {
      _passedCaption
        ..anchor = Anchor.bottomLeft
        ..x = cardX - cardHeight * .25
        ..y = cardY - (fullDeckWidth - cardWidth);
    } else if (position == Position.Right) {
      _passedCaption
        ..x = cardX + cardHeight * .25
        ..y = cardY - fullDeckWidth;
    }
  }

  void _resizeTrumpColor(
    double cardX,
    double initialX,
    Size size,
    double cardY,
    double fullDeckWidth,
    double cardWidth,
  ) {
    if (_trumpColor != null) {
      switch (position) {
        case Position.Top:
          _trumpColor
            ..anchor = Anchor.topLeft
            ..x = cardX + 10
            ..y = 0;
          break;
        case Position.Bottom:
          _trumpColor
            ..anchor = Anchor.bottomRight
            ..x = initialX - 10
            ..y = size.height;
          break;
        case Position.Left:
          _trumpColor
            ..anchor = Anchor.bottomLeft
            ..x = 0
            ..y = cardY - (fullDeckWidth - cardWidth) - 10;
          break;
        case Position.Right:
          _trumpColor
            ..anchor = Anchor.bottomRight
            ..x = size.width
            ..y = cardY - fullDeckWidth - 10;
          break;
      }
    }
  }

  void _resizeLastPlayedCard(double tileSize, Size size) {
    if (lastPlayedCard != null) {
      lastPlayedCard.setWidthAndHeightFromTileSize(tileSize * .75);
      lastPlayedCard.angle = 0;
      switch (position) {
        case Position.Top:
          lastPlayedCard.x = (size.width / 2) - (lastPlayedCard.width / 2);
          lastPlayedCard.y =
              (size.height / 2) - (lastPlayedCard.height * 1.5) - 10;
          break;
        case Position.Bottom:
          lastPlayedCard.x = (size.width / 2) - (lastPlayedCard.width / 2);
          lastPlayedCard.y =
              (size.height / 2) - (lastPlayedCard.height * .5) + 10;
          break;
        case Position.Left:
          lastPlayedCard.x = (size.width / 2) - (lastPlayedCard.width * 2);
          lastPlayedCard.y = (size.height / 2) - lastPlayedCard.height;
          break;
        case Position.Right:
          lastPlayedCard.x = (size.width / 2) + lastPlayedCard.width;
          lastPlayedCard.y = (size.height / 2) - lastPlayedCard.height;
          break;
      }
    }
  }

  static PlayerComponent fromPlayer(Player player) {
    return PlayerComponent(
      player,
      player.position,
      player.isRealPlayer,
    );
  }

  @override
  void handleTapUp(TapUpDetails details) {
    if (isRealPlayer && isDown) {
      isDown = false;
      super.handleTapUp(details);
    }
  }

  @override
  void handleTapDown(TapDownDetails details) {
    if (isRealPlayer && !isDown) {
      isDown = true;
      super.handleTapDown(details);
    }
  }

  void addCards(List<CardComponent> newCards) {
    cards.addAll(newCards);
    newCards.forEach((newCard) => add(newCard));
  }

  void setCardsOnTapCallback(Function(Card card) callback) {
    cards.forEach((card) => card.onCardPlayed = () => callback(card.card));
  }

  void displayTrumpColor(CardColor color) {
    _trumpColor = TrumpColor(color);
    add(_trumpColor);
  }
}
