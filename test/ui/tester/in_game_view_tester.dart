import 'package:atoupic/domain/entity/card.dart';
import 'package:atoupic/domain/entity/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';
import 'take_or_pass_dialog_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogTester get takeOrPass => TakeOrPassDialogTester(tester);

  TurnResultElement get turnResult => TurnResultElement(tester);
  GameResultElement get gameResult => GameResultElement(tester);
  ScoreElement get score => ScoreElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class TurnResultElement extends BaseViewTester {
  TurnResultElement(tester) : super(tester);

  bool get isVisible => widgetExists('TurnResultDialog');

  bool get win => getTextByKey('TurnResultDialog__Result') == 'Contract fulfilled';

  int get takerScore => int.parse(getTextByKey('TurnResultDialog__TakerScore'));

  int get opponentScore => int.parse(getTextByKey('TurnResultDialog__OpponentScore'));

  Future<void> tapOnNext() async => await tapOnButtonByKey('TurnResultDialog__NextButton');

  Position get taker {
    var takerPosition = getTextByKey('TurnResultDialog__Taker');
    return Position.values
        .firstWhere((position) => takerPosition.contains(position.toString()));
  }
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