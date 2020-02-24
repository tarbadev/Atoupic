import 'package:atoupic/game/atoupic_game.dart';
import 'package:kiwi/kiwi.dart';

part 'application_injector.g.dart';

abstract class ApplicationInjector {
  void configure() {
    configureAnnotations();
  }

  @Register.singleton(AtoupicGame)
  void configureAnnotations();
}

ApplicationInjector getApplicationInjector() => _$ApplicationInjector();
