import 'package:atoupic/application/domain/entity/card.dart';
import 'package:atoupic/application/domain/entity/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class InGameViewTester extends BaseViewTester {
  InGameViewTester(tester) : super(tester);

  bool get isVisible => widgetExists('InGame__Container');

  TakeOrPassDialogElement get takeOrPass => TakeOrPassDialogElement(tester);

  TurnResultElement get turnResult => TurnResultElement(tester);
  ScoreElement get score => ScoreElement(tester);

  String get turn => getTextByKey('InGame__TurnCounter');
}

class TakeOrPassDialogElement extends BaseViewTester {
  TakeOrPassDialogElement(tester) : super(tester);

  bool get isVisible => widgetExists('TakeOrPassDialog');

  List<CardColor> get colorChoices =>
      (tester.widget(find.byKey(Key('TakeOrPassDialog__ColorChoices'))) as Row)
          .children
          .map((container) => (((container as Container).child as RaisedButton).child as Text).data)
          .map((symbol) => CardColor.values.firstWhere((cardColor) => cardColor.symbol == symbol))
          .toList();

  Future<void> tapOnPass() async => await tapOnButtonByKey('TakeOrPassDialog__PassButton');

  Future<void> tapOnTake() async => await tapOnButtonByKey('TakeOrPassDialog__TakeButton');

  Future<void> tapOnColorChoice(CardColor cardColor) async {
    var button = (tester.widget(find.byKey(Key('TakeOrPassDialog__ColorChoices'))) as Row)
        .children
        .firstWhere((container) =>
            (((container as Container).child as RaisedButton).child as Text).data ==
            cardColor.symbol);
    return await tester.tap(find.byWidget(button));
  }
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

class ScoreElement extends BaseViewTester {
  ScoreElement(tester) : super(tester);

  bool get isVisible => widgetExists('Score');

  int get us => int.parse(getTextByKey('Score__Us'));

  int get them => int.parse(getTextByKey('Score__Them'));
}