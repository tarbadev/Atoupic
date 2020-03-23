import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class Start extends GameEvent {
  final List<Player> players;

  Start(this.players);

  @override
  List<Object> get props => [players];

  @override
  String toString() => 'Start{players: $players}';
}

class NewTurn extends GameEvent {
  final List<Player> players;

  NewTurn(this.players);

  @override
  List<Object> get props => [players];

  @override
  String toString() => 'NewTurn{players: $players}';
}

class DisplayPlayerPassedCaption extends GameEvent {
  final Position position;

  DisplayPlayerPassedCaption(this.position);

  @override
  List<Object> get props => [position];

  @override
  String toString() => 'DisplayPlayerPassedCaption{position: $position}';
}

class ResetPlayersPassedCaption extends GameEvent {}

class DisplayTrumpColor extends GameEvent {
  final CardColor color;
  final Position takerPosition;

  DisplayTrumpColor(this.color, this.takerPosition);

  @override
  List<Object> get props => [color, takerPosition];

  @override
  String toString() => 'DisplayTrumpColor{color: $color, taker: $takerPosition}';
}

class AddPlayerCards extends GameEvent {
  final List<Card> cards;
  final Position position;

  AddPlayerCards(this.cards, this.position);

  @override
  List<Object> get props => [cards, position];

  @override
  String toString() => 'AddPlayerCards{cards: $cards, position: $position}';
}

class ReplaceRealPlayersCards extends GameEvent {
  final List<Card> cards;

  ReplaceRealPlayersCards(this.cards);

  @override
  List<Object> get props => [cards];

  @override
  String toString() => 'ReplaceRealPlayersCards{cards: $cards}';
}

class RealPlayerCanChooseCard extends GameEvent {
  final List<Card> cards;

  RealPlayerCanChooseCard(this.cards);

  @override
  List<Object> get props => [cards];

  @override
  String toString() => 'RealPlayerCanChooseCard{cards: $cards}';
}

class SetPlayedCard extends GameEvent {
  final Card card;
  final Position position;
  final Function onCardPlayed;

  SetPlayedCard(this.card, this.position, this.onCardPlayed);

  @override
  List<Object> get props => [card, position, onCardPlayed];

  @override
  String toString() {
    return 'SetPlayedCard{card: $card, position: $position, onCardPlayed: $onCardPlayed}';
  }
}

class ResetLastPlayedCards extends GameEvent {}
