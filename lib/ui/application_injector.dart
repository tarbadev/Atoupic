import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';

part 'application_injector.g.dart';

abstract class ApplicationInjector {
  @Register.singleton(AtoupicGame)
  @Register.singleton(CardService)
  @Register.factory(PlayerService)
  @Register.factory(GameService)
  @Register.factory(AiService)
  @Register.singleton(GameContextRepository)
  @Register.singleton(GameBloc)
  @Register.singleton(AppBloc)
  @Register.singleton(CurrentTurnBloc)
  @Register.singleton(TakeOrPassDialogBloc)
  @Register.singleton(ApplicationBlocDelegate)
  void configure();
}

ApplicationInjector getApplicationInjector() => _$ApplicationInjector();
