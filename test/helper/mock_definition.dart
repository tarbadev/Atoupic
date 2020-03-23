import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/entity/game_context.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:atoupic/ui/entity/score_display.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}
class MockTurn extends Mock implements Turn {}

class MockCardService extends Mock implements CardService {}

class MockPlayerService extends Mock implements PlayerService {}

class MockGameService extends Mock implements GameService {}
class MockAiService extends Mock implements AiService {}

class MockGameContextRepository extends Mock implements GameContextRepository {}

class MockGameContext extends Mock implements GameContext {}

class MockPlayer extends Mock implements Player {}
class MockGameBloc extends Mock implements GameBloc {}

class MockStore extends Mock implements Store<ApplicationState> {}

class MockApplicationState extends Mock implements ApplicationState {}

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
  static final Store<ApplicationState> store = MockStore();
  static final GameContextRepository gameContextRepository =
      MockGameContextRepository();
  static final ApplicationState applicationState = MockApplicationState();
  static final MockNext mockNext = MockNext();
  static final NextDispatcher next = (dynamic action) => mockNext.next(action);

  static setupMockStore({
    bool showTakeOrPassDialog: false,
    AtoupicView currentView = AtoupicView.Home,
    Player realPlayer,
    Turn currentTurn,
    int usScore = 42,
    int themScore = 120,
  }) {
    reset(store);
    reset(applicationState);

    if (currentTurn == null) {
      currentTurn = Turn(1, MockPlayer());
    }

    when(store.state).thenReturn(applicationState);
    when(store.onChange).thenAnswer((_) => Stream.empty());
    when(applicationState.showTakeOrPassDialog)
        .thenReturn(showTakeOrPassDialog);
    when(applicationState.currentView).thenReturn(currentView);
    when(applicationState.realPlayer).thenReturn(realPlayer);
    when(applicationState.currentTurn).thenReturn(currentTurn);
    when(applicationState.score).thenReturn(ScoreDisplay(usScore, themScore));
  }
}
