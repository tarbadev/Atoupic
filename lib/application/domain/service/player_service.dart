import 'package:atoupic/application/domain/entity/player.dart';
import 'package:kiwi/kiwi.dart';

import 'card_service.dart';

class PlayerService {
  Player buildRealPlayer() {
    var cards = Container().resolve<CardService>().distributeCards(5);
    return Player(cards, Position.Bottom, isRealPlayer: true);
  }
}