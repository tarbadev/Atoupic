import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class TurnResultTester extends BaseViewTester {
  TurnResultTester(tester) : super(tester);

  bool get isVisible => widgetExists('TurnResultDialog');

  bool get win => getTextByKey('TurnResultDialog__Result') == 'Contract fulfilled';

  int get takerScore => int.parse(getTextByKey('TurnResultDialog__TakerScore'));

  int get opponentScore => int.parse(getTextByKey('TurnResultDialog__OpponentScore'));

  Future<void> tapOnNext() async => await tapOnButtonByKey('TurnResultDialog__NextButton');

  String get taker => getTextByKey('TurnResultDialog__Taker');
}
