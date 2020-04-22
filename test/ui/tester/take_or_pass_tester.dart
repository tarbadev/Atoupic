import 'package:atoupic/domain/entity/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'base_view_tester.dart';

class TakeOrPassTester extends BaseViewTester {
  TakeOrPassTester(tester) : super(tester);

  bool get isVisible => widgetExists('TakeOrPassContainer');

  List<CardColor> get colorChoices =>
      (tester.widget(find.byKey(Key('TakeOrPassContainer__Buttons'))) as Column)
          .children
          .map((flexible) =>
              ((((flexible as Flexible).child as ButtonTheme).child as OutlineButton).child as Text)
                  .data)
          .map((symbol) => CardColor.values
              .firstWhere((cardColor) => cardColor.symbol == symbol, orElse: () => null))
          .where((colorChoice) => colorChoice != null)
          .toList();

  Future<void> tapOnPass() async => await tapOnButtonByKey('TakeOrPassContainer__PassButton');

  Future<void> tapOnTake() async => await tapOnButtonByKey('TakeOrPassContainer__TakeButton');

  Future<void> tapOnColorChoice(CardColor cardColor) async {
    var button = (tester.widget(find.byKey(Key('TakeOrPassContainer__Buttons'))) as Column)
        .children
        .firstWhere((flexible) =>
            ((((flexible as Flexible).child as ButtonTheme).child as OutlineButton).child as Text)
                .data ==
            cardColor.symbol);
    return await tester.tap(find.byWidget(button));
  }
}
