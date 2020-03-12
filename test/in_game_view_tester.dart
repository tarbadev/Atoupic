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

  String get turn => getTextByKey('InGame__TurnCounter');
}

class TakeOrPassDialogElement extends BaseViewTester {
  TakeOrPassDialogElement(tester) : super(tester);

  Finder get _passButtonFinder => find.byKey(Key('TakeOrPassDialog__PassButton'));

  Finder get _takeButtonFinder => find.byKey(Key('TakeOrPassDialog__TakeButton'));

  bool get isVisible => widgetExists('TakeOrPassDialog');

  List<CardColor> get colorChoices =>
      (tester.widget(find.byKey(Key('TakeOrPassDialog__ColorChoices'))) as Row)
          .children
          .map((container) => (((container as Container).child as RaisedButton).child as Text).data)
          .map((symbol) => CardColor.values.firstWhere((cardColor) => cardColor.symbol == symbol))
          .toList();

  Future<void> tapOnPass() async => await tester.tap(_passButtonFinder);

  Future<void> tapOnTake() async => await tester.tap(_takeButtonFinder);

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

  Position get taker {
    var takerPosition = getTextByKey('TurnResultDialog__Taker');
    return Position.values
        .firstWhere((position) => takerPosition.contains(position.toString()));
  }
}
