import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';
import 'take_or_pass_dialog_tester.dart';
import 'turn_result_dialog_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogTester get takeOrPass => TakeOrPassDialogTester(tester);

  TurnResultTester get turnResult => TurnResultTester(tester);
  GameResultElement get gameResult => GameResultElement(tester);
  ScoreElement get score => ScoreElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class GameResultElement extends BaseViewTester {
  GameResultElement(tester) : super(tester);

  bool get isVisible => widgetExists('GameResultDialog');

  String get result => getTextByKey('GameResultDialog__Result');

  int get usScore => int.parse(getTextByKey('GameResultDialog__UsScore'));

  int get themScore => int.parse(getTextByKey('GameResultDialog__ThemScore'));

  Future<void> tapOnHome() async => await tapOnButtonByKey('GameResultDialog__HomeButton');
  Future<void> tapOnNewGame() async => await tapOnButtonByKey('GameResultDialog__NewGameButton');
}

class ScoreElement extends BaseViewTester {
  ScoreElement(tester) : super(tester);

  bool get isVisible => widgetExists('Score');

  int get us => int.parse(getTextByKey('Score__Us'));

  int get them => int.parse(getTextByKey('Score__Them'));
}