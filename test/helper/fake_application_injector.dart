import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:mockito/mockito.dart';

import 'mock_definition.dart';

void setupDependencyInjectorForTest() {
  final container = kiwi.Container();
  container.registerInstance(Mocks.atoupicGame);
  container.registerInstance(Mocks.store);
  container.registerInstance(Mocks.cardService);
  container.registerInstance(Mocks.playerService);
  container.registerInstance(Mocks.gameService);
  container.registerInstance(Mocks.gameContextRepository);

  when(Mocks.atoupicGame.widget).thenReturn(Scaffold());
}