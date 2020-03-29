import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

abstract class TakeOrPassEvent extends Equatable {
  const TakeOrPassEvent();

  @override
  List<Object> get props => [];
}

class RealPlayerTurn extends TakeOrPassEvent {
  final Player player;
  final Card card;

  RealPlayerTurn(this.player, this.card);

  @override
  List<Object> get props => [player, card];

  @override
  String toString() {
    return 'RealPlayerTurn{player: $player, card: $card}';
  }
}

class Take extends TakeOrPassEvent {
  final Player player;
  final CardColor color;

  Take(this.player, this.color);

  @override
  List<Object> get props => [this.player, this.color];

  @override
  String toString() {
    return 'Take{player: $player, color: $color}';
  }
}

class Pass extends TakeOrPassEvent {
  final Player player;

  Pass(this.player);

  @override
  List<Object> get props => [this.player];

  @override
  String toString() {
    return 'Pass{player: $player}';
  }
}