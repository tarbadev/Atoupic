import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'helper/home_view_driver.dart';
import 'helper/in_game_view_driver.dart';

void main() {
  FlutterDriver driver;
  HomeViewDriver homeView;
  InGameViewDriver inGameView;

  setUp(() {
    homeView = HomeViewDriver(driver);
    inGameView = InGameViewDriver(driver);
  });

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    await Future.delayed(Duration(seconds: 1));
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  group('Home Page', () {
    test('displays Game when clicking on Start Solo button', () async {
      expect(await homeView.isVisible, true);

      await homeView.tapOnStartSolo();
      expect(await homeView.isVisible, false);
      expect(await inGameView.isVisible, true);

      expect(await inGameView.score.us, 0);
      expect(await inGameView.score.them, 0);

      await Future.delayed(Duration(seconds: 2));

      expect(await inGameView.takeOrPassDialog.isVisible, true);
    });
  });
}
