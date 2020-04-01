import 'base_view_tester.dart';
import 'game_result_tester.dart';
import 'take_or_pass_dialog_tester.dart';
import 'turn_result_dialog_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogTester get takeOrPass => TakeOrPassDialogTester(tester);

  TurnResultTester get turnResult => TurnResultTester(tester);
  GameResultTester get gameResult => GameResultTester(tester);
  ScoreElement get score => ScoreElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class ScoreElement extends BaseViewTester {
  ScoreElement(tester) : super(tester);

  bool get isVisible => widgetExists('Score');

  int get us => int.parse(getTextByKey('Score__Us'));

  int get them => int.parse(getTextByKey('Score__Them'));
}