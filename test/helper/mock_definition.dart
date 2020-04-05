import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/cart_round.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}

class MockTurn extends Mock implements Turn {}

class MockCardService extends Mock implements CardService {}

class MockPlayerService extends Mock implements PlayerService {}

class MockGameService extends Mock implements GameService {}

class MockAiService extends Mock implements AiService {}

class MockGameContextRepository extends Mock implements GameContextRepository {}

class MockGameContext extends Mock implements GameContext {}
class MockCardRound extends Mock implements CartRound {}

class MockPlayer extends Mock implements Player {}

class MockGameBloc extends MockBloc<GameEvent, GameState> implements GameBloc {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockTakeOrPassDialogBloc extends MockBloc<TakeOrPassEvent, TakeOrPassState>
    implements TakeOrPassDialogBloc {}

class MockCurrentTurnBloc extends MockBloc<CurrentTurnEvent, int> implements CurrentTurnBloc {}

abstract class MockFunction {
  next(dynamic action);
}

class MockNext extends Mock implements MockFunction {}

class Mocks {
  static final AtoupicGame atoupicGame = MockAtoupicGame();
  static final CardService cardService = MockCardService();
  static final PlayerService playerService = MockPlayerService();
  static final GameService gameService = MockGameService();
  static final AiService aiService = MockAiService();
  static final GameBloc gameBloc = MockGameBloc();
  static final AppBloc appBloc = MockAppBloc();
  static final CurrentTurnBloc currentTurnBloc = MockCurrentTurnBloc();
  static final TakeOrPassDialogBloc takeOrPassDialogBloc = MockTakeOrPassDialogBloc();
  static final GameContextRepository gameContextRepository = MockGameContextRepository();
  static final MockNext mockNext = MockNext();
}
