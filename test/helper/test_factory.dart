import 'package:atoupic/application/domain/entity/turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/cart_round.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/entity/turn_result.dart';
import 'package:atoupic/application/domain/service/game_service.dart';

abstract class TestFactory {
  static List<Card> get cards => [
        Card(CardColor.Spade, CardHead.Seven),
        Card(CardColor.Spade, CardHead.Eight),
        Card(CardColor.Spade, CardHead.Nine),
        Card(CardColor.Spade, CardHead.Ten),
        Card(CardColor.Spade, CardHead.Jack),
        Card(CardColor.Spade, CardHead.Queen),
        Card(CardColor.Spade, CardHead.King),
        Card(CardColor.Spade, CardHead.Ace),
        Card(CardColor.Heart, CardHead.Seven),
        Card(CardColor.Heart, CardHead.Eight),
        Card(CardColor.Heart, CardHead.Nine),
        Card(CardColor.Heart, CardHead.Ten),
        Card(CardColor.Heart, CardHead.Jack),
        Card(CardColor.Heart, CardHead.Queen),
        Card(CardColor.Heart, CardHead.King),
        Card(CardColor.Heart, CardHead.Ace),
        Card(CardColor.Club, CardHead.Seven),
        Card(CardColor.Club, CardHead.Eight),
        Card(CardColor.Club, CardHead.Nine),
        Card(CardColor.Club, CardHead.Ten),
        Card(CardColor.Club, CardHead.Jack),
        Card(CardColor.Club, CardHead.Queen),
        Card(CardColor.Club, CardHead.King),
        Card(CardColor.Club, CardHead.Ace),
        Card(CardColor.Diamond, CardHead.Seven),
        Card(CardColor.Diamond, CardHead.Eight),
        Card(CardColor.Diamond, CardHead.Nine),
        Card(CardColor.Diamond, CardHead.Ten),
        Card(CardColor.Diamond, CardHead.Jack),
        Card(CardColor.Diamond, CardHead.Queen),
        Card(CardColor.Diamond, CardHead.King),
        Card(CardColor.Diamond, CardHead.Ace),
      ];

  static Player get realPlayer => Player(Position.Bottom, isRealPlayer: true);

  static Player get computerPlayer => Player(Position.Top);

  static Player realPlayerWithCards(List<Card> cards) =>
      Player(Position.Bottom, isRealPlayer: true)..cards = cards;

  static TurnResult get turnResult => TurnResult(Player(Position.Left), 102, 50, Result.Success, 102, 50);

  static GameContext get gameContext => GameContext([
        Player(Position.Left),
        Player(Position.Top),
        Player(Position.Right),
        realPlayer
      ], [
        Turn(1, Player(Position.Top))
      ]);

  static GameContext get finishedTurnGameContext =>
      gameContext
        ..lastTurn.playerDecisions[Position.Top] = Decision.Take
        ..lastTurn.card = Card(CardColor.Spade, CardHead.Ten)
        ..lastTurn.trumpColor = CardColor.Spade
        ..lastTurn.cardRounds = fullGamePlayed;

  static List<CartRound> get fullGamePlayed => [
        CartRound(Player(Position.Top))
          ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Jack)
          ..playedCards[Position.Right] = Card(CardColor.Spade, CardHead.King)
          ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
          ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
        CartRound(Player(Position.Top))
          ..playedCards[Position.Top] = Card(CardColor.Spade, CardHead.Nine)
          ..playedCards[Position.Right] = Card(CardColor.Club, CardHead.Eight)
          ..playedCards[Position.Bottom] = Card(CardColor.Spade, CardHead.Ace)
          ..playedCards[Position.Left] = Card(CardColor.Spade, CardHead.Seven),
      ];
}
