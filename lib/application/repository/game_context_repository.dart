import 'package:atoupic/application/domain/entity/game_context.dart';

class GameContextRepository {
  GameContext gameContext;

  GameContext save(GameContext gameContext) {
    this.gameContext = gameContext;

    return this.gameContext;
  }

  GameContext read() => this.gameContext;
}
