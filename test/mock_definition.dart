import 'package:atoupic/game/atoupic_game.dart';
import 'package:mockito/mockito.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}

class Mocks {
  static final AtoupicGame atoupicGame = MockAtoupicGame();
}
