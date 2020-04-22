import 'base_view_tester.dart';
import 'game_result_tester.dart';
import 'score_tester.dart';
import 'take_or_pass_tester.dart';
import 'turn_result_dialog_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassTester get takeOrPass => TakeOrPassTester(tester);

  TurnResultTester get turnResult => TurnResultTester(tester);
  GameResultTester get gameResult => GameResultTester(tester);
  ScoreTester get score => ScoreTester(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}