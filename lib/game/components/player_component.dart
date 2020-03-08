import 'dart:ui';

import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/components/text_box_component.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';

import 'card_component.dart';

class PassedCaption extends TextBoxComponent {
  bool visible = false;

  PassedCaption() : super('Passed   ', config: TextConfig(fontSize: 18)) {
    anchor = Anchor.bottomRight;
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  @override
  void drawBackground(Canvas c) {
    final Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
  }
}

class PlayerComponent extends PositionComponent
    with HasGameRef, Tapable, Resizable, ComposedComponent {
  final Player player;
  final List<CardComponent> cards;
  final Position position;
  final bool isRealPlayer;
  CardComponent lastPlayedCard;
  bool isDown = false;
  PassedCaption _passedCaption;
  bool _shouldDestroy = false;

  set passed(bool newPassed) => _passedCaption.visible = newPassed;

  PlayerComponent(this.player, this.cards, this.position, this.isRealPlayer,
      this.lastPlayedCard) {
    _passedCaption = PassedCaption();
    this.cards.forEach((card) => add(card));
    if (this.lastPlayedCard != null) {
      add(this.lastPlayedCard);
    }
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

    super.resize(size);
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

  static PlayerComponent fromDomainPlayer(Player player) {
    return PlayerComponent(
      player,
      [],
      player.position,
      player.isRealPlayer,
      null,
    );
  }

  static PlayerComponent fromPlayer(
    Player player, {
    bool passed = false,
    Function onCardSelected,
    Card lastPlayed,
    List<Card> possibleCardsToPlay,
  }) {
    List<CardComponent> cards = player.cards
        .map((card) => CardComponent.fromCard(
              card,
              showBackFace: !player.isRealPlayer,
              onCardPlayed: player.isRealPlayer && onCardSelected != null
                  ? () => onCardSelected(card)
                  : null,
            )..canBePlayed = possibleCardsToPlay == null
                ? true
                : possibleCardsToPlay.contains(card))
        .toList()
        .cast();
    return PlayerComponent(
      player,
      cards,
      player.position,
      player.isRealPlayer,
      lastPlayed == null ? null : CardComponent.fromCard(lastPlayed),
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
}
