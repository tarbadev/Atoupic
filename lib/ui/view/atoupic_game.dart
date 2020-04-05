import 'dart:ui';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/card_component.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/game.dart';
import 'package:kiwi/kiwi.dart';

class AtoupicGame extends BaseGame {
  bool visible = false;
  List<PlayerComponent> _players = List();
  PlayerComponent _realPlayer;

  @override
  Color backgroundColor() => Color(0xFF079992);

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  void setDomainPlayers(List<Player> players) {
    if (_players.isNotEmpty) {
      _players.forEach((playerComponent) => playerComponent.setToDestroy());
      _players.clear();
    }
    players.map((player) => PlayerComponent.fromPlayer(player)).forEach((player) {
      if (player.isRealPlayer) {
        _realPlayer = player;
      }
      _players.add(player);
      add(player);
    });
  }

  void setPlayerPassed(Position position) {
    _players.firstWhere((player) => player.position == position).passed = true;
  }

  void addPlayerCards(List<Card> cards, Position position) {
    var playerComponent = _players.firstWhere((player) => player.position == position);
    _addPlayerCards(playerComponent, cards);
  }

  void _addPlayerCards(PlayerComponent playerComponent, List<Card> cards) {
    playerComponent.addCards(cards
        .map((card) => CardComponent.fromCard(card, showBackFace: !playerComponent.isRealPlayer))
        .toList());
    playerComponent.resize(size);
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }

  void resetPlayersPassed() {
    _players.forEach((player) => player.passed = false);
  }

  void replaceRealPlayersCards(List<Card> cards) {
    _resetPlayerCards(_realPlayer);
    _addPlayerCards(_realPlayer, cards);
  }

  void realPlayerCanChooseCard(bool canChooseCard, {List<Card> possiblePlayableCards}) {
    if (canChooseCard) {
      final container = Container();
      final GameBloc gameBloc = container.resolve();
      _realPlayer.setCardsOnTapCallback(
          (card) => gameBloc.add(PlayCard(card, _realPlayer.player)));
      _realPlayer.cards.forEach((cardComponent) =>
          cardComponent.canBePlayed = possiblePlayableCards.contains(cardComponent.card));
    } else {
      _realPlayer.cards.forEach((cardComponent) {
        cardComponent.canBePlayed = false;
        cardComponent.onCardPlayed = null;
      });
    }
  }

  void setLastCardPlayed(Card card, Position position, Function onAnimationDoneCallback) {
    var playerComponent = _players.firstWhere((player) => player.position == position);
    var playedCard =
        playerComponent.cards.firstWhere((cardComponent) => cardComponent.card == card);
    playerComponent.playCard(playedCard, onAnimationDoneCallback);
  }

  void resetLastPlayedCards() {
    _players.forEach((player) {
      player.lastPlayedCard.shouldDestroy = true;
      player.lastPlayedCard = null;
      player.resize(size);
    });
  }

  void setTrumpColor(CardColor color, Position position) {
    var playerComponent = _players.firstWhere((player) => player.position == position);
    playerComponent.displayTrumpColor(color);
    resize(size);
  }
  
  void resetPlayersCards() {
    _players.forEach((player) => _resetPlayerCards(player));
  }

  void _resetPlayerCards(PlayerComponent player) {
    player.cards.forEach((card) {
        card.shouldDestroy = true;
      });
    player.cards.clear();
  }

  void resetTrumpColor() {
    _players.forEach((player) => player.resetTrumpColor());
  }
}
