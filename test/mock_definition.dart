import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:mockito/mockito.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}

class MockCardService extends Mock implements CardService {}
class MockPlayerService extends Mock implements PlayerService {}

class Mocks {
  static final AtoupicGame atoupicGame = MockAtoupicGame();
  static final CardService cardService = MockCardService();
  static final PlayerService playerService = MockPlayerService();
}
