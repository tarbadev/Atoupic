import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class GameResultTester extends BaseViewTester {
  GameResultTester(tester) : super(tester);

  bool get isVisible => widgetExists('GameResultDialog');

  String get result => getTextByKey('GameResultDialog__Result');

  int get usScore => int.parse(getTextByKey('GameResultDialog__UsScore'));

  int get themScore => int.parse(getTextByKey('GameResultDialog__ThemScore'));

  Future<void> tapOnHome() async => await tapOnButtonByKey('GameResultDialog__HomeButton');

  Future<void> tapOnNewGame() async => await tapOnButtonByKey('GameResultDialog__NewGameButton');
}
