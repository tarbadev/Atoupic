import 'package:atoupic/bloc/bloc.dart';
import 'package:atoupic/ui/view/home_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/testable_widget.dart';
import '../tester/home_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  group('HomeView', () {
    testWidgets('dispatches a SetCurrentViewAction on startSolo tap',
        (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);

      await tester.pumpWidget(buildTestableWidget(HomeView()));

      verifyZeroInteractions(Mocks.gameBloc);

      await homeViewTester.tapOnSolo();
      verify(Mocks.gameBloc.add(StartSoloGame()));
    });
  });
}
