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
  final List<CardComponent> cards;
  final Position position;
  final bool isRealPlayer;
  final bool passed;
  final CardComponent lastPlayedCard;
  bool isDown = false;
  PassedCaption _passedCaption;
  bool shouldDestroy = false;

  PlayerComponent(this.cards, this.position, this.isRealPlayer, this.passed,
      this.lastPlayedCard) {
    _passedCaption = PassedCaption();
    _passedCaption.visible = this.passed;
    this.cards.forEach((card) => add(card));
    if(this.lastPlayedCard != null) {
      add(this.lastPlayedCard);
    }
    add(_passedCaption);
  }

  @override
  bool destroy() {
    return shouldDestroy;
  }

  @override
  void resize(Size size) {
    var tileSize = size.width / 9;
    cards.forEach((card) => card.setWidthAndHeightFromTileSize(tileSize));

    double cardHeight = cards.first.height;
    double fullDeckWidth =
        cards.first.width * .25 * (cards.length - 1) + cards.first.width;
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
      card.fullyDisplayed = index == cards.length - 1;
    });

    if (lastPlayedCard != null) {
      lastPlayedCard.setWidthAndHeightFromTileSize(tileSize * .75);
      lastPlayedCard.x = size.width / 2 - (lastPlayedCard.width / 2);
      lastPlayedCard.y = size.height - (cardHeight * .85) - lastPlayedCard.height;
    }

    if (position == Position.Top) {
      _passedCaption
        ..anchor = Anchor.bottomLeft
        ..x = cards.last.x
        ..y = cards.first.y;
    } else if (position == Position.Left) {
      _passedCaption
        ..anchor = Anchor.bottomLeft
        ..x = cards.first.x - cards.first.height * .25
        ..y = cards.first.y;
    } else if (position == Position.Right) {
      _passedCaption
        ..x = cards.first.x + cards.first.height * .25
        ..y = cards.first.y - cards.first.width;
    }

    super.resize(size);
  }

  static PlayerComponent fromPlayer(Player player,
      {bool passed = false, Function onCardSelected, Card lastPlayed}) {
    List<CardComponent> cards = player.cards
        .map((card) => CardComponent.fromCard(card,
            showBackFace: !player.isRealPlayer,
            onCardPlayed: () => onCardSelected(card)))
        .toList()
        .cast();
    return PlayerComponent(
      cards,
      player.position,
      player.isRealPlayer,
      passed,
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
}
