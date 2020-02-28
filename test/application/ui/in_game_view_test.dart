import 'package:atoupic/application/domain/entity/Turn.dart';
import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/game_context.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:atoupic/application/domain/service/game_service.dart';
import 'package:atoupic/application/ui/application_actions.dart';
import 'package:atoupic/application/ui/view/in_game_view.dart';
import 'package:atoupic/game/components/player_component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helper/fake_application_injector.dart';
import '../../helper/mock_definition.dart';
import '../../helper/test_factory.dart';
import '../../helper/testable_widget.dart';
import '../../in_game_view_tester.dart';

void main() {
  setupDependencyInjectorForTest();

  group('InGameView', () {
    testWidgets('displays dialog if showTakeOrPassDialog is true',
        (WidgetTester tester) async {
      var inGameView = InGameView();

      await tester.pumpWidget(buildTestableWidget(
        inGameView,
        showTakeOrPassDialog: true,
        takeOrPassCard: Card(CardColor.Club, CardHead.Ace),
      ));
      await tester.pump();

      var inGameViewTester = InGameViewTester(tester);
      expect(inGameViewTester.takeOrPass.isVisible, isTrue);
    });
  });
}
