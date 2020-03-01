import 'package:atoupic/application/domain/entity/card.dart' as AtoupicCard;
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/ui/application_state.dart';
import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(
  Widget widget, {
  bool showTakeOrPassDialog = false,
  AtoupicView currentView = AtoupicView.Home,
  AtoupicCard.Card takeOrPassCard,
  Player realPlayer,
      int turn = 1,
}) {
  Mocks.setupMockStore(
    showTakeOrPassDialog: showTakeOrPassDialog,
    currentView: currentView,
    takeOrPassCard: takeOrPassCard,
    realPlayer: realPlayer,
    turn: turn,
  );

  return MediaQuery(
    data: MediaQueryData(),
    child: StoreProvider<ApplicationState>(
      store: Mocks.store,
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
}
