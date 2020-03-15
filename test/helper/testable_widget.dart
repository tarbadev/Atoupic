import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(
  Widget widget, {
  bool showTakeOrPassDialog = false,
  AtoupicView currentView = AtoupicView.Home,
  Player realPlayer,
  Turn currentTurn,
  int usScore,
  int themScore,
}) {
  Mocks.setupMockStore(
    showTakeOrPassDialog: showTakeOrPassDialog,
    currentView: currentView,
    realPlayer: realPlayer,
    currentTurn: currentTurn,
    usScore: usScore,
    themScore: themScore,
  );

  return MediaQuery(
    data: MediaQueryData(),
    child: StoreProvider<ApplicationState>(
      store: Mocks.store,
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
}
