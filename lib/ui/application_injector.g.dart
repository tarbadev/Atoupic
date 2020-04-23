// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_injector.dart';

// **************************************************************************
// InjectorGenerator
// **************************************************************************

class _$ApplicationInjector extends ApplicationInjector {
  void configureAnnotations() {
    final Container container = Container();
    container.registerSingleton((c) => AtoupicGame());
    container.registerSingleton((c) => CardService());
    container.registerFactory((c) => PlayerService());
    container.registerFactory((c) => GameService(
        c<GameContextRepository>(), c<CardService>(), c<PlayerService>()));
    container.registerFactory((c) => AiService(c<CardService>()));
    container.registerSingleton((c) => GameContextRepository());
    container.registerSingleton((c) => GameBloc(
        c<AtoupicGame>(), c<AppBloc>(), c<GameService>(), c<AiService>()));
    container.registerSingleton((c) => AppBloc());
    container.registerSingleton((c) => CurrentTurnBloc(c<GameBloc>()));
    container.registerSingleton((c) => TakeOrPassBloc(
        c<GameBloc>(), c<GameService>(), c<CardService>(), c<AiService>()));
    container.registerSingleton((c) => ApplicationBlocDelegate(
        c<GameBloc>(), c<TakeOrPassBloc>(), c<ErrorReporter>()));
  }
}
