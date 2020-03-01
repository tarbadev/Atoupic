import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/application/repository/game_context_repository.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';

class MockAtoupicGame extends Mock implements AtoupicGame {}
class MockCardService extends Mock implements CardService {}
class MockPlayerService extends Mock implements PlayerService {}
class MockGameService extends Mock implements GameService {}
class MockGameContextRepository extends Mock implements GameContextRepository {}
class MockGameContext extends Mock implements GameContext {}
class MockPlayer extends Mock implements Player {}
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
  static final Store<ApplicationState> store = MockStore();
  static final GameContextRepository gameContextRepository =
      MockGameContextRepository();
  static final ApplicationState applicationState = MockApplicationState();
  static final MockNext mockNext = MockNext();
  static final NextDispatcher next = (dynamic action) => mockNext.next(action);

  static setupMockStore({
    bool showTakeOrPassDialog: false,
    AtoupicView currentView = AtoupicView.Home,
    Card takeOrPassCard,
    Player realPlayer,
    int turn = 1,
  }) {
    reset(store);
    reset(applicationState);

    final gameContext = GameContext([], [Turn(turn, MockPlayer())..card = takeOrPassCard]);

    when(store.state).thenReturn(applicationState);
    when(store.onChange).thenAnswer((_) => Stream.empty());
    when(applicationState.showTakeOrPassDialog)
        .thenReturn(showTakeOrPassDialog);
    when(applicationState.currentView).thenReturn(currentView);
    when(applicationState.realPlayer).thenReturn(realPlayer);
    when(applicationState.gameContext).thenReturn(gameContext);
  }
}
