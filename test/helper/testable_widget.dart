import 'package:atoupic/domain/entity/player.dart';
import 'package:atoupic/domain/entity/turn.dart';
import 'package:atoupic/ui/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(
  Widget widget, {
  bool showTakeOrPassDialog = false,
  Player realPlayer,
  Turn currentTurn,
  int usScore = 42,
  int themScore = 120,
}) {
  Mocks.setupMockStore(
    showTakeOrPassDialog: showTakeOrPassDialog,
    realPlayer: realPlayer,
    currentTurn: currentTurn,
    usScore: usScore,
    themScore: themScore,
  );

  return MediaQuery(
    data: MediaQueryData(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Mocks.gameBloc),
        BlocProvider(create: (_) => Mocks.appBloc),
        BlocProvider(create: (_) => Mocks.currentTurnBloc),
        BlocProvider(create: (_) => Mocks.takeOrPassDialogBloc),
      ],
      child: StoreProvider<ApplicationState>(
        store: Mocks.store,
        child: MaterialApp(home: Scaffold(body: widget)),
      ),
    ),
  );
}
