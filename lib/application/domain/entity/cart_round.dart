import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:equatable/equatable.dart';

class CartRound extends Equatable {
  final Map<Position, Card> playedCards = Map();
  final Player firstPlayer;

  CartRound(this.firstPlayer);

  @override
  List<Object> get props => [playedCards, firstPlayer];
}
