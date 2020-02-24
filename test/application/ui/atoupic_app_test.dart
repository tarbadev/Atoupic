import 'package:atoupic/application/ui/atoupic_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../atoupic_app_view.dart';
import '../../fake_application_injector.dart';
import '../../mock_definition.dart';

void main() {
  setupDependencyInjectorForTest();

  testWidgets('AtoupicApp display the game when clicking on solo', (WidgetTester tester) async {
    var atoupicAppView = AtoupicAppView(tester);

    await tester.pumpWidget(AtoupicApp());

    verify(Mocks.atoupicGame.widget);

    await atoupicAppView.tapOnSolo();

    verify(Mocks.atoupicGame.visible = true);
  });

  testWidgets('AtoupicApp load cards through cardService', (WidgetTester tester) async {
    await tester.pumpWidget(AtoupicApp());

    verify(Mocks.cardService.initializeCards());
  });
}
