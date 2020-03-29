import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:atoupic/ui/application_middleware.dart';
import 'package:atoupic/ui/application_reducer.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';
import 'package:redux/redux.dart';

part 'application_injector.g.dart';

abstract class ApplicationInjector {
  void configure() {
    configureAnnotations();
    configureInstances();
  }

  @Register.singleton(AtoupicGame)
  @Register.singleton(CardService)
  @Register.factory(PlayerService)
  @Register.factory(GameService)
  @Register.factory(AiService)
  @Register.singleton(GameContextRepository)
  @Register.singleton(GameBloc)
  @Register.singleton(AppBloc)
  @Register.singleton(CurrentTurnBloc)
  @Register.singleton(TakeOrPassBloc)
  void configureAnnotations();

  void configureInstances() {
    final _store = Store<ApplicationState>(
      applicationReducer,
      initialState: ApplicationState.initial(),
      middleware: createApplicationMiddleware(),
    );
    final Container container = Container();
    container.registerInstance(_store);
  }
}

ApplicationInjector getApplicationInjector() => _$ApplicationInjector();
