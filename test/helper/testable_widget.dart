import 'package:atoupic/application/ui/application_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'mock_definition.dart';

Widget buildTestableWidget(
  Widget widget,
{bool showTakeOrPassDialog = false}
) {
  Mocks.setupMockStore(
    showTakeOrPassDialog: showTakeOrPassDialog,
  );

  return MediaQuery(
    data: MediaQueryData(),
    child: StoreProvider<ApplicationState>(
      store: Mocks.store,
      child: MaterialApp(home: Scaffold(body: widget)),
    ),
  );
}
