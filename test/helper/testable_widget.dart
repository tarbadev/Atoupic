import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/entity/turn.dart';
import 'package:atoupic/application/domain/entity/turn_result.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(
  Widget widget, {
  bool showTakeOrPassDialog = false,
  AtoupicView currentView = AtoupicView.Home,
  Player realPlayer,
  Turn currentTurn,
  TurnResult turnResult,
  int usScore,
  int themScore,
}) {
  Mocks.setupMockStore(
    showTakeOrPassDialog: showTakeOrPassDialog,
    currentView: currentView,
    realPlayer: realPlayer,
    currentTurn: currentTurn,
    turnResult: turnResult,
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
