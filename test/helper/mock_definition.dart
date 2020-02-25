import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/application/repository/game_context_repository.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:mockito/mockito.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}

class MockCardService extends Mock implements CardService {}
class MockPlayerService extends Mock implements PlayerService {}
class MockGameService extends Mock implements GameService {}
class MockGameContextRepository extends Mock implements GameContextRepository {}
class MockGameContext extends Mock implements GameContext {}

class Mocks {
  static final AtoupicGame atoupicGame = MockAtoupicGame();
  static final CardService cardService = MockCardService();
  static final PlayerService playerService = MockPlayerService();
  static final GameService gameService = MockGameService();
  static final GameContextRepository gameContextRepository = MockGameContextRepository();
}
