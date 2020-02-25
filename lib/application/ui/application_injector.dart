import 'package:atoupic/application/domain/service/card_service.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/domain/service/player_service.dart';
import 'package:atoupic/application/repository/game_context_repository.dart';
import 'package:atoupic/game/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';

part 'application_injector.g.dart';

abstract class ApplicationInjector {
  void configure() {
    configureAnnotations();
  }

  @Register.singleton(AtoupicGame)
  @Register.singleton(CardService)
  @Register.factory(PlayerService)
  @Register.factory(GameService)
  @Register.singleton(GameContextRepository)
  void configureAnnotations();
}

ApplicationInjector getApplicationInjector() => _$ApplicationInjector();
