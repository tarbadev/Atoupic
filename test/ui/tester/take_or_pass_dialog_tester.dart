import 'package:atoupic/domain/entity/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class TakeOrPassDialogTester extends BaseViewTester {
  TakeOrPassDialogTester(tester) : super(tester);

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
