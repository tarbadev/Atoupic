import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../home_view_tester.dart';
import '../../fake_application_injector.dart';
import '../../in_game_view_tester.dart';
import '../../mock_definition.dart';

void main() {
  setupDependencyInjectorForTest();

  group('AtoupicApp', () {
    testWidgets('loads the game on startup', (WidgetTester tester) async {
      await tester.pumpWidget(AtoupicApp());

      verify(Mocks.atoupicGame.widget);
    });

    testWidgets('calls startSoloGame when clicking on solo', (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);

      await tester.pumpWidget(AtoupicApp());
      await homeViewTester.tapOnSolo();

      verify(Mocks.gameService.startSoloGame());
    });

    testWidgets('changes view when clicking on solo', (WidgetTester tester) async {
      var homeViewTester = HomeViewTester(tester);
      var inGameViewTester = InGameViewTester(tester);

      await tester.pumpWidget(AtoupicApp());

      expect(homeViewTester.isVisible, isTrue);
      expect(inGameViewTester.isVisible, isFalse);

      await homeViewTester.tapOnSolo();
      await tester.pump();

      expect(homeViewTester.isVisible, isFalse);
      expect(inGameViewTester.isVisible, isTrue);
    });
  });
}
