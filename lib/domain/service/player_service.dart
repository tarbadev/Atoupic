import 'package:atoupic/domain/entity/player.dart';

class PlayerService {
  Player buildRealPlayer() {
    return Player(Position.Bottom, 'Player', isRealPlayer: true);
  }

  Player buildComputerPlayer(Position position, String name) {
    return Player(position, name);
  }
}
