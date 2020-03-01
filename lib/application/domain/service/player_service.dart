import 'package:atoupic/application/domain/entity/player.dart';
import 'package:kiwi/kiwi.dart';

import 'card_service.dart';

class PlayerService {
  Player buildRealPlayer() {
    return Player(Position.Bottom, isRealPlayer: true);
  }

  Player buildComputerPlayer(Position position) {
    return Player(position);
  }
}