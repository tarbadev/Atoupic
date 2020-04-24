import 'dart:convert' show json;

import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/domain/service/ai_service.dart';
import 'package:atoupic/domain/service/card_service.dart';
import 'package:atoupic/domain/service/game_service.dart';
import 'package:atoupic/domain/service/player_service.dart';
import 'package:atoupic/repository/game_context_repository.dart';
import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:atoupic/ui/error_reporter.dart';
import 'package:atoupic/ui/view/atoupic_game.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kiwi/kiwi.dart';
import 'package:platform/platform.dart';
import 'package:sentry/sentry.dart';

import 'entity/Secrets.dart';

part 'application_injector.g.dart';


abstract class ApplicationInjector {
  bool get _isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Future configure() async {
    final secretsJson = json.decode(await rootBundle.loadString('assets/secrets.json'));
    final secrets = Secrets.map(secretsJson);
    final sentry = new SentryClient(dsn: secrets.sentryDsn);

    final Platform platform = LocalPlatform();

    var container = Container();
    container.registerSingleton((c) => secrets);
    container.registerSingleton((c) => ErrorReporter(sentry, platform, _isInDebugMode));

    configureAnnotations();
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
  @Register.singleton(DeclarationsBloc)
  @Register.singleton(ApplicationBlocDelegate)
  void configureAnnotations();
}

ApplicationInjector getApplicationInjector() => _$ApplicationInjector();
