import 'package:atoupic/ui/application_bloc_delegate.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:mockito/mockito.dart';

import 'mock_definition.dart';

void setupDependencyInjectorForTest() {
  final container = kiwi.Container();
  container.registerInstance(Mocks.atoupicGame);
  container.registerInstance(Mocks.cardService);
  container.registerInstance(Mocks.playerService);
  container.registerInstance(Mocks.gameService);
  container.registerInstance(Mocks.aiService);
  container.registerInstance(Mocks.gameBloc);
  container.registerInstance(Mocks.appBloc);
  container.registerInstance(Mocks.currentTurnBloc);
  container.registerInstance(Mocks.takeOrPassDialogBloc);
  container.registerInstance(Mocks.gameContextRepository);
  container.registerInstance(ApplicationBlocDelegate(Mocks.gameBloc, Mocks.takeOrPassDialogBloc, Mocks.errorReporter));

  when(Mocks.atoupicGame.widget).thenReturn(Scaffold());
}
