import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class NewTurn extends GameEvent {
  final bool turnAlreadyCreated;

  NewTurn({this.turnAlreadyCreated = false});

  @override
  List<Object> get props => [turnAlreadyCreated];
}

class DisplayPlayerPassedCaption extends GameEvent {
  final Position position;

  DisplayPlayerPassedCaption(this.position);

  @override
  List<Object> get props => [position];
}

class DisplayPlayerTookCaption extends GameEvent {
  final Position position;

  DisplayPlayerTookCaption(this.position);

  @override
  List<Object> get props => [position];
}

class ResetPlayersCaption extends GameEvent {}

class DisplayTrumpColor extends GameEvent {
  final CardColor color;
  final Position takerPosition;

  DisplayTrumpColor(this.color, this.takerPosition);

  @override
  List<Object> get props => [color, takerPosition];
}

class AddPlayerCards extends GameEvent {
  final List<Card> cards;
  final Position position;

  AddPlayerCards(this.cards, this.position);

  @override
  List<Object> get props => [cards, position];
}

class ReplaceRealPlayersCards extends GameEvent {
  final List<Card> cards;

  ReplaceRealPlayersCards(this.cards);

  @override
  List<Object> get props => [cards];
}

class RealPlayerCanChooseCard extends GameEvent {
  final List<Card> cards;

  RealPlayerCanChooseCard(this.cards);

  @override
  List<Object> get props => [cards];
}

class StartSoloGame extends GameEvent {}
class NewCardRound extends GameEvent {}
class EndCardRound extends GameEvent {}
class EndGame extends GameEvent {}

class PlayCardForAi extends GameEvent {
  final Player player;
  final List<Card> possibleCardsToPlay;

  PlayCardForAi(this.player, this.possibleCardsToPlay);

  @override
  List<Object> get props => [player, possibleCardsToPlay];
}

class PlayCard extends GameEvent {
  final Card card;
  final Player player;

  PlayCard(this.card, this.player);

  @override
  List<Object> get props => [player, card];
}
