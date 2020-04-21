import 'dart:ui';

import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/card_component.dart';
import 'package:atoupic/ui/component/destroyable.dart';
import 'package:atoupic/ui/component/left_player_component.dart';
import 'package:atoupic/ui/component/player_dialog.dart';
import 'package:atoupic/ui/component/player_name.dart';
import 'package:atoupic/ui/component/right_player_component.dart';
import 'package:atoupic/ui/component/top_player_component.dart';
import 'package:atoupic/ui/component/trump_color.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/mixins/tapable.dart';

import 'bottom_player_component.dart';

abstract class PlayerComponent extends PositionComponent
    with HasGameRef, Tapable, Resizable, ComposedComponent, Destroyable {
  static final Map<Position, Type> positionToPlayerType = {
    Position.Top: TopPlayerComponent,
    Position.Right: RightPlayerComponent,
    Position.Bottom: BottomPlayerComponent,
    Position.Left: LeftPlayerComponent,
  };

  final Player player;
  final List<CardComponent> cards = List();
  final bool isRealPlayer;

  CardComponent lastPlayedCard;
  bool isDown = false;
  PlayerDialog playerDialog;
  TrumpColor trumpColor;
  PlayerName playerName;

  PlayerComponent(this.player, this.isRealPlayer, String name) {
    playerName = PlayerName(name);
    add(playerName);
  }

  @override
  void resize(Size size) {
    final tileSize = size.width / 9;
    final cardWidth = tileSize * 1.25;
    cards.forEach((card) => card.setWidthAndHeightFromTileSize(tileSize));

    double initialX = resizeCardDeck(size);

    resizePlayerName(size);
    resizeTrumpColor(size, initialX, cardWidth);
    resizePlayerDialog(size);

    super.resize(size);
  }

  double resizeCardDeck(Size size);

  void resizePlayerName(Size size);

  void resizePlayerDialog(Size size);

  void resizeTrumpColor(Size size, double firstCardX, double cardWidth);

  static PlayerComponent fromPlayer(Player player) {
    switch (player.position) {
      case Position.Top:
        return TopPlayerComponent(player);
      case Position.Bottom:
        return BottomPlayerComponent(player);
      case Position.Left:
        return LeftPlayerComponent(player);
      case Position.Right:
        return RightPlayerComponent(player);
      default:
        return null;
    }
  }

  void addCards(List<CardComponent> newCards) {
    cards.addAll(newCards);
    newCards.forEach((newCard) => add(newCard));

    components.remove(playerName);
    add(playerName);
  }

  void setCardsOnTapCallback(Function(Card card) callback) {
    cards.forEach((card) => card.onCardPlayed = () => callback(card.card));
  }

  void playCard(CardComponent cardToPlay, Function onAnimationDoneCallback) {
    lastPlayedCard = cardToPlay;
    cards.remove(cardToPlay);

    components.remove(cardToPlay);
    add(cardToPlay);

    cardToPlay.angle = 0;
    cardToPlay.fullyDisplayed = true;
    cardToPlay.animateStart = DateTime.now();
    cardToPlay.animatePlayedCard = true;
    cardToPlay.onAnimationDoneCallback = onAnimationDoneCallback;
    cardToPlay.revealCard();
  }

  void displayTrumpColor(CardColor color) {
    trumpColor = TrumpColor(color);
    add(trumpColor);

    resize(size);
  }

  void hideTrumpColor() {
    if (trumpColor != null) {
      components.remove(trumpColor);
      trumpColor.setToDestroy();
      trumpColor = null;
    }
  }

  void displayDialog(String text) {
    playerDialog = PlayerDialog(text);
    components.add(playerDialog);

    resizePlayerDialog(size);
  }

  void hideDialog() {
    if (playerDialog != null) {
      components.remove(playerDialog);
      playerDialog.setToDestroy();
      playerDialog = null;
    }
  }
}