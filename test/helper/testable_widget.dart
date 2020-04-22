import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(Widget widget) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Mocks.gameBloc),
        BlocProvider(create: (_) => Mocks.appBloc),
        BlocProvider(create: (_) => Mocks.currentTurnBloc),
        BlocProvider(create: (_) => Mocks.takeOrPassBloc),
      ],
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
}
