import 'dart:ui';

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/ui/component/carpet_component.dart';
import 'package:atoupic/ui/component/player_component.dart';
import 'package:flame/game.dart';
import 'package:kiwi/kiwi.dart';

class AtoupicGame extends BaseGame {
  final CarpetComponent _carpetComponent = CarpetComponent();
  bool visible = false;
  List<PlayerComponent> _players = List();
  PlayerComponent _realPlayer;

  AtoupicGame() {
    add(_carpetComponent);
  }

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
    players.forEach((player) {
      final playerComponent = PlayerComponent.fromPlayer(player);
      if (player.isRealPlayer) {
        _realPlayer = playerComponent;
      }
      _players.add(playerComponent);
      add(playerComponent);
    });
  }

  void setPlayerDialogText(Position position, String text) {
    _getPlayerFromPosition(position).displayDialog(text);
  }

  void addPlayerCards(List<Card> cards, Position position) {
    _addPlayerCards(_getPlayerFromPosition(position), cards);
  }

  void _addPlayerCards(PlayerComponent playerComponent, List<Card> cards) {
    playerComponent.addCards(cards);
  }

  void resetPlayersDialog() {
    _players.forEach((player) => player.hideDialog());
  }

  void replaceRealPlayersCards(List<Card> cards) {
    _resetPlayerCards(_realPlayer);
    _addPlayerCards(_realPlayer, cards);
  }

  void realPlayerCanChooseCard(bool canChooseCard, {List<Card> possiblePlayableCards}) {
    if (canChooseCard) {
      final container = Container();
      final GameBloc gameBloc = container.resolve();
      _realPlayer.setCardsOnTapCallback((card) => gameBloc.add(PlayCard(card, _realPlayer.player)));
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
    var playerComponent = _getPlayerFromPosition(position);
    var playedCard =
        playerComponent.cards.firstWhere((cardComponent) => cardComponent.card == card);

    playerComponent.playCard(playedCard);
    _carpetComponent.add(playedCard);

    playedCard.angle = 0;
    playedCard.fullyDisplayed = true;
    playedCard.animateStart = DateTime.now();
    playedCard.destinationRect = playerComponent.getPlayedCardRect(size, getCenterRect());
    playedCard.onAnimationDoneCallback = onAnimationDoneCallback;
    playedCard.revealCard();
  }

  void removePlayedCardsToWinnerPile(Position winner, Function onAnimationEnd) async {
    resize(size);
    _carpetComponent.cleanUpCarpetToWinner(winner, onAnimationEnd, getCenterContentOffset());
  }

  void setTrumpColor(CardColor color, Position position) {
    var playerComponent = _getPlayerFromPosition(position);
    playerComponent.displayTrumpColor(color);
  }

  void resetPlayersCards() {
    _players.forEach((player) => _resetPlayerCards(player));
  }

  void _resetPlayerCards(PlayerComponent player) {
    player.cards.forEach((card) {
      card.setToDestroy();
    });
    player.cards.clear();
  }

  void resetTrumpColor() {
    _players.forEach((player) => player.hideTrumpColor());
  }

  PlayerComponent _getPlayerFromPosition(Position position) {
    return _players.firstWhere(
        (player) => player.runtimeType == PlayerComponent.positionToPlayerType[position]);
  }

  Rect getCenterRect() {
    var leftPlayer = _getPlayerFromPosition(Position.Left);
    var topPlayer = _getPlayerFromPosition(Position.Top);
    var rightPlayer = _getPlayerFromPosition(Position.Right);
    var bottomPlayer = _realPlayer;

    final left = leftPlayer.playerName.x + leftPlayer.playerName.width - 10;
    final top = topPlayer.playerName.y + (topPlayer.playerName.height * 2) - 5;
    final right = rightPlayer.playerName.x - rightPlayer.playerName.width;
    final bottom = bottomPlayer.cards.isEmpty
        ? 0
        : (bottomPlayer.cards.first.y - (bottomPlayer.cards.first.height / 2));

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Offset getCenterContentOffset() {
    final centerRect = getCenterRect();
    return Offset(
      centerRect.left + ((centerRect.right - centerRect.left) / 2),
      centerRect.top + ((centerRect.bottom - centerRect.top) / 2),
    );
  }
}
