import 'package:atoupic/ui/application_actions.dart';
import 'package:atoupic/ui/view/home_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/mock_definition.dart';
import '../../helper/testable_widget.dart';
import '../../home_view_tester.dart';

void main() {
  group('HomeView', () {
    testWidgets('dispatches a SetCurrentViewAction on startSolo tap',
        (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);

      await tester.pumpWidget(buildTestableWidget(HomeView()));

      await homeViewTester.tapOnSolo();
      verify(Mocks.store.dispatch(StartSoloGameAction()));
    });
  });
}
