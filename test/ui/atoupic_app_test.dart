import 'package:atoupic/bloc/app_state.dart';
import 'package:atoupic/ui/atoupic_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helper/fake_application_injector.dart';
import '../helper/mock_definition.dart';
import '../home_view_tester.dart';
import '../in_game_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  group('AtoupicApp', () {
    testWidgets('loads the game on startup', (WidgetTester tester) async {
      await tester.pumpWidget(AtoupicApp());

      verify(Mocks.atoupicGame.widget);
    });

    testWidgets('displays HomeView when current view is Home',
        (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);
      var inGameViewTester = InGameViewTester(tester);

      when(Mocks.appBloc.state).thenAnswer((_) => HomeAppState());

      await tester.pumpWidget(AtoupicApp());

      expect(homeViewTester.isVisible, isTrue);
      expect(inGameViewTester.isVisible, isFalse);
    });

    testWidgets('displays InGameView when current view is InGame',
        (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);
      var inGameViewTester = InGameViewTester(tester);

      when(Mocks.appBloc.state).thenAnswer((_) => InGameAppState());

      await tester.pumpWidget(AtoupicApp());

      expect(homeViewTester.isVisible, isFalse);
      expect(inGameViewTester.isVisible, isTrue);
    });
  });
}
